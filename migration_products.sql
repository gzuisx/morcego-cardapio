-- ============================================================
-- MORCEGO — Fase 3: Tabelas de Categorias e Produtos
-- Colar no SQL Editor do Supabase e executar
-- ============================================================

-- 1. TABELAS
create table if not exists restaurants (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text unique not null,
  created_at timestamptz default now()
);

create table if not exists categories (
  id uuid primary key default gen_random_uuid(),
  restaurant_id uuid references restaurants(id) on delete cascade,
  slug text not null,
  name text not null,
  icon text default '',
  sort_order integer default 0,
  wide boolean default false,
  visible boolean default true
);

create table if not exists products (
  id uuid primary key default gen_random_uuid(),
  restaurant_id uuid references restaurants(id) on delete cascade,
  category_id uuid references categories(id) on delete cascade,
  name text not null,
  description text default '',
  price text default '',
  price_prefix text default '',
  image_url text default '',
  calories integer,
  allergens text[] default '{}',
  tags text[] default '{}',
  available boolean default true,
  extras jsonb,
  sort_order integer default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- 2. RLS
alter table restaurants enable row level security;
alter table categories enable row level security;
alter table products enable row level security;

do $$ begin
  if not exists (select 1 from pg_policies where tablename='restaurants' and policyname='pub_read_restaurants') then
    create policy "pub_read_restaurants" on restaurants for select using (true);
    create policy "allow_all_restaurants" on restaurants for all using (true) with check (true);
  end if;
  if not exists (select 1 from pg_policies where tablename='categories' and policyname='pub_read_categories') then
    create policy "pub_read_categories" on categories for select using (true);
    create policy "allow_all_categories" on categories for all using (true) with check (true);
  end if;
  if not exists (select 1 from pg_policies where tablename='products' and policyname='pub_read_products') then
    create policy "pub_read_products" on products for select using (true);
    create policy "allow_all_products" on products for all using (true) with check (true);
  end if;
end $$;

-- 3. DADOS
do $$
declare
  rid uuid;
  c_lojinha uuid; c_destaques uuid; c_cervejas uuid;
  c_drinks_a uuid; c_drinks uuid; c_rango uuid;
  c_vegano uuid; c_porcoes uuid; c_sobremesa uuid;
  c_sem uuid; c_destilados uuid; c_vinhos uuid;
  Z text := 'https://zig-public.zig.fun/images/';
  ZF text := 'https://zig-public-files.zig.fun/images/';
begin

-- Restaurant
insert into restaurants (name, slug) values ('Morcego Lanchonete', 'morcego')
on conflict (slug) do update set name=excluded.name returning id into rid;

-- Categories
insert into categories (restaurant_id,slug,name,icon,sort_order,wide) values (rid,'lojinha','Lojinha','🛍️',1,false) returning id into c_lojinha;
insert into categories (restaurant_id,slug,name,icon,sort_order,wide) values (rid,'destaques','Destaques','⭐',2,true) returning id into c_destaques;
insert into categories (restaurant_id,slug,name,icon,sort_order,wide) values (rid,'cervejas','Cervejas','🍺',3,false) returning id into c_cervejas;
insert into categories (restaurant_id,slug,name,icon,sort_order,wide) values (rid,'drinks-autorais','Drinks Autorais','🍹',4,true) returning id into c_drinks_a;
insert into categories (restaurant_id,slug,name,icon,sort_order,wide) values (rid,'drinks','Drinks','🥂',5,true) returning id into c_drinks;
insert into categories (restaurant_id,slug,name,icon,sort_order,wide) values (rid,'rango','Rango','🍔',6,true) returning id into c_rango;
insert into categories (restaurant_id,slug,name,icon,sort_order,wide) values (rid,'vegano','Vegano','🌿',7,false) returning id into c_vegano;
insert into categories (restaurant_id,slug,name,icon,sort_order,wide) values (rid,'porcoes','Porções','🍟',8,false) returning id into c_porcoes;
insert into categories (restaurant_id,slug,name,icon,sort_order,wide) values (rid,'sobremesa','Sobremesa','🍮',9,false) returning id into c_sobremesa;
insert into categories (restaurant_id,slug,name,icon,sort_order,wide) values (rid,'sem-alcool','Sem Álcool','🥤',10,false) returning id into c_sem;
insert into categories (restaurant_id,slug,name,icon,sort_order,wide) values (rid,'destilados','Destilados','🥃',11,false) returning id into c_destilados;
insert into categories (restaurant_id,slug,name,icon,sort_order,wide) values (rid,'vinhos','Vinhos','🍷',12,false) returning id into c_vinhos;

-- ── LOJINHA ──
insert into products (restaurant_id,category_id,name,description,price,price_prefix,image_url,sort_order,extras) values
(rid,c_lojinha,'CAMISETA MOCERGO KISS','Camiseta exclusiva Mocergo. Edição Kiss.','R$100,00','A partir de',ZF||'5374b397e434454cc51f5b68cf6385f09d99a74d35ddb7cb9a2fb579daf28748.jpg',1,'[{"title":"TAMANHO","type":"select","opts":[{"name":"P–M–G (incluso)"},{"name":"CAMISETA XG","price":"+R$10,00"}]}]'),
(rid,c_lojinha,'CAMISETA 7 ANOS MOCERGO','Camiseta comemorativa dos 7 anos de Mocergo.','R$110,00','',ZF||'3cdb7b5414de7e7af454df8e6935a438c33bf44f3b962f5fa8e4151c6da807c8.jpg',2,null),
(rid,c_lojinha,'SERIGRAFIA MOCERGO','Arte em serigrafia. Tamanho: 67cm x 50cm.','R$120,00','',ZF||'8a6d748e57409fd604f7d9123c2aa10ba3bc5ededcfd728fcc6acfd5859a5765.jpg',3,null);

-- ── DESTAQUES ──
insert into products (restaurant_id,category_id,name,description,price,image_url,sort_order,extras) values
(rid,c_destaques,'ARANCINI DE CALABRESA','Arancini de calabresa com parmesão. [4 unidades]','R$44,90',ZF||'6041d7af90ba6e0de6a99a9c08dd0f101a6c71d7ead94b193c605dcdc3a20620.jpg',1,null),
(rid,c_destaques,'GALINHO XIKILIRO','Sobrecoxa de frango empanada, com molho barbecue artesanal. Sabores da cidade.','R$33,60',ZF||'3c933473f78d9945afe6309fb917924de95d64233f0d7c39958fb1d53a6de20d.jpg',2,'[{"title":"ADICIONAIS","type":"add","opts":[{"name":"BACON","price":"+R$7,00"},{"name":"QUEIJO EXTRA","price":"+R$7,00"},{"name":"BATATA SIDE","price":"+R$10,00"}]}]');

-- ── CERVEJAS ──
insert into products (restaurant_id,category_id,name,description,price,image_url,sort_order,extras) values
(rid,c_cervejas,'CHOPP PILSEN','Chopp pilsen gelado.','R$18,00',Z||'202488d8ac6b10527221f6ad3bc83143f0f6a3bbc120a754fbc4b7234ad703df.jpg',1,null),
(rid,c_cervejas,'Chopp Ratazana IPA','Chopp IPA de fabricação própria.','R$25,00',Z||'7a66566d04c895a7938939fde785c03f419f2d55939fb739407caae6e3e1168c.jpg',2,null),
(rid,c_cervejas,'HEINEKEN (330ml)','A clássica verde. +18.','R$16,00',Z||'b1ce5310e57845176b8ece0261522d4ae4ef3e2c60d871b4f36b2ea94fb6e832.jpg',3,null),
(rid,c_cervejas,'CORONA (330ml)','Leve e refrescante. +18.','R$17,00',Z||'7cc0193d72085d64ec31a6bab23aa5ef1f6731fd1307430a920ddafc9b7fac37.jpg',4,'[{"title":"OPÇÕES","type":"add","opts":[{"name":"LIMÃO","price":"Grátis"}]}]'),
(rid,c_cervejas,'PURE GOLD','Stella Artois sem glúten. +18.','R$16,00',Z||'035a2158766e696cbcaea80889fd4dd9bf86232485679d0db5dc98395db1bc8d.jpg',5,null);

-- ── DRINKS AUTORAIS ──
insert into products (restaurant_id,category_id,name,description,price,image_url,sort_order) values
(rid,c_drinks_a,'Encuentro','Gin Gringo, coentro, limão tahiti, xarope de manga, suco de manga, borda de sal e coentro.','R$35,00',Z||'f5fcbf7d547ec89a06204c6269a172d39098e32d615487c93beb4557da6f0e20.jpg',1),
(rid,c_drinks_a,'Lixinho','Gin Gringo, xarope de lichia, chá de hibisco, limão siciliano e aquafaba.','R$35,00',Z||'bb679865b088d04d474b3bdc9a2b7b5b134019472a18d40925b01f0f19d7520c.jpg',2),
(rid,c_drinks_a,'Artemísia','Gin Bombay infusionado em canela, Amaretto, limão siciliano e aquafaba.','R$35,00',Z||'4e7eee6d1eaa3c4b80cb52e713463d7d35690c917772161a01915c9f6e63882f.jpg',3),
(rid,c_drinks_a,'CAMI SOUR','Bourbon, chá matte, cordial de gengibre, limão siciliano e aquafaba.','R$35,00',Z||'20db9b671aa635770e100aaabcd9bbbb46049caafa08f49410234745d07a4b7c.jpg',4),
(rid,c_drinks_a,'MATO SANTO','Gin Bombay, cordial de capim santo, sumo de limão e aquafaba.','R$35,00',Z||'f65ff44b45370e7d81e2afa6fe447869398ea34189480859e1eab7e47825764b.jpg',5),
(rid,c_drinks_a,'Pula Pirata','Rum Prata, Rum Ouro, xarope de toranja, xarope de capim santo, suco de limão.','R$35,00',Z||'8447a67a3b691b072960777d7318752693849e0c70abd26f45e36265d61203a7.jpg',6),
(rid,c_drinks_a,'CABARÉ','Fireball, Steinhager, Xarope de açúcar, Limão siciliano, Aquafaba.','R$35,00',Z||'bd73dd914e54853477ffc9d86e0010a253261af9b6c8c404e047cee2ba101435.jpg',7),
(rid,c_drinks_a,'MARACARU','Gin, tequila, polpa de maracujá, limão siciliano, xarope de açúcar e aquafaba.','R$35,00',Z||'eb42ab5e8a61035c6e158b1e12348385c06475c76c2158d23f21a72c89b68a23.jpg',8),
(rid,c_drinks_a,'CABAQUI','Whisky bourbon, suco de abacaxi, xarope de hortelã e limão siciliano.','R$35,00',Z||'825e0a81961a8f3f27d8551af87ccd02b409dfbf7011dd6edeba778822966ed9.jpg',9),
(rid,c_drinks_a,'PARANGA','Gin, xarope artesanal de manjericão, uva verde macerada e limão.','R$35,00',ZF||'8299906ca0629ccccf8441ef1e1092518d9dd287980d71ec0dfbad696eac7bf9.jpg',10);

-- ── DRINKS ──
insert into products (restaurant_id,category_id,name,description,price,image_url,sort_order,extras) values
(rid,c_drinks,'Amareto Sour','Amaretto, suco de limão siciliano, aquafaba e angostura.','R$32,00',Z||'beabce706d5b55d75c779b18a6fb8c6bcc930e4ff27a751f12ad96e5c6c80c92.jpg',1,null),
(rid,c_drinks,'NEGRONI','Campari, gin, vermute rosso e pele de laranja.','R$35,00',Z||'98ce9131caf2913a73fcd378a24381d5716abe10bc597777c16297f8ba4b812c.jpg',2,null),
(rid,c_drinks,'BOULEVARDIER','Campari, bourbon, vermute rosso e pele de laranja.','R$35,00',Z||'98ce9131caf2913a73fcd378a24381d5716abe10bc597777c16297f8ba4b812c.jpg',3,null),
(rid,c_drinks,'Jameson com Chá','Jameson, chá mate e limão.','R$35,00',Z||'1e0fdc76e90ddda3b5cf66dfa4c1a28560627e2d1e8284451875feb59c45fd18.jpg',4,null),
(rid,c_drinks,'Aperol Sour','Aperol, Whiskey bourbon, xarope de açúcar, suco de laranja, limão e aquafaba.','R$35,00',Z||'996ddc1b2c634874cf75b6ed731d6ec64b15ab489cb06fe8a719fffaf0323bc1.jpg',5,null),
(rid,c_drinks,'Aperol Spritz','Aperol, espumante e água com gás.','R$35,00',Z||'38e36db01891b11c9158b5409e6cda3645839337e5ee1d23c633a92c3cf860f8.jpg',6,null),
(rid,c_drinks,'KARIRI MEL E LIMÃO','Kariri (cachaça cearense), com mel e limão.','R$15,00',Z||'bb559cc64745741fdd8279fefc2acfa98a0be4906cd606621328079e975d66c3.jpg',7,'[{"title":"OPÇÕES","type":"add","opts":[{"name":"GELO","price":"Grátis"}]}]'),
(rid,c_drinks,'Mamba Negra','Gin Bombay, limão siciliano, cachaça de gengibre, xarope de toranja e capim santo.','R$35,00',Z||'3849b3c74114dd3ea6a141f3afd3ebc27ee052782eebd9e97100fe01d6758cd1.jpg',8,null),
(rid,c_drinks,'Blood Mary','Vodka e suco de tomate temperada. Acompanha bacon frita (OPCIONAL).','R$36,00',Z||'d3122092a6a30fefd47a6ed2cf7abce89a47297516ae5b6a1606d862dfc5d1f3.jpg',9,'[{"title":"ADICIONAL","type":"add","opts":[{"name":"BACON","price":"Grátis"}]}]'),
(rid,c_drinks,'Moscou Mula?','Vodka, limão, xarope de açúcar, angostura e espuma de gengibre.','R$29,90',Z||'43b66c678bda3c20847c5ca21153eb24ba34a649502c61a33a72ff5fc2bd642a.jpg',10,null),
(rid,c_drinks,'Bombeirinho de Madame','Cachaça, xarope de groselha, limão e essência de groselha.','R$28,00',Z||'4108e82551e42366ed89d9775023234b718b65886d83f6391040e28d1bba2a2b.jpg',11,null),
(rid,c_drinks,'Café Pint com Rum','Bacardi carta ouro, café expresso, tônica, limão e xarope de gengibre.','R$32,00',Z||'fda91fb9ee5db8ea1fb91fcb4eae832d5797d22ed90f6f45bd25f066c48c575c.jpg',12,null),
(rid,c_drinks,'New York Sour','Bourbon, limão siciliano, xarope de açúcar, angostura, aquafaba e vinho.','R$35,00',Z||'1a43636ce1af5279a93ebf589ca763ae948d3382e96dff2751c7322b7befa333.jpg',13,null),
(rid,c_drinks,'Caipirinha Jorge Amado','Cachaça Gabriela, limão e maracujá.','R$34,00',Z||'399a77b48df25901d9dfd54aa9dd1f60d072f289a227837ee3aa184c40cad0ba.jpg',14,null),
(rid,c_drinks,'Old Fashioned','Whisky (bourbon), angostura, açúcar, água com gás.','R$35,00',Z||'3ba8cd34c7a08468233f9aa049bdad3db9fc4a58a5a8f817780dd4e0d2db6241.jpg',15,null),
(rid,c_drinks,'Caipirinha Tradiça','Cachaça, limão e açúcar.','R$30,00',Z||'b73aa7c0dbc497434cf62e261a757027aa1aac68309e62f293fb69eda54112f3.jpg',16,null),
(rid,c_drinks,'Penicillin','Whiskey bourbon, limão siciliano, xarope de mel e gengibre. É foda!','R$35,00',Z||'c9007a69e3393b5c31249e8bc6094887ad0738fede06d5d11b92267f4e3c9797.jpg',17,null),
(rid,c_drinks,'Rabo de Galo','Cachaça Salinas, vermute rosso, Cynar e pele de laranja.','R$20,00',Z||'14668fb6eb53cf29fad496c0e4f38989f112dbbadaffd3748de527b9b3d9bf7d.jpg',18,null),
(rid,c_drinks,'CAMBALHOTA NA DESCIDA','Cachaça de jambu, cachaça de gengibre, cachaça salinas e limão.','R$28,00',Z||'a4d1113ea572335bbaf16ba7a78adfa91016be3dc54f0c7fa942db43732267fb.jpg',19,null),
(rid,c_drinks,'Sweet Manhattan','Bourbon, vermouth rosso e xarope de cereja.','R$35,00',Z||'147e55384d38c9bce2511bbf957c4af3b6e2897659b13d454a28a7923600fa62.jpg',20,null),
(rid,c_drinks,'Campari Tônica','Campari, tônica e laranja.','R$28,00',Z||'d4604dbe1eb4e2b08f9f21bb08bd50cc4431316d2747f37dcd9fd9f9f03d6f88.jpg',21,null),
(rid,c_drinks,'Citrus Martini','Aperol, gin, limão siciliano e xarope de açúcar.','R$32,00',Z||'9d8e25e292d1b0c909b621f7acbcc51177b1064e354bcecd2005fe315dc0bfba.jpg',22,null),
(rid,c_drinks,'Tom Collins','Gin Bombay, limão siciliano, xarope de açúcar, água com gás.','R$35,00',Z||'2a969c2edf94d8afe78746b46fcaaa6b3cce29185ff36bd69fd566b6eecc371e.jpg',23,null),
(rid,c_drinks,'Clover Club','Gin, xarope de framboesa, limão siciliano e aquafaba, borda de pó de hibisco.','R$38,00',Z||'86623e44871d74cfda6bb2e736b2ba471d57da61c49dd278ef6ff839857ece8c.jpg',24,null),
(rid,c_drinks,'Cosmopolitan','Vodka, licor de laranja, limão siciliano, xarope de cranberry e solução salina.','R$35,00',Z||'ba61beec9025653dfdd625792b3aebc79d0cbd80c11101f09aad93337591f0bb.jpg',25,null),
(rid,c_drinks,'Cuba Libre','Bacardi oro, coca-cola e limão.','R$25,00',Z||'b340810a24b38f6421c57f387df51efcd6bafd073e0bc33c27a79bf99ac1e3cd.jpg',26,null),
(rid,c_drinks,'CONHAQUE COM CACAU','O nome já diz.','R$18,00',Z||'f9bab97dbee330a72a559e743a275172cb92cf683848e1ef0bd036e3368bcec2.jpg',27,null),
(rid,c_drinks,'Dry Martini','Gin e Vermouth Branco.','R$35,00',Z||'82b5c010c7c1e29930a8442b587e466d824926ba11e61cd62f7cb39fbc1d5799.jpg',28,null),
(rid,c_drinks,'Espresso Martini','Vodka, café expresso, xarope de açúcar e grãos de café.','R$35,00',Z||'1d7ac9f91007603b973fabf41ad92fb3d46f488fe91070c67942611fdbff7914.jpg',29,null),
(rid,c_drinks,'Fitzgerald','Gin Tanqueray, limão siciliano, angostura e pele de limão.','R$35,00',Z||'b9ab2282a7625e61cc8c85549e8c65bc4b30dad4f35d1fc03930edc607b5b230.jpg',30,null),
(rid,c_drinks,'Gengibrite','Cachaça de gengibre, suco de limão siciliano e água com gás.','R$25,00',Z||'fb985fb24386b177bb01c6d900936e69e5ff43c99175a5b5e5d55cd57256f06a.jpg',31,null),
(rid,c_drinks,'Gin Tônica','Gin Bombay, tônica e limão.','R$35,00',Z||'e3f964e00e9b9b294c4731b0b02f44fa4bc733c1f010241c66bfa0d37b759bfd.jpg',32,null),
(rid,c_drinks,'Golden Shower','Cachaça de gengibre, cachaça salinas, limão e espuma de gengibre.','R$35,00',Z||'9b4a6414adfd2c7284cd5f85b7690098fab3a72848957bd0f382fc697b461b6a.jpg',33,null),
(rid,c_drinks,'Irish Mule','Jameson, limão, xarope de açúcar, angostura e espuma de gengibre.','R$35,00',Z||'43b66c678bda3c20847c5ca21153eb24ba34a649502c61a33a72ff5fc2bd642a.jpg',34,null),
(rid,c_drinks,'Jack & Coke','Jack Daniel''s e Coca-Cola.','R$35,00',Z||'b340810a24b38f6421c57f387df51efcd6bafd073e0bc33c27a79bf99ac1e3cd.jpg',35,null),
(rid,c_drinks,'Jagerbomb','Jägermeister com Red Bull.','R$35,00',Z||'3663f96c732cebb1ee4f89ccb30a7ca315279af6abf4abab3c3ae9a16a2ee8cf.jpg',36,null);

-- ── RANGO ──
insert into products (restaurant_id,category_id,name,description,price,price_prefix,image_url,sort_order,allergens,extras) values
(rid,c_rango,'LANCHE DE PERNIL','Pernil desfiado moiadinho e queijo prato no pão francês.','R$28,00','A partir de',Z||'f4aff81d63dc878d2beb5004701a4b47d1b1a9f8085b3e9fb4ca6f72bb46706a.jpg',1,'{"glúten","leite"}','[{"title":"ADICIONAIS","type":"add","opts":[{"name":"BATATA SIDE","price":"+R$10,00"}]}]'),
(rid,c_rango,'QUEIJO CRENTE (camembert)','Fogazza recheada com 150g de queijo camembert, compota de tomate e folhas verdes.','R$64,90','',Z||'99416da8ecdd0641a0b1b4a4e335688ef7b16801985b5bcfb0b8803e7f0a7f00.jpg',2,'{"leite"}',null),
(rid,c_rango,'X BURGER','Pão, hambúrguer bovino 150g, queijo prato e maionese da casa.','R$37,90','A partir de',ZF||'ea532951e7e19ae145e8f3c9897058da1254a8e8e66ace17b5354daa3e6b66f9.jpg',3,'{"glúten","ovo","leite"}','[{"title":"ADICIONAIS","type":"add","opts":[{"name":"BACON","price":"+R$7,00"},{"name":"BATATA CRINKLE (SIDE 100G)","price":"+R$10,00"},{"name":"HAMBURGUER EXTRA","price":"+R$10,00"},{"name":"QUEIJO EXTRA","price":"+R$7,00"},{"name":"SALADA","price":"+R$7,00"},{"name":"PICLES","price":"+R$3,00"}]}]'),
(rid,c_rango,'BOLOVO DE CARNE','Carne envolvendo ovo com gema mole.','R$28,00','A partir de',Z||'e2acec3f49bfbeaa52924abc90364da22a6e0d101f2bcac874da9ed2f3b3cbbf.jpg',4,'{"ovo"}','[{"title":"ADICIONAL","type":"add","opts":[{"name":"MAIONESE EXTRA","price":"+R$5,00"}]}]'),
(rid,c_rango,'BOLOVO À PARMEGIANA','Bolovo com compota de tomate, queijo gratinado, focaccia na manteiga de alho.','R$47,00','',Z||'5f07e785a054b638180b8c7f0c132f028dd95c980a582491a01ba563d8dac59a.jpg',5,'{"glúten","leite"}',null),
(rid,c_rango,'CHORIPAN','Pão francês, hambúrguer de linguiça toscana 150g e molho chimichurri.','R$28,00','A partir de',Z||'724f1a0bb6da98ef065a975b527e3798db0653e4ce1ce07c0bcc743499e8d992.jpg',6,'{"glúten"}','[{"title":"ADICIONAIS","type":"add","opts":[{"name":"QUEIJO","price":"+R$7,00"},{"name":"BATATA SIDE","price":"+R$10,00"}]}]'),
(rid,c_rango,'FALAFEL','Pão australiano, hambúrguer de falafel 150g, queijo prato, tomate, pepino, rúcula e homus.','R$35,00','A partir de',Z||'73045f4d918191f1bd133ed0ea5f5371f2e3a34151363bfea9245d541a8d63fe.jpg',7,'{"glúten","leite"}','[{"title":"ADICIONAIS","type":"add","opts":[{"name":"BACON","price":"+R$7,00"},{"name":"BATATA SIDE","price":"+R$10,00"},{"name":"QUEIJO EXTRA","price":"+R$7,00"},{"name":"HAMBURGUER EXTRA","price":"Grátis"}]}]'),
(rid,c_rango,'GALINHO XIKILIRO','Sobrecoxa de frango empanada, com molho barbecue artesanal. Valor com desconto.','R$33,60','A partir de',Z||'0ebd79b215b3e7185ec6652d54297646e61e28665a7150eeb949291a7eab21c8.jpg',8,'{}','[{"title":"ADICIONAIS","type":"add","opts":[{"name":"BACON","price":"+R$7,00"},{"name":"QUEIJO EXTRA","price":"+R$7,00"},{"name":"BATATA SIDE","price":"+R$10,00"}]}]');

-- ── VEGANO ──
insert into products (restaurant_id,category_id,name,description,price,image_url,sort_order,tags) values
(rid,c_vegano,'(VEGANO) Falafel','Pão frances, hambúrguer de falafel 150g, tomate, pepino, cebola roxa, rúcula e homus.','R$35,00',Z||'1ee18a16c214892ad8c6234e7285a24a5aad2ed31d5419217e7576eef4cf4778.jpg',1,'{"vegano"}');

-- ── PORÇÕES ──
insert into products (restaurant_id,category_id,name,description,price,price_prefix,image_url,sort_order,extras) values
(rid,c_porcoes,'BATATA FRITA','Batata frita, temperada com páprica defumada e lemon pepper (aprox. 350g).','R$30,00','A partir de',Z||'819ba1fdef9e524ea0ff022443a52a491b6dc6e30f7c5015e4f7d6540f46f459.jpg',1,'[{"title":"ADICIONAIS","type":"add","opts":[{"name":"AMERICAN CHEESE","price":"+R$12,00"},{"name":"BARBECUE","price":"+R$5,00"},{"name":"MAIONESE EXTRA","price":"+R$5,00"}]}]'),
(rid,c_porcoes,'CHILI FRIES','Batata crinkle crocante coberta com molho chili picante e creme cheddar.','R$53,90','A partir de',Z||'305cfc8779329cfbccf605a1aeae397fd72948c819f473ece6c62ab35e2c6da9.jpg',2,'[{"title":"OPÇÕES","type":"add","opts":[{"name":"CHILI À PARTE","price":"Grátis"},{"name":"SOUR CREAM","price":"+R$5,00"}]}]'),
(rid,c_porcoes,'GUIOZA SUINO','Guioza de carne de porco frito, acompanha molho shoyo. (10 unidades)','R$39,90','',Z||'6bd562213208b84eee354ec54d1e95f152678c010413c44dda5a715c771ed17d.jpg',3,null),
(rid,c_porcoes,'ARANCINI DE CALABRESA','Arancini de calabresa com parmesão. [4 unidades]','R$44,90','',ZF||'6041d7af90ba6e0de6a99a9c08dd0f101a6c71d7ead94b193c605dcdc3a20620.jpg',4,null);

-- ── SOBREMESA ──
insert into products (restaurant_id,category_id,name,description,price,image_url,sort_order) values
(rid,c_sobremesa,'TEQUENO DE DOCE DE LEITE','Barrinha de doce leite envolta de massa de pão frito, com açúcar e canela.','R$30,00',ZF||'770c68def44d54044ccf155c1c99a0aee05c22c4d93b5d149a9914b488950540.jpg',1);

-- ── SEM ÁLCOOL ──
insert into products (restaurant_id,category_id,name,description,price,price_prefix,image_url,sort_order,extras) values
(rid,c_sem,'Soda Italiana','Xarope de frutas e água com gás. Escolha o sabor.','R$15,00','A partir de',Z||'8129521eb3269a30cc5aeb185dd9dc825e84ac2fcf477fa7c77a07ed58f00a71.jpg',1,'[{"title":"SABORES","type":"select","opts":[{"name":"GENGIBRE"},{"name":"MORANGO"},{"name":"GROSELHA"},{"name":"MELANCIA"},{"name":"ROMÃ"},{"name":"MAÇÃ VERDE"},{"name":"FRAMBOESA"},{"name":"TANGERINA"}]}]'),
(rid,c_sem,'Chá Puro Verde','Mate orgânico, gaseificado, adoçado com suco de maçã.','R$15,00','',Z||'10fe4a5a441f52f62bfd6f1da4880737af32a0d8d61a943bb60c0ccda5fdafee.jpg',2,null),
(rid,c_sem,'Café / Espresso','De máquina.','R$8,00','',Z||'7981c30d9dc66f62dd4ad5db0f63a67915219ae2b048ba7dfd4a4dfd4dff3d4e.jpg',3,null),
(rid,c_sem,'Café Pint (sem álcool)','Café expresso, tônica, limão e xarope de gengibre.','R$25,00','',Z||'58cbaf96f44325f3b0b67586d1ad05b7e024f3e8c4640cf3f4a4618f60499fd1.jpg',4,null),
(rid,c_sem,'Tônica Antártica Lata','—','R$8,00','',Z||'d79fc820f83f11ba8fe5dd2e21de3518bd4b5aa590bc41b860ac9df1314f4e91.jpg',5,null),
(rid,c_sem,'RedBull 250ml','—','R$20,00','',Z||'59eba4616f7e8eff7690f36235555b836f50a565473c6a355cb9cacd7e87f6e1.jpg',6,null),
(rid,c_sem,'Água com Gás 500ml','—','R$7,00','',Z||'552d0439013bf86db290459ef5dac66a9ba6f688a07cdaaf0811f376b812440f.jpg',7,null),
(rid,c_sem,'Água sem Gás 500ml','—','R$6,00','',Z||'793e644bf821b3a020cda88714c666de8c59d72134d119dd85c921033760a01a.jpg',8,null),
(rid,c_sem,'Coca Cola','—','R$8,00','',Z||'c0d14bc206e3153898c75e6e3d10f48b977029bf70064292cf6f13a65c952ffb.jpg',9,null),
(rid,c_sem,'Coca Zero','—','R$8,00','',Z||'8bcd1b1310092ed614189d444cc5cd5e3db1dc88a9f58dbe235b269aeb20157d.jpg',10,null),
(rid,c_sem,'CORONA ZERO LATA (350ml)','—','R$15,00','',Z||'8d0231af087d0d07ce3a53c60499bff4259d924902363551aac5a1b15d3981c0.jpg',11,null);

-- ── DESTILADOS ──
insert into products (restaurant_id,category_id,name,description,price,image_url,sort_order,extras) values
(rid,c_destilados,'Jack Daniels','Classic bourbon whiskey.','R$35,00',Z||'8b57c02c3c1c824e43d9dd5eedc144b2db6981fc7500704640d5d7970960b212.jpg',1,null),
(rid,c_destilados,'Jameson','Irish classic whiskey.','R$28,00',Z||'0034038f2a56cab272c4cd153272676cfeb3a438f50a2d195d55b5ac7b8637a7.jpg',2,null),
(rid,c_destilados,'Jim Beam','Classic bourbon whiskey.','R$32,00',Z||'a0c85ac24c5b0bcf5ef92e86fb89ef07eeeb9274953fa114ac88ed3d2697d4e5.jpg',3,null),
(rid,c_destilados,'Woodford Reserve','Bourbon premium whiskey.','R$49,90',Z||'49818293a7d082e11a3dea923f175358719aa0ed61cc2448a9bb92c448c98041.jpg',4,null),
(rid,c_destilados,'Fireball','Whisky com canela.','R$25,00',Z||'c59d7096377291a9dc07913502a85ba260cd73a530981f1ec98846bae3666afb.jpg',5,null),
(rid,c_destilados,'Jagermeister','—','R$28,00',Z||'b03a9c661ff8c09adf9a8a61eda3526894ade509bd44fb5e5599ca586ca0669e.jpg',6,null),
(rid,c_destilados,'Conhaque Domecq','—','R$15,00',Z||'f9bab97dbee330a72a559e743a275172cb92cf683848e1ef0bd036e3368bcec2.jpg',7,null),
(rid,c_destilados,'Tequila','—','R$25,00',Z||'52da624f85e8d77e5635f30a05f98b836eb1e1277fad3124ef0eeb073caf024d.jpg',8,null),
(rid,c_destilados,'Campari','—','R$20,00',Z||'2d6233b70e5f1a260c0c6fd293cb218e8168862dd06a3f8871b1cd94df5aab64.jpg',9,null),
(rid,c_destilados,'Rum Bacardi','Ouro ou prata.','R$20,00',Z||'48e2b2d4a8a83eaf3b763a6c24c87911d77fd9d5d06811447d5f18bf7a597c02.jpg',10,null),
(rid,c_destilados,'Vodka Smirnoff','—','R$18,00',Z||'810e11f0fde1428f19d88131bba4c76f34e6588ed03ce9be669fe0d1ea4d0b07.jpg',11,null),
(rid,c_destilados,'CACHAÇAS ARTESANAIS','Diversas opções artesanais. Escolha a marca.','R$15,00',ZF||'8295d3cfe3d8d0161244f271ef15f373a38ed501db42a6bf235a3823b436bdec.jpg',12,'[{"title":"MARCAS","type":"select","opts":[{"name":"GENGIBRE"},{"name":"TRÊS CORONÉIS"},{"name":"SALINAS UMBURANA (MG)"},{"name":"GABRIELA (SP)"},{"name":"SAGATIBA"},{"name":"CARIBÉ (MG)"},{"name":"JOÃO MENDES"}]}]');

-- ── VINHOS ──
insert into products (restaurant_id,category_id,name,description,price,price_prefix,image_url,sort_order,extras) values
(rid,c_vinhos,'Rolha (taxa)','—','R$50,00','',Z||'2811649ff7fc8feb2deffbf4075c4eef5ce07d84ac1b8fd0a64a6fc898bfb2a5.jpg',1,null),
(rid,c_vinhos,'Vinho Tinto Taça (150ml)','Vinícola Miolo, blend Cabernet Sauvignon com Merlot.','R$20,00','',Z||'76e4fc4b05c7f540aaf3b4b5d16ba871dcda3ad9483f0b8619522de5992f76fc.jpg',2,null),
(rid,c_vinhos,'RESERVADO CONCHA Y TORO 750ml','Cabernet-Sauvignon, Malbec, Carménère e Merlot. Consulte disponibilidade.','R$66,00','A partir de',ZF||'f69359ea0ab7761f257c7209c9ca8317c8514a3c14a4d556748712e37bd7e20a.png',3,'[{"title":"VARIEDADE","type":"select","opts":[{"name":"CARMÉNÈRE"},{"name":"TAÇA"}]}]'),
(rid,c_vinhos,'PORTA 6 (português)','—','R$110,00','',ZF||'307936bc07f4e5368bf7d784f3720b3c85bc3aca5de14a184fe0454433d4f5dd.jpg',4,null),
(rid,c_vinhos,'A FLORISTA (português)','—','R$100,00','A partir de',ZF||'e478fcba72ed501c16f7177e0e25766d4a90e6118797dc1c4271d7b36dc86cd5.jpg',5,'[{"title":"ADICIONAL","type":"add","opts":[{"name":"TAÇA","price":"Consulte"}]}]'),
(rid,c_vinhos,'CASILLERO DEL DIABLO (chileno)','—','R$100,00','A partir de',ZF||'3e3b0979e9a1090bc6d5590642dc44e24edcf20a58e8227ec7557c805edf3587.jpg',6,'[{"title":"VARIEDADE","type":"select","opts":[{"name":"CABERNET SAUVIGNON"},{"name":"CARMÉNÈRE"}]}]'),
(rid,c_vinhos,'SUSPEITO ROSÉ (750ml)','100% Merlot do RS. Perfil aromático frutal com notas florais.','R$99,90','',ZF||'149cdd1ee6038f6b24ae87c6a37fcdbfaa83690bc5e12c6ca53c47f26a909d36.jpg',7,null),
(rid,c_vinhos,'SUSPEITO TINTO (750ml)','Cabernet Sauvignon, Tannat e Moscato.','R$99,90','',ZF||'582356014247f44b3a52bb2c09c7345b99cc1a0b545c976baf9bc01888a3fea0.jpg',8,null),
(rid,c_vinhos,'SUSPEITO BRANCO (750ml)','100% Chardonnay do RS.','R$99,90','',ZF||'eec9497cab38c4285c40ec98c42646eefd64d46b403e2b3101a27c722cde5949.jpg',9,null),
(rid,c_vinhos,'TAÇA DE VINHO SUSPEITO','Escolha o tipo: Tinto, Rosé ou Branco.','R$25,00','A partir de',ZF||'bc86c636ad69b6df60689c2c7b8f10d9a91e7dcd67d4355414ad9693e5084efb.jpg',10,'[{"title":"TIPO","type":"select","opts":[{"name":"VINHO TINTO"},{"name":"VINHO ROSÉ"},{"name":"VINHO BRANCO"}]}]');

raise notice 'Migração concluída: 1 restaurante, 12 categorias, ~103 produtos.';
end $$;
