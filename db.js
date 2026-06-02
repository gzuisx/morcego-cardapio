// db.js — Supabase client compartilhado (index, admin, cozinha)
const SUPABASE_URL = 'https://furylkbhumckstiowshu.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ1cnlsa2JodW1ja3N0aW93c2h1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzNTEwNDcsImV4cCI6MjA5NTkyNzA0N30.5QUt2XcEbH6-VppjxnsrUWunj19L9Ds8c3DRz7Kt76U';

let _sb = null;
function getSB(){
  if(!_sb) _sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
  return _sb;
}

// ══ ORDERS ══
async function sbGetOrders(){
  const {data} = await getSB().from('morcego_orders').select('*').order('created_at',{ascending:false});
  return (data||[]).map(r=>({
    id:r.id, table:r.table_number, items:r.items,
    status:r.status, timestamp:r.created_at
  }));
}
async function sbInsertOrder(order){
  const {data,error} = await getSB().from('morcego_orders').insert({
    id:order.id, table_number:order.table,
    items:order.items, status:order.status||'new',
    created_at:order.timestamp
  }).select();
  if(error) console.error('sbInsertOrder',error);
  return data;
}
async function sbUpdateOrder(id, status){
  const {data,error} = await getSB().from('morcego_orders')
    .update({status, updated_at:new Date().toISOString()}).eq('id',id).select();
  if(error) console.error('sbUpdateOrder',error);
  return data;
}

// ══ CALLS ══
async function sbGetCalls(){
  const {data} = await getSB().from('morcego_calls').select('*').order('created_at',{ascending:false});
  return (data||[]).map(r=>({
    id:r.id, table:r.table_number, type:r.type,
    status:r.status, timestamp:r.created_at
  }));
}
async function sbInsertCall(call){
  const {data,error} = await getSB().from('morcego_calls').insert({
    id:call.id, table_number:call.table,
    type:call.type, status:'pending'
  }).select();
  if(error) console.error('sbInsertCall',error);
  return data;
}
async function sbResolveCall(id){
  const {data} = await getSB().from('morcego_calls').update({status:'resolved'}).eq('id',id).select();
  return data;
}

// ══ REACTIONS ══
async function sbGetReactions(){
  const {data} = await getSB().from('morcego_reactions').select('*');
  const result={};
  (data||[]).forEach(r=>{result[r.product_id]={fire:r.fire,heart:r.heart,meh:r.meh};});
  return result;
}
async function sbSaveReaction(productId, emoji){
  const sb=getSB();
  const {data:existing} = await sb.from('morcego_reactions').select('*').eq('product_id',productId).maybeSingle();
  const cur = existing||{fire:0,heart:0,meh:0};
  cur[emoji]=(cur[emoji]||0)+1;
  await sb.from('morcego_reactions').upsert({product_id:productId,fire:cur.fire,heart:cur.heart,meh:cur.meh});
  return cur;
}

// ══ SETTINGS ══
async function sbGetSettings(){
  const {data} = await getSB().from('morcego_settings').select('*').eq('id',1).maybeSingle();
  if(!data) return {};
  return {
    waitTime: data.wait_time,
    tableModeEnabled: data.table_mode_enabled,
    nightlyHighlight: data.nightly_highlight||{},
    adminPassword: data.admin_password||'morcego2024'
  };
}
async function sbSaveSettings(s){
  await getSB().from('morcego_settings').upsert({
    id:1,
    wait_time: s.waitTime||null,
    table_mode_enabled: !!s.tableModeEnabled,
    nightly_highlight: s.nightlyHighlight||{},
    admin_password: s.adminPassword||'morcego2024',
    updated_at: new Date().toISOString()
  });
}

// ══ RESTAURANT / CATEGORIES / PRODUCTS ══
let _restaurantId = null;

async function sbGetRestaurantId(slug='morcego'){
  if(_restaurantId) return _restaurantId;
  const {data} = await getSB().from('restaurants').select('id').eq('slug',slug).single();
  _restaurantId = data?.id || null;
  return _restaurantId;
}

async function sbGetCategories(){
  const rid = await sbGetRestaurantId();
  if(!rid) return [];
  const {data} = await getSB().from('categories')
    .select('*').eq('restaurant_id',rid).eq('visible',true).order('sort_order');
  return data||[];
}

async function sbGetProducts(includeUnavailable=false){
  const rid = await sbGetRestaurantId();
  if(!rid) return [];
  let q = getSB().from('products').select('*').eq('restaurant_id',rid).order('sort_order');
  if(!includeUnavailable) q = q.eq('available',true);
  const {data} = await q;
  return data||[];
}

async function sbUpdateProduct(id, fields){
  const {data,error} = await getSB().from('products')
    .update({...fields, updated_at: new Date().toISOString()}).eq('id',id).select();
  if(error) console.error('sbUpdateProduct',error);
  return data?.[0];
}

async function sbInsertProduct(p){
  const rid = await sbGetRestaurantId();
  const {data,error} = await getSB().from('products').insert({
    restaurant_id: rid,
    category_id: p.catId,
    name: p.name, description: p.desc||'',
    price: p.price||'', price_prefix: p.prefix||'',
    image_url: p.img||'', calories: p.calories||null,
    allergens: p.allergens||[], tags: p.tags||[],
    available: true, extras: p.extras||null
  }).select();
  if(error) console.error('sbInsertProduct',error);
  return data?.[0];
}

async function sbDeleteProduct(id){
  const {error} = await getSB().from('products').delete().eq('id',id);
  if(error) console.error('sbDeleteProduct',error);
}

// ══ REALTIME ══
function sbOnNewOrder(callback){
  return getSB().channel('rt-orders')
    .on('postgres_changes',{event:'INSERT',schema:'public',table:'morcego_orders'},payload=>{
      const r=payload.new;
      callback({id:r.id,table:r.table_number,items:r.items,status:r.status,timestamp:r.created_at});
    })
    .on('postgres_changes',{event:'UPDATE',schema:'public',table:'morcego_orders'},payload=>{
      callback(null, payload.new); // second arg = update event
    })
    .subscribe();
}
function sbOnNewCall(callback){
  return getSB().channel('rt-calls')
    .on('postgres_changes',{event:'INSERT',schema:'public',table:'morcego_calls'},payload=>{
      const r=payload.new;
      callback({id:r.id,table:r.table_number,type:r.type,status:r.status,timestamp:r.created_at});
    })
    .subscribe();
}
