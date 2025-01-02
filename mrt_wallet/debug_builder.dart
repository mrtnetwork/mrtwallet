// ignore_for_file: avoid_print

import 'dart:io';

void _copyDirectory(Directory source, Directory destination) {
  if (!destination.existsSync()) {
    destination.createSync(recursive: true);
  }

  source.listSync(recursive: false).forEach((var entity) {
    if (entity is Directory) {
      final uri = Uri.parse(entity.path);
      final newDirectory =
          Directory('${destination.path}/${uri.pathSegments.last}');
      _copyDirectory(entity, newDirectory);
    } else if (entity is File) {
      final newFile =
          File('${destination.path}/${entity.uri.pathSegments.last}');
      newFile.writeAsBytesSync(entity.readAsBytesSync());
    }
  });
}

Future<void> buildCrypto() async {
  print("Building WASM web crypto. please wait...");
  const String command = 'dart';
  final List<String> args = [
    'compile',
    'wasm',
    '-o',
    'assets/wasm/crypto.wasm',
    'web_crypto/crypto.dart'
  ];
  await _doProcess(command, args);
  if (Directory("build/web/flutter_assets/wasm").existsSync()) {
    File file = File("assets/wasm/crypto.wasm");
    await file.copy("build/web/flutter_assets/wasm/crypto.wasm");
    file = File("assets/wasm/crypto.mjs");
    await file.copy("build/web/flutter_assets/wasm/crypto.mjs");
  }
}

Future<void> buildCryptoJs() async {
  print("Building JS web crypto. please wait...");
  const String command = 'dart';
  final List<String> args = [
    'compile',
    'js',
    '-o',
    'assets/wasm/crypto.js',
    'web_crypto/crypto.dart'
  ];
  await _doProcess(command, args);
  if (Directory("build/flutter_assets/assets/wasm").existsSync()) {
    final File file = File("assets/wasm/crypto.js");
    await file.copy("build/flutter_assets/assets/wasm/crypto.js");
    print("filed copied ");
  }
}

Future<void> buildHttpJs() async {
  print("Building JS web http. please wait...");
  const String command = 'dart';
  final List<String> args = [
    'compile',
    'js',
    '-o',
    'assets/wasm/http.js',
    'web_http/http.dart'
  ];
  await _doProcess(command, args);
  if (Directory("build/flutter_assets/assets/wasm").existsSync()) {
    final File file = File("assets/wasm/http.js");
    await file.copy("build/flutter_assets/assets/wasm/http.js");
    print("filed copied ");
  }
}

Future<void> buildCryptoWasm() async {
  print("Building WASM web crypto. please wait...");
  const String command = 'dart';
  final List<String> args = [
    'compile',
    'wasm',
    '-o',
    'assets/wasm/crypto.wasm',
    'web_crypto/crypto.dart'
  ];
  await _doProcess(command, args);
  if (Directory("build/flutter_assets/assets/wasm").existsSync()) {
    File file = File("assets/wasm/crypto.wasm");
    await file.copy("build/flutter_assets/assets/wasm/crypto.wasm");
    file = File("assets/wasm/crypto.mjs");
    await file.copy("build/flutter_assets/assets/wasm/crypto.mjs");
    print("filed copied ");
  }
}

Future<void> buildWebView({bool minify = false}) async {
  print("Building webview script. please wait...");
  const String command = 'dart';
  final List<String> args = [
    'compile',
    'js',
    "--no-source-maps",
    if (minify) '-m',
    '-o',
    'assets/webview/script.js',
    'js/webview.dart'
  ];
  await _doProcess(command, args);
  File file = File("assets/webview/script.js.deps");
  file.deleteSync(recursive: true);
  file = File("assets/webview/script.js");
  file.copySync(r'D:\mrt_wallet_web3_js_examples\public\webview.js');
}

Future<void> buildWebViewPage({bool minify = false}) async {
  print("Building webview script. please wait...");
  const String command = 'dart';
  final List<String> args = [
    'compile',
    'js',
    "--no-source-maps",
    if (minify) '-m',
    '-o',
    'assets/webview/script_page.js',
    'js/webview_page.dart'
  ];
  await _doProcess(command, args);
  File file = File("assets/webview/script_page.js.deps");
  file.deleteSync(recursive: true);
  file = File("assets/webview/script_page.js");
  file.copySync(r'D:\mrt_wallet_web3_js_examples\public\webview_page.js');
}

Future<void> buildContent({bool minify = false, bool isMozila = false}) async {
  print("Building content. please wait...");
  const String command = 'dart';
  final List<String> args = [
    'compile',
    'js',
    "--no-source-maps",
    if (minify) '-m',
    '-o',
    'web/content.js',
    'js/content.dart'
  ];

  await _doProcess(command, args);
  File file = File("web/content.js");
  if (isMozila) {
    String data = file.readAsStringSync();
    if (minify) {
      data = data.replaceFirst("(function dartProgram(){",
          r'''(function dartProgram(){if(self.browser === undefined){self.browser = browser;self.cloneInto = cloneInto;}''');
    } else {
      data = data.replaceFirst("main() {", r'''    main() {
      if(self.browser === undefined){
        self.browser = browser
        self.cloneInto = cloneInto
      }''');
    }
    await file.writeAsString(data);
  }
  file = File("web/content.js.deps");
  file.deleteSync(recursive: true);
  if (Directory("build/web/").existsSync()) {
    file = File("web/content.js");
    await file.copy("build/web/content.js");
  }
}

Future<void> buildBackground({bool minify = false}) async {
  print("Building background. please wait...");
  const String command = 'dart';
  final List<String> args = [
    'compile',
    'js',
    "--no-source-maps",
    if (minify) '-m',
    '-o',
    'web/background.js',
    'js/background.dart'
  ];
  await _doProcess(command, args);
  File file = File("web/background.js.deps");
  file.deleteSync(recursive: true);
  if (Directory("build/web/").existsSync()) {
    file = File("web/background.js");
    await file.copy("build/web/background.js");
  }
}

Future<void> buildPage({bool minify = false}) async {
  print("Building page. please wait...");
  const String command = 'dart';
  final List<String> args = [
    'compile',
    'js',
    "--no-source-maps",
    if (minify) '-m',
    '-o',
    'web/page.js',
    'js/page.dart'
  ];
  await _doProcess(command, args);
  File file = File("web/page.js.deps");
  file.deleteSync(recursive: true);
  if (Directory("build/web/").existsSync()) {
    file = File("web/page.js");
    await file.copy("build/web/page.js");
  }
}

Future<void> _doProcess(String command, List<String> args,
    {bool runInShell = false}) async {
  final process = await Process.start(command, args, runInShell: runInShell);
  await stdout.addStream(process.stdout);
  await stderr.addStream(process.stderr);
  final result = await process.exitCode;
  print("${[command, ...args].join(" ")} done with exit code $result");
  if (result != 0) {
    throw Exception("process failed with exit code $result");
  }
}

Future<void> _clean() async {
  const String command = 'flutter';
  List<String> args = ['clean'];
  await _doProcess(command, args, runInShell: true);
  args = ["pub", "get"];
  await _doProcess(command, args, runInShell: true);
}

///  'build','web','--wasm', fix
Future<void> _build(
    {bool wasm = true,
    bool csp = false,
    bool minify = false,
    String? baseHref}) async {
  const String command = 'flutter';
  final List<String> args = [
    'build',
    'web',
    if (wasm) '--wasm',
    // if (!csp) '-O0',
    if (!minify) '--profile' else '--release',
    if (csp) '--csp',
    if (baseHref != null) baseHref,
  ];
  print("is csp $csp");
  await _doProcess(command, args, runInShell: true);
  if (csp) {
    const canvasUri =
        r"https://www\.gstatic\.com/flutter-canvaskit/([a-f0-9]+)/";
    final file = File("build/web/main.dart.js");
    String data = await file.readAsString();
    final regex = RegExp(canvasUri);
    final match = regex.firstMatch(data);
    if (match != null && match.groupCount == 1) {
      final part = match.group(0);
      if (part != null) {
        data = data.replaceFirst(part, "/canvaskit/");
        await file.writeAsString(data);
        print("canvaskit replaced $part");
      }
    }
  }
}

Future<void> _buildWeb(
    {bool extension = false,
    bool mozila = false,
    bool minify = false,
    bool clean = false,
    String? baseHref}) async {
  print("come build Extension: $extension Mozila: $mozila Minify: $minify");

  if (clean) {
    await _clean();
  }
  // await buildCrypto();
  final r = Directory("web");
  if (r.existsSync()) {
    await r.delete(recursive: true);
  }
  await r.create(recursive: true);
  final browserFiles = Directory("browser");
  _copyDirectory(browserFiles, r);

  if (extension) {
    await buildBackground(minify: minify);
    await buildPage(minify: minify);
    await buildContent(minify: minify, isMozila: mozila);
    File file = File("extensions/tron_web.js");
    await file.copy("web/tron_web.js");
    file = File("extensions/bn.js");
    await file.copy("web/bn.js");
    file = File("extensions/index.html");
    await file.copy("web/index.html");
    file = File("extensions/popup.html");
    await file.copy("web/popup.html");
    file = File(mozila
        ? "extensions/mozila_manifest.json"
        : "extensions/chrome_manifest.json");
    await file.copy("web/manifest.json");
  }
  await _build(minify: minify, csp: extension, wasm: true, baseHref: baseHref);
}

void main(List<String> args) async {
  // await buildCrypto();
  // return;
  // await buildHttpJs();
  // return;
  // if (args.contains('p')) {
  //   await buildWebViewPage();
  // } else if (args.contains('w')) {
  //   await buildWebView();
  // } else {
  //   await buildWebViewPage();
  //   await buildWebView();
  // }
  // return;
  // return;
  final fixedArgs = List<String>.from(args);

  if (fixedArgs.isEmpty) {
    await buildContent();
    await buildBackground();
    await buildPage();
    return;
  }
  final bool minify = fixedArgs.contains("--release");
  final bool clean = fixedArgs.contains("--clean");
  final bool extension = fixedArgs.contains("-extension");
  final bool mozila = fixedArgs.contains("--mozila");
  final bool web = fixedArgs.contains("-web");
  final bool webviewScript = fixedArgs.contains("-webview");

  if (extension) {
    return await _buildWeb(
        extension: true, mozila: mozila, minify: minify, clean: clean);
  } else if (web) {
    return await _buildWeb(
        minify: minify, baseHref: "--base-href=/mrtwallet/", clean: clean);
  } else if (webviewScript) {
    return await buildWebView(minify: minify);
  }

  if (fixedArgs.contains("w")) {
    await buildWebView();
  }
  if (fixedArgs.contains("c")) {
    await buildContent();
  }
  if (fixedArgs.contains("b")) {
    await buildBackground();
  }
  if (fixedArgs.contains("p")) {
    await buildPage();
  }
}
