'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"version.json": "11e7febc788a974f8e9ef16bab4d66a0",
"index.html": "0b70787258970fa45751d7ef444615b6",
"/": "0b70787258970fa45751d7ef444615b6",
"main.dart.js": "511a19aa247888a46a13599ea831d3c6",
"flutter.js": "c71a09214cb6f5f8996a531350400a9a",
"favicon.png": "4b4810b38e78f910793b2e6d97f5cd73",
"icons/Icon-192.png": "4fd751826796e9526ba08f9e1f25dcd9",
"icons/Icon-maskable-192.png": "4fd751826796e9526ba08f9e1f25dcd9",
"icons/Icon-maskable-512.png": "429b0f2eeadd3c52452d3eead2205184",
"icons/Icon-512.png": "429b0f2eeadd3c52452d3eead2205184",
"manifest.json": "4aad1646bc606329a38074c8a1729634",
"assets/AssetManifest.json": "fcbc39eec25278dc5091e08c58cbd746",
"assets/NOTICES": "9142d82d1a03f239f740ea005f30386d",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "e00ce038df26ef5d43ac655cd19a1b82",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "89ed8f4e49bcdfc0b5bfc9b24591e347",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "3c720954df39f6150a5770a977e0529c",
"assets/fonts/MaterialIcons-Regular.otf": "3c2c65da7c6d3a9785cb4169c3a8e1ba",
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
"assets/assets/image/coingeko.png": "cfb404e1eb363073e4cd17a3d658cf89",
"assets/assets/image/1152x1152_sc_on_black.png": "2be994cd96c98d375442dab745763bb6",
"assets/assets/image/xrp.png": "28b66533a5f4727e89ae33cf71046654",
"assets/assets/image/g.png": "b60b4eed7d92cc47f50477516c26dfd5",
"canvaskit/skwasm.js": "445e9e400085faead4493be2224d95aa",
"canvaskit/skwasm.js.symbols": "741d50ffba71f89345996b0aa8426af8",
"canvaskit/canvaskit.js.symbols": "38cba9233b92472a36ff011dc21c2c9f",
"canvaskit/skwasm.wasm": "e42815763c5d05bba43f9d0337fa7d84",
"canvaskit/chromium/canvaskit.js.symbols": "4525682ef039faeb11f24f37436dca06",
"canvaskit/chromium/canvaskit.js": "43787ac5098c648979c27c13c6f804c3",
"canvaskit/chromium/canvaskit.wasm": "f5934e694f12929ed56a671617acd254",
"canvaskit/canvaskit.js": "c86fbd9e7b17accae76e5ad116583dc4",
"canvaskit/canvaskit.wasm": "3d2a2d663e8c5111ac61a46367f751ac",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
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
