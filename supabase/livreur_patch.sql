-- Run once in Supabase > SQL Editor, after marketplace_schema.sql.

alter table public.shops
  add column if not exists lat double precision,
  add column if not exists lng double precision;


create table if not exists public.driver_profiles (
  id           uuid primary key references public.profiles(id) on delete cascade,
  vehicle_type text,
  is_available boolean not null default false,
  created_at   timestamptz not null default now()
);

alter table public.driver_profiles enable row level security;

drop policy if exists "driver_profiles_select_own" on public.driver_profiles;
create policy "driver_profiles_select_own"
  on public.driver_profiles for select
  using (id = auth.uid() or exists (
    select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'
  ));

drop policy if exists "driver_profiles_insert_own" on public.driver_profiles;
create policy "driver_profiles_insert_own"
  on public.driver_profiles for insert
  with check (id = auth.uid());

drop policy if exists "driver_profiles_update_own" on public.driver_profiles;
create policy "driver_profiles_update_own"
  on public.driver_profiles for update
  using (id = auth.uid());


create table if not exists public.delivery_requests (
  id           uuid primary key default gen_random_uuid(),
  order_id     uuid not null references public.orders(id) on delete cascade,
  shop_id      uuid not null references public.shops(id) on delete cascade,
  pickup_lat   double precision,
  pickup_lng   double precision,
  dropoff_lat  double precision,
  dropoff_lng  double precision,
  distance_km  numeric,
  status       text not null default 'pending'
                 check (status in ('pending','accepted','delivered','cancelled')),
  driver_id    uuid references public.profiles(id) on delete set null,
  created_at   timestamptz not null default now(),
  accepted_at  timestamptz,
  delivered_at timestamptz,
  unique (order_id)
);

create index if not exists delivery_requests_status_idx on public.delivery_requests (status);
create index if not exists delivery_requests_driver_idx on public.delivery_requests (driver_id);

alter table public.delivery_requests enable row level security;


drop policy if exists "delivery_requests_select" on public.delivery_requests;
create policy "delivery_requests_select"
  on public.delivery_requests for select
  using (
    status = 'pending'
    or driver_id = auth.uid()
    or exists (select 1 from public.orders o where o.id = order_id and o.client_id = auth.uid())
    or exists (select 1 from public.shops s where s.id = shop_id and s.owner_id = auth.uid())
    or exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin')
  );


drop policy if exists "delivery_requests_insert_client" on public.delivery_requests;
create policy "delivery_requests_insert_client"
  on public.delivery_requests for insert
  with check (exists (select 1 from public.orders o where o.id = order_id and o.client_id = auth.uid()));


create or replace function public.trg_delivery_request_distance()
returns trigger
language plpgsql
as $$
declare
  v_r constant double precision := 6371;
  v_dlat double precision;
  v_dlng double precision;
  v_a double precision;
begin
  if new.pickup_lat is null or new.pickup_lng is null
     or new.dropoff_lat is null or new.dropoff_lng is null then
    new.distance_km := null;
    return new;
  end if;
  v_dlat := radians(new.dropoff_lat - new.pickup_lat);
  v_dlng := radians(new.dropoff_lng - new.pickup_lng);
  v_a := sin(v_dlat / 2) ^ 2
       + cos(radians(new.pickup_lat)) * cos(radians(new.dropoff_lat)) * sin(v_dlng / 2) ^ 2;
  new.distance_km := round((v_r * 2 * atan2(sqrt(v_a), sqrt(1 - v_a)))::numeric, 2);
  return new;
end;
$$;

drop trigger if exists delivery_requests_distance on public.delivery_requests;
create trigger delivery_requests_distance
  before insert or update of pickup_lat, pickup_lng, dropoff_lat, dropoff_lng
  on public.delivery_requests
  for each row execute function public.trg_delivery_request_distance();


create or replace function public.accept_delivery_request(p_request_id uuid)
returns public.delivery_requests
language plpgsql
security definer
set search_path = public
as $$
declare
  v_row public.delivery_requests;
begin
  if not exists (select 1 from public.driver_profiles where id = auth.uid()) then
    raise exception 'Only a registered driver can accept a delivery.';
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

  update public.orders set status = 'delivered' where id = v_row.order_id;

  return v_row;
end;
$$;


create or replace function public.get_delivery_contact(p_request_id uuid)
returns table(client_full_name text, client_phone text, client_address text, client_city text)
language plpgsql
security definer
set search_path = public
as $$
begin
  return query
    select o.client_full_name, o.client_phone, o.client_address, o.client_city
    from public.delivery_requests d
    join public.orders o on o.id = d.order_id
    where d.id = p_request_id
      and d.driver_id = auth.uid();
end;
$$;


do $$
begin
  execute 'alter publication supabase_realtime add table public.delivery_requests';
exception when duplicate_object then
  null; -- déjà ajoutée (patch relancé une deuxième fois) : rien à faire
end $$;

