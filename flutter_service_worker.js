// Service worker auto-destructeur
// Force la suppression du cache et se désenregistre immédiatement
self.addEventListener('install', function(e) {
  self.skipWaiting();
});

self.addEventListener('activate', function(e) {
  e.waitUntil(
    caches.keys().then(function(keys) {
      return Promise.all(keys.map(function(k) {
        return caches.delete(k);
      }));
    }).then(function() {
      return self.registration.unregister();
    }).then(function() {
      return self.clients.matchAll();
    }).then(function(clients) {
      clients.forEach(function(c) { c.navigate(c.url); });
    })
  );
});

self.addEventListener('fetch', function(e) {
  // Passer toutes les requêtes directement au réseau — pas de cache
  e.respondWith(fetch(e.request));
});
