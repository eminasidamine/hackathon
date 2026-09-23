-- Category and collection-banner images use buckets that were never created
-- alongside the rest of the schema (marketplace_schema.sql only creates
-- product-images, shop-images, payment-proofs and avatars). Every upload
-- from the admin "New category" / "New collection" dialogs was failing
-- against a bucket that doesn't exist — silently, because the app's
-- generic error SnackBar renders behind the dialog's own modal barrier.
-- Run this once in the Supabase SQL Editor.

insert into storage.buckets (id, name, public)
values ('category-images', 'category-images', true)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
values ('banner-images', 'banner-images', true)
on conflict (id) do nothing;

-- drop-then-create makes this rerunnable: "create policy" alone errors out
-- (42710) if a policy with that name already exists, unlike the bucket
-- inserts above which use "on conflict do nothing".
drop policy if exists "public_read_category_images" on storage.objects;
create policy "public_read_category_images"
  on storage.objects for select
  using (bucket_id = 'category-images');

drop policy if exists "public_read_banner_images" on storage.objects;
create policy "public_read_banner_images"
  on storage.objects for select
  using (bucket_id = 'banner-images');

drop policy if exists "authenticated_write_category_images" on storage.objects;
create policy "authenticated_write_category_images"
  on storage.objects for insert
  with check (bucket_id = 'category-images' and auth.role() = 'authenticated');

drop policy if exists "authenticated_write_banner_images" on storage.objects;
create policy "authenticated_write_banner_images"
  on storage.objects for insert
  with check (bucket_id = 'banner-images' and auth.role() = 'authenticated');
