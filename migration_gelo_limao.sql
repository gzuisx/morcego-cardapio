-- ============================================================
-- MOCERGO — Adicionar opções "Com/Sem Gelo" e "Com/Sem Limão"
-- aos drinks e bebidas. Preserva extras existentes (concat jsonb).
-- Rodar no SQL Editor do Supabase.
-- ============================================================

-- Bloco GELO+LIMÃO (drinks e drinks autorais)
update products
set extras = coalesce(extras, '[]'::jsonb) ||
  '[
    {"title":"GELO","type":"select","opts":[{"name":"Com gelo"},{"name":"Sem gelo"}]},
    {"title":"LIMÃO","type":"select","opts":[{"name":"Com limão"},{"name":"Sem limão"}]}
  ]'::jsonb
where category_id in (
  '6ebb85a6-1926-4ada-8a54-6482ea4eb8f2',  -- drinks-autorais
  'edc51e35-51fe-4734-bbe3-afc33c35c237'   -- drinks
)
and (extras is null or extras::text not ilike '%"GELO"%');

-- Bloco GELO+LIMÃO (sem-álcool: sucos, sodas, chás, tônicas — exclui água/café/lata fechada)
update products
set extras = coalesce(extras, '[]'::jsonb) ||
  '[
    {"title":"GELO","type":"select","opts":[{"name":"Com gelo"},{"name":"Sem gelo"}]},
    {"title":"LIMÃO","type":"select","opts":[{"name":"Com limão"},{"name":"Sem limão"}]}
  ]'::jsonb
where category_id = '574d013d-bed4-48db-bd6a-b9db5e65a6b7'  -- sem-alcool
and (extras is null or extras::text not ilike '%"GELO"%')
and name not ilike '%água%'
and name not ilike '%café%'
and name not ilike '%espresso%'
and name not ilike '%redbull%'
and name not ilike '%coca%'
and name not ilike '%corona%'
and name not ilike '%lata%';

-- Bloco só GELO (cervejas que aceitam gelo? geralmente não — pular)
-- Destilados servidos com gelo (dose): adiciona só GELO
update products
set extras = coalesce(extras, '[]'::jsonb) ||
  '[
    {"title":"GELO","type":"select","opts":[{"name":"Com gelo"},{"name":"Sem gelo"}]}
  ]'::jsonb
where category_id = '91ddf1cf-e406-413f-a549-051dd237b3ac'  -- destilados
and (extras is null or extras::text not ilike '%"GELO"%')
and name not ilike '%cachaça%';

select 'Opções de gelo/limão adicionadas.' as resultado;
