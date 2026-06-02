-- ============================================================
-- MOCERGO — Roles de usuário (Fase 3.3)
-- ADMIN | CAIXA | COZINHA | GARCOM
-- Rodar no SQL Editor do Supabase.
-- ============================================================

create table if not exists user_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  restaurant_id uuid references restaurants(id) on delete cascade,
  role text not null default 'admin',  -- admin | caixa | cozinha | garcom
  name text default '',
  created_at timestamptz default now()
);

alter table user_roles enable row level security;

-- Cada usuário lê o próprio role
drop policy if exists "roles_select_self" on user_roles;
create policy "roles_select_self" on user_roles
  for select to authenticated using (auth.uid() = user_id);

-- Admin pode gerenciar todos os roles do seu restaurante
drop policy if exists "roles_admin_all" on user_roles;
create policy "roles_admin_all" on user_roles
  for all to authenticated
  using (exists (select 1 from user_roles r where r.user_id = auth.uid() and r.role = 'admin'))
  with check (exists (select 1 from user_roles r where r.user_id = auth.uid() and r.role = 'admin'));

select 'Tabela user_roles criada.' as resultado;
