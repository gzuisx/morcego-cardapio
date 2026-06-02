-- ============================================================
-- MOCERGO — RLS apertada (Fase 3.2)
-- Cliente anônimo: só cria pedidos/chamados, vota, lê cardápio/config
-- Admin autenticado: controla tudo
-- Rodar no SQL Editor do Supabase.
-- ============================================================

-- Remove policies permissivas antigas
drop policy if exists "allow_all_orders"    on morcego_orders;
drop policy if exists "allow_all_calls"     on morcego_calls;
drop policy if exists "allow_all_reactions" on morcego_reactions;
drop policy if exists "allow_all_settings"  on morcego_settings;
drop policy if exists "allow_all_products"     on products;
drop policy if exists "pub_read_products"      on products;
drop policy if exists "allow_all_categories"   on categories;
drop policy if exists "pub_read_categories"    on categories;
drop policy if exists "allow_all_restaurants"  on restaurants;
drop policy if exists "pub_read_restaurants"   on restaurants;

-- ORDERS: cliente cria (anon insert), admin lê/atualiza/exclui (auth)
create policy "orders_insert_anon" on morcego_orders for insert to anon, authenticated with check (true);
create policy "orders_select_auth" on morcego_orders for select to authenticated using (true);
create policy "orders_update_auth" on morcego_orders for update to authenticated using (true) with check (true);
create policy "orders_delete_auth" on morcego_orders for delete to authenticated using (true);

-- CALLS: cliente chama (anon insert), admin lê/atualiza (auth)
create policy "calls_insert_anon" on morcego_calls for insert to anon, authenticated with check (true);
create policy "calls_select_auth" on morcego_calls for select to authenticated using (true);
create policy "calls_update_auth" on morcego_calls for update to authenticated using (true) with check (true);
create policy "calls_delete_auth" on morcego_calls for delete to authenticated using (true);

-- REACTIONS: cliente vê e vota (anon), todos leem
create policy "reactions_all_anon" on morcego_reactions for all to anon, authenticated using (true) with check (true);

-- SETTINGS: todos leem, só admin altera
create policy "settings_select_all"  on morcego_settings for select to anon, authenticated using (true);
create policy "settings_write_auth"  on morcego_settings for insert to authenticated with check (true);
create policy "settings_update_auth" on morcego_settings for update to authenticated using (true) with check (true);

-- PRODUCTS: todos leem, só admin escreve
create policy "products_select_all"  on products for select to anon, authenticated using (true);
create policy "products_write_auth"  on products for all to authenticated using (true) with check (true);

-- CATEGORIES: todos leem, só admin escreve
create policy "categories_select_all" on categories for select to anon, authenticated using (true);
create policy "categories_write_auth" on categories for all to authenticated using (true) with check (true);

-- RESTAURANTS: todos leem, só admin escreve
create policy "restaurants_select_all" on restaurants for select to anon, authenticated using (true);
create policy "restaurants_write_auth" on restaurants for all to authenticated using (true) with check (true);

select 'RLS aplicada com sucesso.' as resultado;
