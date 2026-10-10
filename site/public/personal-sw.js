const CACHE = 'keepline-personal-v1';
self.addEventListener('install', event => event.waitUntil((async () => {
  const cache = await caches.open(CACHE);
  const response = await fetch('/personal.html', { cache: 'reload' });
  if (!response.ok) throw new Error('Personal editor unavailable');
  const html = await response.clone().text();
  const assets = [...html.matchAll(/(?:src|href)="([^"\s]+\.(?:js|css))"/g)].map(match => match[1]);
  await cache.put('/personal.html', response);
  await cache.addAll([...assets, '/fonts/newsreader-latin.woff2', '/icon.svg', '/app-icon.png', '/personal.webmanifest']);
  await self.skipWaiting();
})()));
self.addEventListener('activate', event => event.waitUntil((async () => { for (const name of await caches.keys()) if (name.startsWith('keepline-personal-') && name !== CACHE) await caches.delete(name); await self.clients.claim(); })()));
self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);
  if (url.origin !== self.location.origin || event.request.method !== 'GET') return;
  if (!(url.pathname === '/personal.html' || url.pathname.startsWith('/assets/') || url.pathname.startsWith('/fonts/') || ['/icon.svg', '/app-icon.png', '/personal.webmanifest'].includes(url.pathname))) return;
  event.respondWith((async () => { const cache = await caches.open(CACHE); try { const response = await fetch(event.request); if (response.ok) await cache.put(event.request, response.clone()); return response; } catch { const saved = await cache.match(event.request, { ignoreSearch: url.pathname === '/personal.html', ignoreVary: true }); return saved || Response.error(); } })());
});
