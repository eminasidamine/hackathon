-- Run once in Supabase > SQL Editor, after marketplace_schema.sql.

drop policy if exists "reviews_insert_own" on public.reviews;
create policy "reviews_insert_own"
  on public.reviews for insert
  with check (
    client_id = auth.uid()
    and order_id is not null
    and exists (
      select 1
      from public.orders o
      join public.order_items oi on oi.order_id = o.id
      where o.id = order_id
        and o.client_id = auth.uid()
        and oi.product_id = reviews.product_id
    )
  );

