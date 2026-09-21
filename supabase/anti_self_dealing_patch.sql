-- Run once in Supabase > SQL Editor, after marketplace_schema.sql,
-- livreur_patch.sql, livreur_patch_2_grants.sql, livreur_patch_3_approval.sql
-- and whatever added restrict_client_order_update() (not in this repo, but
-- live on the database). Safe to re-run even if an earlier version of this
-- file was already applied.
--
-- 1. A vendor cannot place an order against their own shop.
-- 2. A driver cannot accept the delivery of an order they placed themselves.
-- 3. Fixes "Seule l'annulation d'une commande en attente est possible" on
--    Accept: restrict_client_order_update() only let the shop owner or an
--    admin change an order's status, so it also blocked
--    accept_delivery_request()/mark_delivery_delivered() updating status
--    on behalf of a driver. Those two functions now set a transaction-local
--    flag right before touching orders, and the trigger lets it through.
-- 4. New: release_delivery_request(), so a driver can hand an accepted
--    delivery back to the board (order status reverts to 'preparing').

drop policy if exists "orders_insert_client" on public.orders;
create policy "orders_insert_client"
  on public.orders for insert
  with check (client_id = auth.uid() and not public.owns_shop(shop_id));

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
     or new.delivery_mode is distinct from old.delivery_mode then
    raise exception 'Une commande déjà passée ne peut plus être modifiée.';
  end if;

  if new.status is distinct from old.status
     and not (old.status = 'pending' and new.status = 'cancelled') then
    raise exception 'Seule l''annulation d''une commande en attente est possible.';
  end if;

  return new;
end;
$function$;

create or replace function public.accept_delivery_request(p_request_id uuid)
returns public.delivery_requests
language plpgsql
security definer
set search_path = public
as $$
declare
  v_row public.delivery_requests;
begin
  if not exists (
    select 1 from public.driver_profiles where id = auth.uid() and status = 'approved'
  ) then
    raise exception 'Your driver account is not approved yet.';
  end if;

  if exists (
    select 1 from public.delivery_requests d
    join public.orders o on o.id = d.order_id
    where d.id = p_request_id and o.client_id = auth.uid()
  ) then
    raise exception 'You cannot accept the delivery of your own order.';
  end if;

  update public.delivery_requests
     set driver_id = auth.uid(),
         status = 'accepted',
         accepted_at = now()
   where id = p_request_id
     and status = 'pending'
  returning * into v_row;

  if v_row.id is null then
    raise exception 'This delivery has already been taken by another driver.';
  end if;

  perform set_config('app.bypass_order_guard', 'on', true);
  update public.orders set status = 'delivering' where id = v_row.order_id;

  return v_row;
end;
$$;

create or replace function public.mark_delivery_delivered(p_request_id uuid)
returns public.delivery_requests
language plpgsql
security definer
set search_path = public
as $$
declare
  v_row public.delivery_requests;
begin
  update public.delivery_requests
     set status = 'delivered',
         delivered_at = now()
   where id = p_request_id
     and driver_id = auth.uid()
     and status = 'accepted'
  returning * into v_row;

  if v_row.id is null then
    raise exception 'Delivery not found or not assigned to you.';
  end if;

  perform set_config('app.bypass_order_guard', 'on', true);
  update public.orders set status = 'delivered' where id = v_row.order_id;

  return v_row;
end;
$$;

create or replace function public.release_delivery_request(p_request_id uuid)
returns public.delivery_requests
language plpgsql
security definer
set search_path = public
as $$
declare
  v_row public.delivery_requests;
begin
  update public.delivery_requests
     set driver_id = null,
         status = 'pending',
         accepted_at = null
   where id = p_request_id
     and driver_id = auth.uid()
     and status = 'accepted'
  returning * into v_row;

  if v_row.id is null then
    raise exception 'Delivery not found or not assigned to you.';
  end if;

  perform set_config('app.bypass_order_guard', 'on', true);
  update public.orders set status = 'preparing' where id = v_row.order_id;

  return v_row;
end;
$$;

grant execute on function public.release_delivery_request(uuid) to authenticated;
