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
"flutter_bootstrap.js": "7af6e4a556ad62fc5230b7c3ba466fdf",
"index.html": "10116e67cac497302042f880251337c9",
"/": "10116e67cac497302042f880251337c9",
"main.dart.js": "04b5621ee0644d6b74c324c831f5876a",
"version.json": "6f6dbe57f71d048c19be125e4db75e56",
"assets/assets/images/santeo_logo.png": "a91f1f12feb96c8150c6d31caff6b470",
"assets/assets/logo/santeo_logo.png": "a91f1f12feb96c8150c6d31caff6b470",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/fonts/MaterialIcons-Regular.otf": "74e94714c4d7d4cbd402b2da25669de1",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.json": "ba09f2e8918b7fccc9d771c6cfb31f6b",
"assets/AssetManifest.bin": "8f776577bd6f9f5ff32f323312027869",
"assets/AssetManifest.bin.json": "e9f38b5aaed23a37d7c7d7bbb88a7fc1",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/NOTICES": "f43e157c8310d59fc26eba8039d8a6ef",
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
"videos/baby_stretch.mp4": "a3a760e90dc0b784526e865d4d4998cf",
"test_tts.html": "bfaf2eb0047323623ed777cbc0cc0b03",
"tts_debug.html": "a1a8ee57a05935c93d27b8814f0abda0",
"tts_test_simple.html": "485aab6506eaea0f8f6c57e6b9416791",
"audio_test.html": "67d0665b55a1a044b4fdf4268fbb300c",
"audio/baby_stretch_intro.mp3": "9d033352526ca5e344a986ca4fa8c222",
"audio/bird_dog_fin.mp3": "e36f97b4833736f901bcafd5e0e24c6f",
"audio/baby_stretch_fin.mp3": "18f98b96121cfd497cd88156956a5492",
"audio/auto_embrassade_fin.mp3": "ee17ffb526767ae725645ce8a3d24b68",
"audio/cat_cow_fin.mp3": "215155256cde36815844d47642632e19",
"audio/dead_bug_fin.mp3": "3eab2557a81c4f3e6285cdc9a9c0a38f",
"audio/brasse_bras_intro.mp3": "c5ab51b10d17d29d52a8e0496fb3833b",
"audio/crossed_legs_forward_fold_intro.mp3": "4c0fb4cba6780bec186728a82731a322",
"audio/abdos_4_temps_fin.mp3": "f87671b718860f72341535cbd69d5178",
"audio/bird_dog_intro.mp3": "fba5ab65aef46246f22917e6c5d241ed",
"audio/child_pose_cobra_fin.mp3": "7d3ec94edd13b19f83c490d861d7c072",
"audio/abdos_4_temps_intro.mp3": "1d37e6d5d9ae081325fca4c4bb58aea5",
"audio/crossed_legs_forward_fold_fin.mp3": "4fad6aa8a2c0f2b291582bcb2c367edb",
"audio/auto_embrassade_intro.mp3": "72c17560f08efab74787fe98e20eb128",
"audio/child_pose_cobra_intro.mp3": "95adc57da756a9ca2190a660dc3e179a",
"audio/dead_bug_intro.mp3": "b2d1188cbc49a40d970e5a9b2fa531bf",
"audio/cat_cow_intro.mp3": "06e3fd7c555b892a0d81a5d548c9d1a7",
"audio/brasse_bras_fin.mp3": "eb91c9f182d84f8cd393fddfa6460d78",
"audio/abdos_2_temps_intro.mp3": "d757306d9fb0685626f07bbbe341a723",
"audio/abdos_2_temps_fin.mp3": "1ded6d203681c9f42a959a619cce2947",
"audio/seated_forward_fold_intro.mp3": "987ac2f45d4cd95aeb2c97a4a0a4366d",
"audio/hip_hinge_fin.mp3": "0bbdf54b5de55148e8bbf5e18811d82c",
"audio/gainage_crunch_fin.mp3": "53a47c80570f006150471999040815d9",
"audio/down_dog_intro.mp3": "d7f26609de7018e8fe0a78b31c72898c",
"audio/gainage_crunch_intro.mp3": "55398e4aaf08e91897a7c7ca522c8c24",
"audio/gainage_lateral_genoux_intro.mp3": "df20b2e15c26e0e44c1f7d0ca99377a1",
"audio/touch_sky_forward_fold_fin.mp3": "56a4f4ade11b5502906c04a86674b182",
"audio/seated_pigeon_stretch_intro.mp3": "34a0836eecbecd946915753035842ec7",
"audio/planche_haute_intro.mp3": "7296d6dac33089574b2ee19fe23220a0",
"audio/extension_hanche_fin.mp3": "c1e9b1dbdeb6d020288eb95cc126421a",
"audio/standing_posterior_pelvic_tilt_fin.mp3": "855143781e060dd52576032b131cdb25",
"audio/mountain_climber_intro.mp3": "92300711d353c29d9dc26b3104e954aa",
"audio/seated_cat_cow_fin.mp3": "78c3083342418d490f0cb8d1c5044295",
"audio/extension_lombaire_intro.mp3": "4dc1df75ef504bcb95279247112cf2e0",
"audio/seated_forward_fold_split_fin.mp3": "28ace4cdd90b7616bb71d7466e4fc87e",
"audio/touch_sky_forward_fold_intro.mp3": "fa37f636e58644c9ca727fe4ff8a6db5",
"audio/gainage_lateral_jambes_intro.mp3": "3552b6125c0bb9785323ec9b104b2c28",
"audio/trapezes_superieurs_fin.mp3": "7e15bad0bf979aba402010f930d5f177",
"audio/down_dog_fin.mp3": "f0a89f1767e3a0033cbf59992ed054a8",
"audio/elevateur_scapula_fin.mp3": "b8c90239c3cb68286bffd60b4131eb88",
"audio/fort_double_stretch_fin.mp3": "d4d49eabfbc1054d7d2489610c741bbf",
"audio/gainage_lateral_jambes_fin.mp3": "fdb17a3249032bc0785853f88c5517b5",
"audio/scorpion_stretch_fin.mp3": "c28be198d5bcda3c19e00d566b66dd32",
"audio/split_unilateral_intro.mp3": "fb319254c7ab2e2454aa9e9e9077f410",
"audio/extension_hanche_intro.mp3": "f427a14fcb16fa8eba50073af21617a8",
"audio/fort_double_stretch_intro.mp3": "bb21e89fdfbe63ea190e19b26e9a5dd1",
"audio/scorpion_stretch_intro.mp3": "f07b7824f9741011dd29c81f14b30b51",
"audio/trapezes_superieurs_intro.mp3": "072490b51374983c0831c0ac50268fb4",
"audio/hip_hinge_intro.mp3": "527b3241b4d7cb18924a984c56ad9ee3",
"audio/flechisseurs_doigts_fin.mp3": "beb114b0208567246d39b33478c4f710",
"audio/paravertebraux_intro.mp3": "adb80debe755ee1881fb7a75089d5e5f",
"audio/seated_cat_cow_intro.mp3": "e0a5848c5d418c7bccc3a784851b2991",
"audio/seated_forward_fold_split_intro.mp3": "c51df490db86305e836c3c6cf44ef2de",
"audio/seated_forward_fold_fin.mp3": "d7a2a71e4fdacf4966dbffcf3b5d00a3",
"audio/extension_lombaire_fin.mp3": "72d637aee813ae83ac08998cd0c5d075",
"audio/flechisseurs_doigts_intro.mp3": "f275ee076266eb290723455277f0694b",
"audio/perfect_stretch_intro.mp3": "89e33248ddb89a7efd0db4d1cea0c2ae",
"audio/seated_pigeon_stretch_fin.mp3": "a4d5a72aa2284df9bf8ab107f5e68caf",
"audio/perfect_stretch_fin.mp3": "bc6f6cbd2a5e137521b4cd257368a476",
"audio/elevateur_scapula_intro.mp3": "8c6f5f69f5e118abb99b30947f8b6bca",
"audio/planche_haute_fin.mp3": "bfe426e5ba7268db0e9e3b5f7cd2939e",
"audio/paravertebraux_fin.mp3": "bc17a089dcc43bfc6d757dfcc7708e2d",
"audio/split_unilateral_fin.mp3": "2ade17af909420b470f4f9fff3d16f9c",
"audio/standing_posterior_pelvic_tilt_intro.mp3": "62f519fe4c7f3815b9980a7dde44910b",
"audio/gainage_lateral_genoux_fin.mp3": "d1c6eb354dedd76ec25b1cb95735e457",
"audio/mountain_climber_fin.mp3": "135cccb111b611d2fa4bc37115c9b99a",
"audio/audio/baby_stretch_intro.mp3": "9d033352526ca5e344a986ca4fa8c222",
"audio/audio/bird_dog_fin.mp3": "e36f97b4833736f901bcafd5e0e24c6f",
"audio/audio/baby_stretch_fin.mp3": "18f98b96121cfd497cd88156956a5492",
"audio/audio/auto_embrassade_fin.mp3": "ee17ffb526767ae725645ce8a3d24b68",
"audio/audio/cat_cow_fin.mp3": "215155256cde36815844d47642632e19",
"audio/audio/dead_bug_fin.mp3": "3eab2557a81c4f3e6285cdc9a9c0a38f",
"audio/audio/brasse_bras_intro.mp3": "c5ab51b10d17d29d52a8e0496fb3833b",
"audio/audio/crossed_legs_forward_fold_intro.mp3": "4c0fb4cba6780bec186728a82731a322",
"audio/audio/abdos_4_temps_fin.mp3": "f87671b718860f72341535cbd69d5178",
"audio/audio/bird_dog_intro.mp3": "fba5ab65aef46246f22917e6c5d241ed",
"audio/audio/child_pose_cobra_fin.mp3": "7d3ec94edd13b19f83c490d861d7c072",
"audio/audio/abdos_4_temps_intro.mp3": "1d37e6d5d9ae081325fca4c4bb58aea5",
"audio/audio/crossed_legs_forward_fold_fin.mp3": "4fad6aa8a2c0f2b291582bcb2c367edb",
"audio/audio/auto_embrassade_intro.mp3": "72c17560f08efab74787fe98e20eb128",
"audio/audio/child_pose_cobra_intro.mp3": "95adc57da756a9ca2190a660dc3e179a",
"audio/audio/dead_bug_intro.mp3": "b2d1188cbc49a40d970e5a9b2fa531bf",
"audio/audio/cat_cow_intro.mp3": "06e3fd7c555b892a0d81a5d548c9d1a7",
"audio/audio/brasse_bras_fin.mp3": "eb91c9f182d84f8cd393fddfa6460d78",
"audio/audio/abdos_2_temps_intro.mp3": "d757306d9fb0685626f07bbbe341a723",
"audio/audio/abdos_2_temps_fin.mp3": "1ded6d203681c9f42a959a619cce2947",
"audio/audio/seated_forward_fold_intro.mp3": "987ac2f45d4cd95aeb2c97a4a0a4366d",
"audio/audio/hip_hinge_fin.mp3": "0bbdf54b5de55148e8bbf5e18811d82c",
"audio/audio/gainage_crunch_fin.mp3": "53a47c80570f006150471999040815d9",
"audio/audio/down_dog_intro.mp3": "d7f26609de7018e8fe0a78b31c72898c",
"audio/audio/gainage_crunch_intro.mp3": "55398e4aaf08e91897a7c7ca522c8c24",
"audio/audio/gainage_lateral_genoux_intro.mp3": "df20b2e15c26e0e44c1f7d0ca99377a1",
"audio/audio/touch_sky_forward_fold_fin.mp3": "56a4f4ade11b5502906c04a86674b182",
"audio/audio/seated_pigeon_stretch_intro.mp3": "34a0836eecbecd946915753035842ec7",
"audio/audio/planche_haute_intro.mp3": "7296d6dac33089574b2ee19fe23220a0",
"audio/audio/extension_hanche_fin.mp3": "c1e9b1dbdeb6d020288eb95cc126421a",
"audio/audio/standing_posterior_pelvic_tilt_fin.mp3": "855143781e060dd52576032b131cdb25",
"audio/audio/mountain_climber_intro.mp3": "92300711d353c29d9dc26b3104e954aa",
"audio/audio/seated_cat_cow_fin.mp3": "78c3083342418d490f0cb8d1c5044295",
"audio/audio/extension_lombaire_intro.mp3": "4dc1df75ef504bcb95279247112cf2e0",
"audio/audio/seated_forward_fold_split_fin.mp3": "28ace4cdd90b7616bb71d7466e4fc87e",
"audio/audio/touch_sky_forward_fold_intro.mp3": "fa37f636e58644c9ca727fe4ff8a6db5",
"audio/audio/gainage_lateral_jambes_intro.mp3": "3552b6125c0bb9785323ec9b104b2c28",
"audio/audio/trapezes_superieurs_fin.mp3": "7e15bad0bf979aba402010f930d5f177",
"audio/audio/down_dog_fin.mp3": "f0a89f1767e3a0033cbf59992ed054a8",
"audio/audio/elevateur_scapula_fin.mp3": "b8c90239c3cb68286bffd60b4131eb88",
"audio/audio/fort_double_stretch_fin.mp3": "d4d49eabfbc1054d7d2489610c741bbf",
"audio/audio/gainage_lateral_jambes_fin.mp3": "fdb17a3249032bc0785853f88c5517b5",
"audio/audio/scorpion_stretch_fin.mp3": "c28be198d5bcda3c19e00d566b66dd32",
"audio/audio/split_unilateral_intro.mp3": "fb319254c7ab2e2454aa9e9e9077f410",
"audio/audio/extension_hanche_intro.mp3": "f427a14fcb16fa8eba50073af21617a8",
"audio/audio/fort_double_stretch_intro.mp3": "bb21e89fdfbe63ea190e19b26e9a5dd1",
"audio/audio/scorpion_stretch_intro.mp3": "f07b7824f9741011dd29c81f14b30b51",
"audio/audio/trapezes_superieurs_intro.mp3": "072490b51374983c0831c0ac50268fb4",
"audio/audio/hip_hinge_intro.mp3": "527b3241b4d7cb18924a984c56ad9ee3",
"audio/audio/flechisseurs_doigts_fin.mp3": "beb114b0208567246d39b33478c4f710",
"audio/audio/paravertebraux_intro.mp3": "adb80debe755ee1881fb7a75089d5e5f",
"audio/audio/seated_cat_cow_intro.mp3": "e0a5848c5d418c7bccc3a784851b2991",
"audio/audio/seated_forward_fold_split_intro.mp3": "c51df490db86305e836c3c6cf44ef2de",
"audio/audio/seated_forward_fold_fin.mp3": "d7a2a71e4fdacf4966dbffcf3b5d00a3",
"audio/audio/extension_lombaire_fin.mp3": "72d637aee813ae83ac08998cd0c5d075",
"audio/audio/flechisseurs_doigts_intro.mp3": "f275ee076266eb290723455277f0694b",
"audio/audio/perfect_stretch_intro.mp3": "89e33248ddb89a7efd0db4d1cea0c2ae",
"audio/audio/seated_pigeon_stretch_fin.mp3": "a4d5a72aa2284df9bf8ab107f5e68caf",
"audio/audio/perfect_stretch_fin.mp3": "bc6f6cbd2a5e137521b4cd257368a476",
"audio/audio/elevateur_scapula_intro.mp3": "8c6f5f69f5e118abb99b30947f8b6bca",
"audio/audio/planche_haute_fin.mp3": "bfe426e5ba7268db0e9e3b5f7cd2939e",
"audio/audio/paravertebraux_fin.mp3": "bc17a089dcc43bfc6d757dfcc7708e2d",
"audio/audio/split_unilateral_fin.mp3": "2ade17af909420b470f4f9fff3d16f9c",
"audio/audio/standing_posterior_pelvic_tilt_intro.mp3": "62f519fe4c7f3815b9980a7dde44910b",
"audio/audio/gainage_lateral_genoux_fin.mp3": "d1c6eb354dedd76ec25b1cb95735e457",
"audio/audio/mountain_climber_fin.mp3": "135cccb111b611d2fa4bc37115c9b99a"};
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
