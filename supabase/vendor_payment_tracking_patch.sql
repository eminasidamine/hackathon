-- Run once in Supabase > SQL Editor, after marketplace_schema.sql and
-- anti_self_dealing_patch.sql (extends the real, live
-- restrict_client_order_update() trigger — same name, confirmed via
-- introspection this session, not a guess). Safe to re-run.
--
-- Adds payment tracking for the vendor dashboard:
--   - payment_status ('submitted' / 'verified' / 'rejected'), set by the
--     vendor once she finds the reference in her banking app.
--   - payment_provider, copied from the shop at order time.
--   - payment_amount_received, what the vendor actually saw land in her
--     account — compared to the order total to catch a reference that's
--     real and unused but for a smaller payment than the order.
--   - shops.women_led: optional, self-declared, impact measurement only —
--     never a gate, never part of any scoring.
--
-- NOT included here: order_items price-integrity triggers
-- (trg_enforce_order_item_price / trg_recompute_order_total already exist
-- live under those names — reused as-is, not duplicated).

alter table public.orders
  add column if not exists payment_status text not null default 'submitted'
    check (payment_status in ('submitted', 'verified', 'rejected')),
  add column if not exists payment_provider text,
  add column if not exists payment_verified_at timestamptz,
  add column if not exists payment_amount_received numeric(12,2)
    check (payment_amount_received is null or payment_amount_received >= 0);

update public.orders
   set payment_status = 'verified',
       payment_verified_at = coalesce(confirmed_at, created_at)
 where payment_reference is not null
   and payment_status = 'submitted'
   and status in ('confirmed', 'preparing', 'delivering', 'delivered');

update public.orders o
   set payment_provider = s.merchant_provider
  from public.shops s
 where s.id = o.shop_id
   and o.payment_provider is null
   and s.merchant_provider is not null;

create index if not exists orders_shop_created_idx
  on public.orders (shop_id, created_at desc);

create index if not exists orders_shop_payment_status_idx
  on public.orders (shop_id, payment_status);

create or replace function public.payment_gap(order_row public.orders)
returns numeric
language sql
immutable
as $$
  select case
    when order_row.payment_amount_received is null then null
    else round(order_row.payment_amount_received - order_row.total, 2)
  end;
$$;

create or replace function public.restrict_client_order_update()
returns trigger
language plpgsql
security definer
set search_path to 'public'
as $function$
begin
  if coalesce(current_setting('app.bypass_order_guard', true), '') = 'on' then
    return new;
  end if;

  if public.owns_shop(old.shop_id) or public.is_admin() then
    return new;
  end if;

  if new.client_id is distinct from old.client_id
     or new.shop_id is distinct from old.shop_id
     or new.total is distinct from old.total
     or new.created_at is distinct from old.created_at
     or new.confirmed_at is distinct from old.confirmed_at
     or new.payment_reference is distinct from old.payment_reference
     or new.delivery_mode is distinct from old.delivery_mode
     or new.payment_status is distinct from old.payment_status
     or new.payment_provider is distinct from old.payment_provider
     or new.payment_verified_at is distinct from old.payment_verified_at
     or new.payment_amount_received is distinct from old.payment_amount_received then
    raise exception 'Une commande déjà passée ne peut plus être modifiée.';
  end if;

  if new.status is distinct from old.status
     and not (old.status = 'pending' and new.status = 'cancelled') then
    raise exception 'Seule l''annulation d''une commande en attente est possible.';
  end if;

  return new;
end;
$function$;

create or replace function public.trg_clear_amount_on_unverify()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new.payment_status is distinct from old.payment_status
     and new.payment_status <> 'verified' then
    new.payment_amount_received := null;
  end if;
  return new;
end;
$$;

drop trigger if exists clear_amount_on_unverify on public.orders;
create trigger clear_amount_on_unverify
  before update on public.orders
  for each row execute function public.trg_clear_amount_on_unverify();

create or replace function public.trg_payment_verified_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new.payment_status is distinct from old.payment_status then
    new.payment_verified_at := case
      when new.payment_status = 'verified' then now()
      else null
    end;
  end if;
  return new;
end;
$$;

drop trigger if exists payment_verified_at_stamp on public.orders;
create trigger payment_verified_at_stamp
  before update on public.orders
  for each row execute function public.trg_payment_verified_at();

alter table public.shops
  add column if not exists women_led boolean;

create or replace function public.inclusion_stats()
returns table (
  total_shops     bigint,
  women_led_shops bigint,
  declared_shops  bigint,
  cities          bigint
)
language sql
security definer
stable
set search_path = public
as $$
  select
    count(*) as total_shops,
    count(*) filter (where women_led is true) as women_led_shops,
    count(*) filter (where women_led is not null) as declared_shops,
    count(distinct city) filter (where city is not null and city <> '') as cities
  from public.shops
  where is_visible = true;
$$;

grant execute on function public.inclusion_stats() to anon, authenticated;
