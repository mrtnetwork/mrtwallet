'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "9ed336af0e9a55500c7ecc9861dffc4f",
"version.json": "dfa22589802345f3dd9fc808cde657f5",
"index.html": "4109a2285b5bd099604496196b8ae2ee",
"/": "4109a2285b5bd099604496196b8ae2ee",
"main.dart.js": "a44bcfa08a34173ca4de2f39ae7eafc9",
"flutter.js": "383e55f7f3cce5be08fcf1f3881f585c",
"favicon.png": "4b4810b38e78f910793b2e6d97f5cd73",
"icons/Icon-192.png": "4fd751826796e9526ba08f9e1f25dcd9",
"icons/Icon-maskable-192.png": "4fd751826796e9526ba08f9e1f25dcd9",
"icons/Icon-maskable-512.png": "429b0f2eeadd3c52452d3eead2205184",
"icons/Icon-512.png": "429b0f2eeadd3c52452d3eead2205184",
"manifest.json": "4aad1646bc606329a38074c8a1729634",
"assets/AssetManifest.json": "22f95fd4fae1cd0850a61f1aacb235cf",
"assets/NOTICES": "a3730c0d9db51ddbba8d392a042a9342",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "1eb94ed189a81612127cae5e80680dae",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "4b95b4262419df174d50490b78ee2604",
"assets/fonts/MaterialIcons-Regular.otf": "30b899c62d1ea2a5a94ac5c715eb81ad",
"assets/assets/image/osmo.png": "0184bbb143cd005c721bf52d97984111",
"assets/assets/image/dash.png": "25a9a5aa35d5def7526599ee4df97bbd",
"assets/assets/image/sol.png": "0d8e9a185773da474955639b5fc82808",
"assets/assets/image/doge.png": "6747a235c4869d9c8d431c2e73e553c0",
"assets/assets/image/matic.png": "64594f2dae6d0124774a1c8b782d0de9",
"assets/assets/image/bnb.png": "ca7e6a0cf273b6b628b2812bf6e619c9",
"assets/assets/image/ltc.png": "64c5025e1cedaac9693ab5da07155445",
"assets/assets/image/cacao.png": "2974f195970c0db6dbfb6236027e2bec",
"assets/assets/image/ada.png": "3a25ee0eb61bb5a3891997bd6fb8003a",
"assets/assets/image/960x960_sc_white.png": "20a68004afeb62fcd777f4c4a781c5b9",
"assets/assets/image/kujira.png": "34d811e0c0e52552e8550912747882df",
"assets/assets/image/ton.png": "64cb8d440809d5f7266c9c40e6de159f",
"assets/assets/image/eth.png": "c3f411b121f17e26adc24e1f569469a0",
"assets/assets/image/mrt_wallet.png": "c9506adb22334757952f5711b76b3fe3",
"assets/assets/image/1152x1152_sc_on_white.png": "b7919d020163034b41ae69367726aa46",
"assets/assets/image/atom.png": "c15d55f6165c9c48b9319ced16ae21f3",
"assets/assets/image/bsv.png": "8a2828f65e9d76d6cb88f266fdde8734",
"assets/assets/image/thor.png": "0322077efbddaa848055170c29a858c1",
"assets/assets/image/trx.png": "ad5a78ce7cef87678d3e80fd12752d92",
"assets/assets/image/btc.png": "5976dcfb5ff9b732674247aebb7111b7",
"assets/assets/image/t.png": "2cd0af4c0b7393c029cd9c22ee9de180",
"assets/assets/image/960x960_sc_black.png": "3e92e5ff1d741b5f4168ff0891218fea",
"assets/assets/image/bch.png": "51a9961b1a1a86d18c505950065351b1",
"assets/assets/image/pepecoin.png": "a21986e0ed24121e9bb934dc455a6ce3",
"assets/assets/image/coingeko.png": "cfb404e1eb363073e4cd17a3d658cf89",
"assets/assets/image/1152x1152_sc_on_black.png": "2be994cd96c98d375442dab745763bb6",
"assets/assets/image/xrp.png": "28b66533a5f4727e89ae33cf71046654",
"assets/assets/image/g.png": "b60b4eed7d92cc47f50477516c26dfd5",
"canvaskit/skwasm.js": "5d4f9263ec93efeb022bb14a3881d240",
"canvaskit/skwasm.js.symbols": "c3c05bd50bdf59da8626bbe446ce65a3",
"canvaskit/canvaskit.js.symbols": "74a84c23f5ada42fe063514c587968c6",
"canvaskit/skwasm.wasm": "4051bfc27ba29bf420d17aa0c3a98bce",
"canvaskit/chromium/canvaskit.js.symbols": "ee7e331f7f5bbf5ec937737542112372",
"canvaskit/chromium/canvaskit.js": "901bb9e28fac643b7da75ecfd3339f3f",
"canvaskit/chromium/canvaskit.wasm": "399e2344480862e2dfa26f12fa5891d7",
"canvaskit/canvaskit.js": "738255d00768497e86aa4ca510cce1e1",
"canvaskit/canvaskit.wasm": "9251bb81ae8464c4df3b072f84aa969b",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03"};
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
