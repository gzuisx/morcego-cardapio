-- MORCEGO — Schema Supabase
-- Colar e executar no SQL Editor do Supabase

-- Orders (pedidos das mesas)
create table if not exists morcego_orders (
  id text primary key,
  table_number text not null,
  items jsonb not null,
  status text default 'new',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Calls (garçom / conta)
create table if not exists morcego_calls (
  id text primary key,
  table_number text not null,
  type text not null,
  status text default 'pending',
  created_at timestamptz default now()
);

-- Reactions (avaliações dos clientes)
create table if not exists morcego_reactions (
  product_id text primary key,
  fire integer default 0,
  heart integer default 0,
  meh integer default 0
);

-- Settings (configurações do dono)
create table if not exists morcego_settings (
  id integer primary key default 1,
  wait_time text,
  table_mode_enabled boolean default false,
  nightly_highlight jsonb default '{}',
  updated_at timestamptz default now()
);
insert into morcego_settings (id) values (1) on conflict (id) do nothing;

-- RLS — permite tudo por enquanto (restringir com auth na Fase 3)
alter table morcego_orders enable row level security;
alter table morcego_calls enable row level security;
alter table morcego_reactions enable row level security;
alter table morcego_settings enable row level security;

create policy "allow_all_orders"    on morcego_orders    for all using (true) with check (true);
create policy "allow_all_calls"     on morcego_calls     for all using (true) with check (true);
create policy "allow_all_reactions" on morcego_reactions for all using (true) with check (true);
create policy "allow_all_settings"  on morcego_settings  for all using (true) with check (true);

-- Realtime (pedidos e chamados em tempo real)
alter publication supabase_realtime add table morcego_orders;
alter publication supabase_realtime add table morcego_calls;
