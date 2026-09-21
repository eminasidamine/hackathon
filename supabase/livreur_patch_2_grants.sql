-- Run once in Supabase > SQL Editor, after livreur_patch.sql.

grant select, insert, update on public.driver_profiles to authenticated;
grant select, insert on public.delivery_requests to authenticated;

grant execute on function public.accept_delivery_request(uuid) to authenticated;
grant execute on function public.mark_delivery_delivered(uuid) to authenticated;
grant execute on function public.get_delivery_contact(uuid) to authenticated;

