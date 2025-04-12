'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "2a9a63c13b710f2231e68c79af76ccf1",
"version.json": "ffc065145b4900f38586733c7681e7a1",
"favicon.ico": "d7a8246d27a181dd2803ac30d9d3a3ea",
"index.html": "657d7d20ec248c78adf310a2ad8d1a39",
"/": "657d7d20ec248c78adf310a2ad8d1a39",
"main.dart.js": "2a0e0207c10a73f7fcbf5654930fda28",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"main.dart.mjs": "ac4bee9bb14d1d6691a39b26d1650321",
"icons/48.png": "1d6ff60eb584624d568180c636067713",
"icons/apple-touch-icon.png": "4e08ae2fdc9e821233d1175ed0d21802",
"icons/Icon-192.png": "5f9b1c62ca74fc5ce58352782bdc7c4a",
"icons/128.png": "335404105909f28e35023c7e94ee376d",
"icons/16.png": "25bd01dff9afc7c851e5ff8f32ff98cf",
"icons/icon-192-maskable.png": "bd4c677decf42ee21f2678ff3c53c33c",
"icons/icon-512-maskable.png": "d87e7e71075e97e79ed153bc477e7766",
"icons/Icon-512.png": "74464ded28eda34f61bfab2538b2d5eb",
"manifest.json": "da5dd54080273a508de8b39db2e13187",
"main.dart.wasm": "0ef80762c4360c3129ad08ec26c4fcc2",
"assets/AssetManifest.json": "5223a8c163edd3b832820409c9fd6866",
"assets/NOTICES": "de99c56d5388e3fb8b4726e0a3674e2b",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "98e82abd712e7f67be2e74622ff6db51",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/cosmos_sdk/assets/chains.json": "94a42a08e4fa35afbd3c524f2a65d40f",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "676391744cf697320b2dd2973a62035d",
"assets/fonts/MaterialIcons-Regular.otf": "0c133a04c407a862aa405a40fdea7c68",
"assets/assets/wasm/wasm.mjs": "3d7c4fc038ec84a5493769d820d82f6c",
"assets/assets/wasm/crypto.mjs": "2ba273f26d5d39cc42e16deeeed9b86d",
"assets/assets/wasm/crypto.wasm.map": "034a68df29f61e6f3ffc99670529bd04",
"assets/assets/wasm/crypto.unopt.wasm": "7bc7b8976f9d8d5876f33dca5193c6de",
"assets/assets/wasm/crypto.unopt.wasm.map": "a8107ea611aa421ac6250b5b925b1a95",
"assets/assets/wasm/http.js": "9de450306cee5a80e0fe157cdfd92d67",
"assets/assets/wasm/crypto.wasm": "050255435aacc44b2bbb0f96ed15afbb",
"assets/assets/webview/script_page.js": "a09541f985ee673fbd6a3043ea0acdd7",
"assets/assets/webview/aptos.js": "ab8c3f32f5b81988288226e9ecc6aacf",
"assets/assets/webview/script.js": "3a6ac929ab1ce5c75de530f1cfd2ae15",
"assets/assets/webview/tron_web.js": "096a46ceba6e2d72fcc46afb17921f1c",
"assets/assets/webview/bn.js": "863d9e3341287f8ea77226799f13025e",
"assets/assets/image/osmo.png": "0184bbb143cd005c721bf52d97984111",
"assets/assets/image/dash.png": "25a9a5aa35d5def7526599ee4df97bbd",
"assets/assets/image/sol.png": "0d8e9a185773da474955639b5fc82808",
"assets/assets/image/doge.png": "6747a235c4869d9c8d431c2e73e553c0",
"assets/assets/image/matic.png": "64594f2dae6d0124774a1c8b782d0de9",
"assets/assets/image/bnb.png": "ca7e6a0cf273b6b628b2812bf6e619c9",
"assets/assets/image/ltc.png": "64c5025e1cedaac9693ab5da07155445",
"assets/assets/image/cacao.png": "2974f195970c0db6dbfb6236027e2bec",
"assets/assets/image/ada.png": "3a25ee0eb61bb5a3891997bd6fb8003a",
"assets/assets/image/astar.png": "9ba608e2a9e4583d06c7924c4ba8a9e5",
"assets/assets/image/aptos.png": "e27eaa44d34e2a533e93bd519f5de146",
"assets/assets/image/960x960_sc_white.png": "20a68004afeb62fcd777f4c4a781c5b9",
"assets/assets/image/avax.png": "794a004e60672537982ecc6cdf495257",
"assets/assets/image/kujira.png": "34d811e0c0e52552e8550912747882df",
"assets/assets/image/ton.png": "64cb8d440809d5f7266c9c40e6de159f",
"assets/assets/image/xlm.png": "1b927d1ddd98f757cd3571ef7f84db80",
"assets/assets/image/eth.png": "c3f411b121f17e26adc24e1f569469a0",
"assets/assets/image/mrt_wallet.png": "d4a75ff7990c792df680287b2e0a092c",
"assets/assets/image/1152x1152_sc_on_white.png": "b7919d020163034b41ae69367726aa46",
"assets/assets/image/substrate.png": "6ca7842d538e11bc64b507755528a810",
"assets/assets/image/atom.png": "02cc70e94a1f2daee7650327034aeffa",
"assets/assets/image/acala.png": "17bc9f4b4541f13abb80ae0a42d656ce",
"assets/assets/image/base.png": "713b2e7abbd0a9d9e769bbf937053f27",
"assets/assets/image/polkadot.png": "beb43963079c1a7028854f7c27ff937c",
"assets/assets/image/bsv.png": "8a2828f65e9d76d6cb88f266fdde8734",
"assets/assets/image/thor.png": "0322077efbddaa848055170c29a858c1",
"assets/assets/image/moonriver.png": "9c7778eb492162350c1a3f853bc6910a",
"assets/assets/image/cfg.png": "6eb220c2b374d85300fe1f4c88de4105",
"assets/assets/image/trx.png": "ad5a78ce7cef87678d3e80fd12752d92",
"assets/assets/image/btc.png": "5976dcfb5ff9b732674247aebb7111b7",
"assets/assets/image/t.png": "2cd0af4c0b7393c029cd9c22ee9de180",
"assets/assets/image/960x960_sc_black.png": "3e92e5ff1d741b5f4168ff0891218fea",
"assets/assets/image/op.png": "606a5bc1c15dc5282e94af74008b3d59",
"assets/assets/image/moonbeam.png": "e5c40b036101ac771aae39c12100f513",
"assets/assets/image/bch.png": "51a9961b1a1a86d18c505950065351b1",
"assets/assets/image/ksm.png": "b964a84254e986223a160ffd38abf122",
"assets/assets/image/pepecoin.png": "13caf3b4af101b40af798bfaccc261ac",
"assets/assets/image/arb.png": "2b2ca4abb7312cd7ada8e15c37766365",
"assets/assets/image/coingeko.png": "cfb404e1eb363073e4cd17a3d658cf89",
"assets/assets/image/1152x1152_sc_on_black.png": "2be994cd96c98d375442dab745763bb6",
"assets/assets/image/monero.png": "1ceb2ad01a9ec6d12445fddc817c89bc",
"assets/assets/image/xrp.png": "28b66533a5f4727e89ae33cf71046654",
"assets/assets/image/g.png": "b60b4eed7d92cc47f50477516c26dfd5",
"assets/assets/image/sui.png": "2ac86def985c8d14638a05c56f33c9d9",
"assets/assets/solidity/erc721.json": "1c14a219781cf4b551a9da1dc957aaf8",
"assets/assets/solidity/erc1155.json": "d7ffa3482c41d49b6e66f9434b704703",
"assets/assets/solidity/erc20.json": "8532c97ae8a576da89fbf6980bc2323a",
"assets/assets/fonts/icomoon.ttf": "652b14474de173e194cbfc734026d924",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206"};
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
