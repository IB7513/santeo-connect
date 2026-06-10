'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "cf80fa3fd3346d6f43d390419aa49e46",
"index.html": "df3f8d7eb6c66f3e56704c8baf82e59f",
"/": "df3f8d7eb6c66f3e56704c8baf82e59f",
"main.dart.js": "8d21da243a4aa53a53ad4b411c1ecf05",
"version.json": "6f6dbe57f71d048c19be125e4db75e56",
"assets/assets/images/santeo_logo.png": "a91f1f12feb96c8150c6d31caff6b470",
"assets/assets/logo/santeo_logo.png": "a91f1f12feb96c8150c6d31caff6b470",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/fonts/MaterialIcons-Regular.otf": "76044a8ba9aaa618552472028f9c07f1",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.json": "ba09f2e8918b7fccc9d771c6cfb31f6b",
"assets/AssetManifest.bin": "8f776577bd6f9f5ff32f323312027869",
"assets/AssetManifest.bin.json": "e9f38b5aaed23a37d7c7d7bbb88a7fc1",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/NOTICES": "a8989ca2517b9f0f66ecc05e2c6e9672",
"favicon.png": "27b14caa62f2b80e595f7ad20af4e4a2",
"icons/Icon-192.png": "6df5ccb56f9e0692c58ea306c15c1ed7",
"icons/Icon-512.png": "394c593b6973eeead68023752e0fcd73",
"icons/Icon-maskable-192.png": "56911c06652682df1c4122f8a050f4e8",
"icons/Icon-maskable-512.png": "72ea8e83ca59eb5b5a7f816c068db64a",
"icons/apple-touch-icon-120.png": "533e3aed57947df40a1a0dbd06d6385e",
"icons/apple-touch-icon-152.png": "4157a6484d0715f0a21a5a7b72586ee1",
"icons/apple-touch-icon-167.png": "66223be6fe85f00b0c8ef558a03cc6dd",
"icons/apple-touch-icon-180.png": "e373152971239620cafb05f9ce0f3dca",
"icons/apple-touch-icon.png": "e373152971239620cafb05f9ce0f3dca",
"icons/favicon-16.png": "6538844ce4529cf599c924293063881e",
"icons/favicon-32.png": "27b14caa62f2b80e595f7ad20af4e4a2",
"icons/santeo_icon_1024.png": "436a8e4a7503d7654cc9e53789bf44a0",
"icons/splash_portrait.png": "17fd4e311755c6e719f2ea633bb1efaa",
"manifest.json": "a5fbed734c0ccda7acf92ece51c83805",
"splash/apple-splash-1080-1920.png": "eec1ece15b28564453e8dbbd069533cb",
"splash/apple-splash-1125-2436.png": "80cf66bb7f374c1fa7b47918031d5e56",
"splash/apple-splash-1170-2532.png": "0a99874b6279181fa06b4146f0f1381b",
"splash/apple-splash-1179-2556.png": "e61c9d76369f5f7f14dc05ca94311ec5",
"splash/apple-splash-1290-2796.png": "7a284bae99ce369ffcbf6ce8dd69edf5",
"splash/apple-splash-1536-2048.png": "c8fbab2be768fffc88068a73cee611f4",
"splash/apple-splash-1668-2388.png": "34d4f1dab79fb147add50defe20e45ac",
"splash/apple-splash-2048-2732.png": "1813d5b62756e6f0530ab8ba15f6c3b4",
"splash/apple-splash-640-1136.png": "c799efb53ab3ce14552af191cfb297ca",
"splash/apple-splash-750-1334.png": "18362d14171070195a11a64268c775e6",
"videos/baby_stretch.mp4": "a3a760e90dc0b784526e865d4d4998cf"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
