-- ============================================================
-- MOCERGO — RLS apertada (idempotente — pode rodar várias vezes)
-- Cliente anônimo: cria pedidos/chamados, vota, lê cardápio/config
-- Admin autenticado: controla tudo
-- ============================================================

-- ORDERS
drop policy if exists "allow_all_orders"  on morcego_orders;
drop policy if exists "orders_insert_anon" on morcego_orders;
drop policy if exists "orders_select_auth" on morcego_orders;
drop policy if exists "orders_update_auth" on morcego_orders;
drop policy if exists "orders_delete_auth" on morcego_orders;
create policy "orders_insert_anon" on morcego_orders for insert to anon, authenticated with check (true);
create policy "orders_select_auth" on morcego_orders for select to authenticated using (true);
create policy "orders_update_auth" on morcego_orders for update to authenticated using (true) with check (true);
create policy "orders_delete_auth" on morcego_orders for delete to authenticated using (true);

-- CALLS
drop policy if exists "allow_all_calls"  on morcego_calls;
drop policy if exists "calls_insert_anon" on morcego_calls;
drop policy if exists "calls_select_auth" on morcego_calls;
drop policy if exists "calls_update_auth" on morcego_calls;
drop policy if exists "calls_delete_auth" on morcego_calls;
create policy "calls_insert_anon" on morcego_calls for insert to anon, authenticated with check (true);
create policy "calls_select_auth" on morcego_calls for select to authenticated using (true);
create policy "calls_update_auth" on morcego_calls for update to authenticated using (true) with check (true);
create policy "calls_delete_auth" on morcego_calls for delete to authenticated using (true);

-- REACTIONS
drop policy if exists "allow_all_reactions" on morcego_reactions;
drop policy if exists "reactions_all_anon"  on morcego_reactions;
create policy "reactions_all_anon" on morcego_reactions for all to anon, authenticated using (true) with check (true);

-- SETTINGS
drop policy if exists "allow_all_settings"  on morcego_settings;
drop policy if exists "settings_select_all"  on morcego_settings;
drop policy if exists "settings_write_auth"  on morcego_settings;
drop policy if exists "settings_update_auth" on morcego_settings;
create policy "settings_select_all"  on morcego_settings for select to anon, authenticated using (true);
create policy "settings_write_auth"  on morcego_settings for insert to authenticated with check (true);
create policy "settings_update_auth" on morcego_settings for update to authenticated using (true) with check (true);

-- PRODUCTS
drop policy if exists "allow_all_products" on products;
drop policy if exists "pub_read_products"  on products;
drop policy if exists "products_select_all" on products;
drop policy if exists "products_write_auth" on products;
create policy "products_select_all" on products for select to anon, authenticated using (true);
create policy "products_write_auth" on products for all to authenticated using (true) with check (true);

-- CATEGORIES
drop policy if exists "allow_all_categories" on categories;
drop policy if exists "pub_read_categories"  on categories;
drop policy if exists "categories_select_all" on categories;
drop policy if exists "categories_write_auth" on categories;
create policy "categories_select_all" on categories for select to anon, authenticated using (true);
create policy "categories_write_auth" on categories for all to authenticated using (true) with check (true);

-- RESTAURANTS
drop policy if exists "allow_all_restaurants" on restaurants;
drop policy if exists "pub_read_restaurants"  on restaurants;
drop policy if exists "restaurants_select_all" on restaurants;
drop policy if exists "restaurants_write_auth" on restaurants;
create policy "restaurants_select_all" on restaurants for select to anon, authenticated using (true);
create policy "restaurants_write_auth" on restaurants for all to authenticated using (true) with check (true);

select 'RLS aplicada (idempotente).' as resultado;
