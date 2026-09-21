-- Run once in Supabase > SQL Editor, after livreur_patch.sql and
-- livreur_patch_2_grants.sql.

alter table public.driver_profiles
  add column if not exists status text not null default 'pending'
    check (status in ('pending', 'approved', 'rejected'));


drop policy if exists "delivery_requests_select" on public.delivery_requests;
create policy "delivery_requests_select"
  on public.delivery_requests for select
  using (
    (status = 'pending' and exists (
      select 1 from public.driver_profiles dp
      where dp.id = auth.uid() and dp.status = 'approved'
    ))
    or driver_id = auth.uid()
    or exists (select 1 from public.orders o where o.id = order_id and o.client_id = auth.uid())
    or exists (select 1 from public.shops s where s.id = shop_id and s.owner_id = auth.uid())
    or exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin')
  );


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


drop policy if exists "driver_profiles_update_admin" on public.driver_profiles;
create policy "driver_profiles_update_admin"
  on public.driver_profiles for update
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'));


