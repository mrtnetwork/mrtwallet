'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "e3edfc0e4940a376137da53cba3ce74e",
"assets/AssetManifest.bin.json": "5414290cdf1d2bb644206c10a35ee4de",
"assets/AssetManifest.json": "0a91a3d9032deba2db2a89d2df609a35",
"assets/assets/fonts/icomoon.ttf": "652b14474de173e194cbfc734026d924",
"assets/assets/image/1152x1152_sc_on_black.png": "2be994cd96c98d375442dab745763bb6",
"assets/assets/image/1152x1152_sc_on_white.png": "b7919d020163034b41ae69367726aa46",
"assets/assets/image/960x960_sc_black.png": "3e92e5ff1d741b5f4168ff0891218fea",
"assets/assets/image/960x960_sc_white.png": "20a68004afeb62fcd777f4c4a781c5b9",
"assets/assets/image/acala.png": "17bc9f4b4541f13abb80ae0a42d656ce",
"assets/assets/image/ada.png": "3a25ee0eb61bb5a3891997bd6fb8003a",
"assets/assets/image/aptos.png": "e27eaa44d34e2a533e93bd519f5de146",
"assets/assets/image/arb.png": "2b2ca4abb7312cd7ada8e15c37766365",
"assets/assets/image/astar.png": "9ba608e2a9e4583d06c7924c4ba8a9e5",
"assets/assets/image/atom.png": "02cc70e94a1f2daee7650327034aeffa",
"assets/assets/image/avax.png": "794a004e60672537982ecc6cdf495257",
"assets/assets/image/base.png": "713b2e7abbd0a9d9e769bbf937053f27",
"assets/assets/image/bch.png": "51a9961b1a1a86d18c505950065351b1",
"assets/assets/image/bnb.png": "ca7e6a0cf273b6b628b2812bf6e619c9",
"assets/assets/image/bsv.png": "8a2828f65e9d76d6cb88f266fdde8734",
"assets/assets/image/btc.png": "5976dcfb5ff9b732674247aebb7111b7",
"assets/assets/image/cacao.png": "2974f195970c0db6dbfb6236027e2bec",
"assets/assets/image/cfg.png": "6eb220c2b374d85300fe1f4c88de4105",
"assets/assets/image/coingeko.png": "cfb404e1eb363073e4cd17a3d658cf89",
"assets/assets/image/dash.png": "25a9a5aa35d5def7526599ee4df97bbd",
"assets/assets/image/doge.png": "6747a235c4869d9c8d431c2e73e553c0",
"assets/assets/image/eth.png": "c3f411b121f17e26adc24e1f569469a0",
"assets/assets/image/g.png": "b60b4eed7d92cc47f50477516c26dfd5",
"assets/assets/image/ksm.png": "b964a84254e986223a160ffd38abf122",
"assets/assets/image/kujira.png": "34d811e0c0e52552e8550912747882df",
"assets/assets/image/ltc.png": "64c5025e1cedaac9693ab5da07155445",
"assets/assets/image/matic.png": "64594f2dae6d0124774a1c8b782d0de9",
"assets/assets/image/monero.png": "1ceb2ad01a9ec6d12445fddc817c89bc",
"assets/assets/image/moonbeam.png": "e5c40b036101ac771aae39c12100f513",
"assets/assets/image/moonriver.png": "9c7778eb492162350c1a3f853bc6910a",
"assets/assets/image/mrt_wallet.png": "d4a75ff7990c792df680287b2e0a092c",
"assets/assets/image/op.png": "606a5bc1c15dc5282e94af74008b3d59",
"assets/assets/image/osmo.png": "0184bbb143cd005c721bf52d97984111",
"assets/assets/image/pepecoin.png": "13caf3b4af101b40af798bfaccc261ac",
"assets/assets/image/polkadot.png": "beb43963079c1a7028854f7c27ff937c",
"assets/assets/image/sol.png": "0d8e9a185773da474955639b5fc82808",
"assets/assets/image/substrate.png": "6ca7842d538e11bc64b507755528a810",
"assets/assets/image/sui.png": "2ac86def985c8d14638a05c56f33c9d9",
"assets/assets/image/t.png": "2cd0af4c0b7393c029cd9c22ee9de180",
"assets/assets/image/thor.png": "0322077efbddaa848055170c29a858c1",
"assets/assets/image/ton.png": "64cb8d440809d5f7266c9c40e6de159f",
"assets/assets/image/trx.png": "ad5a78ce7cef87678d3e80fd12752d92",
"assets/assets/image/xlm.png": "1b927d1ddd98f757cd3571ef7f84db80",
"assets/assets/image/xrp.png": "28b66533a5f4727e89ae33cf71046654",
"assets/assets/solidity/erc1155.json": "d7ffa3482c41d49b6e66f9434b704703",
"assets/assets/solidity/erc20.json": "8532c97ae8a576da89fbf6980bc2323a",
"assets/assets/solidity/erc721.json": "1c14a219781cf4b551a9da1dc957aaf8",
"assets/assets/wasm/crypto.mjs": "b96412713cbe4a8dd6b6467515eec3b1",
"assets/assets/wasm/crypto.unopt.wasm": "317426d6cbf0110b0d3dd274c2334bb0",
"assets/assets/wasm/crypto.unopt.wasm.map": "e7eeba762be607f075373a0d77b921b3",
"assets/assets/wasm/crypto.wasm": "a83d416adb95571758ef3042d50cdc0f",
"assets/assets/wasm/crypto.wasm.map": "af8362947e9c2860382d588a737c8238",
"assets/assets/wasm/http.js": "9de450306cee5a80e0fe157cdfd92d67",
"assets/assets/wasm/wasm.mjs": "3d7c4fc038ec84a5493769d820d82f6c",
"assets/assets/webview/aptos.js": "ab8c3f32f5b81988288226e9ecc6aacf",
"assets/assets/webview/bn.js": "863d9e3341287f8ea77226799f13025e",
"assets/assets/webview/script.js": "fd51799ac2d2790a761d40ee039b1ff3",
"assets/assets/webview/script_page.js": "a843d2457de37e047ceca46289e13025",
"assets/assets/webview/tron_web.js": "096a46ceba6e2d72fcc46afb17921f1c",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "b973c3548dedda2d4db7b9b147b6301c",
"assets/NOTICES": "0f313ab9c9689debd4104d6a70936034",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "26eef3024dbc64886b7f48e1b6fb05cf",
"canvaskit/canvaskit.js.symbols": "efc2cd87d1ff6c586b7d4c7083063a40",
"canvaskit/canvaskit.wasm": "e7602c687313cfac5f495c5eac2fb324",
"canvaskit/chromium/canvaskit.js": "b7ba6d908089f706772b2007c37e6da4",
"canvaskit/chromium/canvaskit.js.symbols": "e115ddcfad5f5b98a90e389433606502",
"canvaskit/chromium/canvaskit.wasm": "ea5ab288728f7200f398f60089048b48",
"canvaskit/skwasm.js": "ac0f73826b925320a1e9b0d3fd7da61c",
"canvaskit/skwasm.js.symbols": "96263e00e3c9bd9cd878ead867c04f3c",
"canvaskit/skwasm.wasm": "828c26a0b1cc8eb1adacbdd0c5e8bcfa",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"favicon.ico": "d7a8246d27a181dd2803ac30d9d3a3ea",
"flutter.js": "4b2350e14c6650ba82871f60906437ea",
"flutter_bootstrap.js": "9e3423fbe0ac029badc5101dd8da21d1",
"icons/128.png": "335404105909f28e35023c7e94ee376d",
"icons/16.png": "25bd01dff9afc7c851e5ff8f32ff98cf",
"icons/48.png": "1d6ff60eb584624d568180c636067713",
"icons/apple-touch-icon.png": "4e08ae2fdc9e821233d1175ed0d21802",
"icons/icon-192-maskable.png": "bd4c677decf42ee21f2678ff3c53c33c",
"icons/Icon-192.png": "5f9b1c62ca74fc5ce58352782bdc7c4a",
"icons/icon-512-maskable.png": "d87e7e71075e97e79ed153bc477e7766",
"icons/Icon-512.png": "74464ded28eda34f61bfab2538b2d5eb",
"index.html": "657d7d20ec248c78adf310a2ad8d1a39",
"/": "657d7d20ec248c78adf310a2ad8d1a39",
"main.dart.js": "5f3690f6a6260b80191013601d369ede",
"main.dart.mjs": "ce757f4aa24dbe17892efa888dbc8e6b",
"main.dart.wasm": "e2c8f5c4f594464ff2f41e3aa98a7234",
"manifest.json": "da5dd54080273a508de8b39db2e13187",
"version.json": "ffc065145b4900f38586733c7681e7a1"};
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
