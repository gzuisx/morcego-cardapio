const CACHE = 'mocergo-v2';
// Só cacheia assets estáticos (fontes, imagens CDN) — nunca HTML
const ASSET_ORIGINS = ['fonts.googleapis.com','fonts.gstatic.com','zig-public.zig.fun','zig-public-files.zig.fun'];

self.addEventListener('install', e => {
  self.skipWaiting();
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;

  const url = new URL(e.request.url);

  // Assets externos (fontes, imagens CDN) → cache-first
  if (ASSET_ORIGINS.some(o => url.hostname.includes(o))) {
    e.respondWith(
      caches.open(CACHE).then(c =>
        c.match(e.request).then(cached =>
          cached || fetch(e.request).then(res => {
            if (res.ok) c.put(e.request, res.clone());
            return res;
          })
        )
      )
    );
    return;
  }

  // HTML e tudo mais → network-first (sempre pega versão nova)
  e.respondWith(
    fetch(e.request).catch(() => caches.match(e.request))
  );
});
