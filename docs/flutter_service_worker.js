'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "c89fc286d77f3632ec66c266ad631a04",
"assets/AssetManifest.bin.json": "dcc019d33ec20e69c5dca64686c1cf52",
"assets/AssetManifest.json": "7cbd8795eec907b381ec790dd3699a2e",
"assets/assets/fonts/icomoon.ttf": "652b14474de173e194cbfc734026d924",
"assets/assets/image/1152x1152_sc_on_black.png": "2be994cd96c98d375442dab745763bb6",
"assets/assets/image/1152x1152_sc_on_white.png": "b7919d020163034b41ae69367726aa46",
"assets/assets/image/960x960_sc_black.png": "3e92e5ff1d741b5f4168ff0891218fea",
"assets/assets/image/960x960_sc_white.png": "20a68004afeb62fcd777f4c4a781c5b9",
"assets/assets/image/ada.png": "3a25ee0eb61bb5a3891997bd6fb8003a",
"assets/assets/image/arb.png": "2b2ca4abb7312cd7ada8e15c37766365",
"assets/assets/image/atom.png": "02cc70e94a1f2daee7650327034aeffa",
"assets/assets/image/avax.png": "794a004e60672537982ecc6cdf495257",
"assets/assets/image/base.png": "713b2e7abbd0a9d9e769bbf937053f27",
"assets/assets/image/bch.png": "51a9961b1a1a86d18c505950065351b1",
"assets/assets/image/bnb.png": "ca7e6a0cf273b6b628b2812bf6e619c9",
"assets/assets/image/bsv.png": "8a2828f65e9d76d6cb88f266fdde8734",
"assets/assets/image/btc.png": "5976dcfb5ff9b732674247aebb7111b7",
"assets/assets/image/cacao.png": "2974f195970c0db6dbfb6236027e2bec",
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
"assets/assets/image/mrt_wallet.png": "d4a75ff7990c792df680287b2e0a092c",
"assets/assets/image/op.png": "606a5bc1c15dc5282e94af74008b3d59",
"assets/assets/image/osmo.png": "0184bbb143cd005c721bf52d97984111",
"assets/assets/image/pepecoin.png": "13caf3b4af101b40af798bfaccc261ac",
"assets/assets/image/polkadot.png": "beb43963079c1a7028854f7c27ff937c",
"assets/assets/image/sol.png": "0d8e9a185773da474955639b5fc82808",
"assets/assets/image/t.png": "2cd0af4c0b7393c029cd9c22ee9de180",
"assets/assets/image/thor.png": "0322077efbddaa848055170c29a858c1",
"assets/assets/image/ton.png": "64cb8d440809d5f7266c9c40e6de159f",
"assets/assets/image/trx.png": "ad5a78ce7cef87678d3e80fd12752d92",
"assets/assets/image/xlm.png": "1b927d1ddd98f757cd3571ef7f84db80",
"assets/assets/image/xrp.png": "28b66533a5f4727e89ae33cf71046654",
"assets/assets/solidity/erc1155.json": "d7ffa3482c41d49b6e66f9434b704703",
"assets/assets/solidity/erc20.json": "8532c97ae8a576da89fbf6980bc2323a",
"assets/assets/solidity/erc721.json": "1c14a219781cf4b551a9da1dc957aaf8",
"assets/assets/wasm/crypto.js": "38ada7fd57b609c2357021684a786ec8",
"assets/assets/wasm/crypto.js.deps": "ce516c831965c40a4caea05abb687f7f",
"assets/assets/wasm/crypto.js.map": "abbdb5362d89a78b6d03da1bf6f62448",
"assets/assets/wasm/crypto.mjs": "9d848899c6faa43e67356c0889506bac",
"assets/assets/wasm/crypto.unopt.wasm": "8d9dc547c56d0eafc4ceff126e3ccd07",
"assets/assets/wasm/crypto.unopt.wasm.map": "44cc61e5a3dc8a52a262a053ee26a1bb",
"assets/assets/wasm/crypto.wasm": "0b2bb7069d9f2799797b6fa97381efda",
"assets/assets/wasm/crypto.wasm.map": "74b853046a3d741fe28ac04b06408c54",
"assets/assets/wasm/http.js": "f749d309186682d958fd66ae1904376c",
"assets/assets/wasm/http.js.deps": "13884a211579971e31d250d86e54f81c",
"assets/assets/wasm/http.js.map": "b28af1c2df34c3aca072c2474a1f2a3b",
"assets/assets/wasm/wasm.mjs": "98a625ab6e76193fdbccf2a8342df344",
"assets/assets/webview/bn.js": "863d9e3341287f8ea77226799f13025e",
"assets/assets/webview/script.js": "d19e3f185998652e9bad7e7a7d03fab1",
"assets/assets/webview/script_page.js": "7863afbe2e68223fa7a88f222ecad0e0",
"assets/assets/webview/tron_web.js": "f57519f3a5dd8859c8bbfe822733b4f5",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "8470a866c797c4b7dcec72d72fa2249b",
"assets/NOTICES": "0f313ab9c9689debd4104d6a70936034",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"background.js": "761f4dd3355fff68832f7f7888a2272e",
"bn.js": "863d9e3341287f8ea77226799f13025e",
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
"content.js": "2b6971ea8878223da63985c143b63a55",
"favicon.ico": "d7a8246d27a181dd2803ac30d9d3a3ea",
"flutter.js": "4b2350e14c6650ba82871f60906437ea",
"flutter_bootstrap.js": "dedcf8a52021e45aa01ba2e61eefc77c",
"icons/128.png": "335404105909f28e35023c7e94ee376d",
"icons/16.png": "25bd01dff9afc7c851e5ff8f32ff98cf",
"icons/48.png": "1d6ff60eb584624d568180c636067713",
"icons/apple-touch-icon.png": "4e08ae2fdc9e821233d1175ed0d21802",
"icons/icon-192-maskable.png": "bd4c677decf42ee21f2678ff3c53c33c",
"icons/Icon-192.png": "5f9b1c62ca74fc5ce58352782bdc7c4a",
"icons/icon-512-maskable.png": "d87e7e71075e97e79ed153bc477e7766",
"icons/Icon-512.png": "74464ded28eda34f61bfab2538b2d5eb",
"index.html": "08ecabdf209d02c7a2c9ebacdd061ca4",
"/": "08ecabdf209d02c7a2c9ebacdd061ca4",
"main.dart.js": "768b38ca4b399b61624bfec94e07a0b6",
"main.dart.mjs": "8024466957f4eba3a4478e825b34a7c2",
"main.dart.wasm": "d9d446666ec30d277caa2e2b87cdb0a1",
"manifest.json": "97c1184f5e650dc093ce382edef2f95c",
"page.js": "488201ccd40d0d135110c7b6567a1912",
"popup.html": "bbd674fdebab60ef68080c9885772341",
"tron_web.js": "096a46ceba6e2d72fcc46afb17921f1c",
"version.json": "b15e9faf948d95cadb156cbc04151ef3"};
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
