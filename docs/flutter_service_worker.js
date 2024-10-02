'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "b70ed8c592f0f56513f67cb85484fb4a",
"version.json": "5a3ba30bd868a7853df42f53c13edb06",
"favicon.ico": "d7a8246d27a181dd2803ac30d9d3a3ea",
"index.html": "8f5d4142d9aec8438fd67ced59e78664",
"/": "8f5d4142d9aec8438fd67ced59e78664",
"page.js": "e1d29b76204e04b340ec1921fb363165",
"background.js": "290c42c8a1439b490be46ec80888854d",
"popup.html": "5f60314a28f5ad2fe3be3e6dfb51c6df",
"main.dart.js": "3f6a6074f60f1f1c801b1661ebdcde3d",
"flutter.js": "f393d3c16b631f36852323de8e583132",
"main.dart.mjs": "933cd5d762c95837ccbcd3e6a915b556",
"icons/48.png": "1d6ff60eb584624d568180c636067713",
"icons/apple-touch-icon.png": "4e08ae2fdc9e821233d1175ed0d21802",
"icons/icon-192.png": "5f9b1c62ca74fc5ce58352782bdc7c4a",
"icons/128.png": "335404105909f28e35023c7e94ee376d",
"icons/16.png": "25bd01dff9afc7c851e5ff8f32ff98cf",
"icons/icon-192-maskable.png": "bd4c677decf42ee21f2678ff3c53c33c",
"icons/icon-512-maskable.png": "d87e7e71075e97e79ed153bc477e7766",
"icons/icon-512.png": "74464ded28eda34f61bfab2538b2d5eb",
"manifest.json": "abcc6bbcf5dad4e6ae71272152c97916",
"tron_web.js": "5662ad025f480dba9d38f9ad3109950f",
"main.dart.wasm": "0e5d321a3e37be00f4be75695dafe3ec",
"content.js": "ce1ccd97eca79c0ebc7ce0ba3e849022",
"assets/AssetManifest.json": "1cff7d102d8655b4f55b50cfee0c0c5b",
"assets/NOTICES": "8fc1cb4c1f06c9ea386d3db42f66f13c",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "0b482f0cf16d45bd538603b16e01172e",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "d15796985469a119aa86972e90b57c61",
"assets/fonts/MaterialIcons-Regular.otf": "8c1bd0f9bccedb2916e133d3dbd04424",
"assets/assets/wasm/wasm.mjs": "6e894146b3aae4fa46c40e48e16870d0",
"assets/assets/wasm/crypto.mjs": "11e83d78b6a150a71ce29d5ec778788e",
"assets/assets/wasm/crypto.wasm.map": "abd3fd92861629183425e9cb81171e0c",
"assets/assets/wasm/crypto.unopt.wasm": "8e435db3de805a1d9b41e09f327b5d0d",
"assets/assets/wasm/crypto.unopt.wasm.map": "a0e8f421738f5e783da15c9cdba25c9a",
"assets/assets/wasm/crypto.wasm": "28af7513a04741c3df7ca856cc4b3751",
"assets/assets/webview/script.js": "65ec31375f9c29280f11963983bb6f08",
"assets/assets/webview/tron_web.js": "82ac55a976257576c948be4942186ace",
"assets/assets/webview/bn.js": "2e6105084e33c000ea42748352bc9509",
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
"assets/assets/image/xlm.png": "1b927d1ddd98f757cd3571ef7f84db80",
"assets/assets/image/eth.png": "c3f411b121f17e26adc24e1f569469a0",
"assets/assets/image/mrt_wallet.png": "d4a75ff7990c792df680287b2e0a092c",
"assets/assets/image/1152x1152_sc_on_white.png": "b7919d020163034b41ae69367726aa46",
"assets/assets/image/atom.png": "02cc70e94a1f2daee7650327034aeffa",
"assets/assets/image/polkadot.png": "beb43963079c1a7028854f7c27ff937c",
"assets/assets/image/bsv.png": "8a2828f65e9d76d6cb88f266fdde8734",
"assets/assets/image/thor.png": "0322077efbddaa848055170c29a858c1",
"assets/assets/image/trx.png": "ad5a78ce7cef87678d3e80fd12752d92",
"assets/assets/image/btc.png": "5976dcfb5ff9b732674247aebb7111b7",
"assets/assets/image/t.png": "2cd0af4c0b7393c029cd9c22ee9de180",
"assets/assets/image/960x960_sc_black.png": "3e92e5ff1d741b5f4168ff0891218fea",
"assets/assets/image/bch.png": "51a9961b1a1a86d18c505950065351b1",
"assets/assets/image/ksm.png": "b964a84254e986223a160ffd38abf122",
"assets/assets/image/pepecoin.png": "a21986e0ed24121e9bb934dc455a6ce3",
"assets/assets/image/coingeko.png": "cfb404e1eb363073e4cd17a3d658cf89",
"assets/assets/image/1152x1152_sc_on_black.png": "2be994cd96c98d375442dab745763bb6",
"assets/assets/image/xrp.png": "28b66533a5f4727e89ae33cf71046654",
"assets/assets/image/g.png": "b60b4eed7d92cc47f50477516c26dfd5",
"assets/assets/solidity/erc721.json": "8e7e31357440d46184ab5a66c6c0271b",
"assets/assets/solidity/erc1155.json": "7ab7cf3ae90e225226acd3de777b4e64",
"assets/assets/solidity/erc20.json": "f3e7a25f40a9656d68388c01dc27a45b",
"assets/assets/fonts/icomoon.ttf": "652b14474de173e194cbfc734026d924",
"bn.js": "2e6105084e33c000ea42748352bc9509",
"canvaskit/skwasm.js": "694fda5704053957c2594de355805228",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/chromium/canvaskit.js": "671c6b4f8fcc199dcc551c7bb125f239",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/canvaskit.js": "66177750aff65a66cb07bb44b8c6422b",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"main.dart.wasm",
"main.dart.mjs",
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
