// ignore_for_file: avoid_print

import 'dart:io';

void _copyDirectory(Directory source, Directory destination) {
  if (!destination.existsSync()) {
    destination.createSync(recursive: true);
  }

  source.listSync(recursive: false).forEach((var entity) {
    if (entity is Directory) {
      final uri = Uri.parse(entity.path);
      var newDirectory =
          Directory('${destination.path}/${uri.pathSegments.last}');
      _copyDirectory(entity, newDirectory);
    } else if (entity is File) {
      var newFile = File('${destination.path}/${entity.uri.pathSegments.last}');
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
    'web_crypto/crypto.dart',
  ];
  await _doProcess(command, args);
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
  final file = File("assets/webview/script.js.deps");
  file.deleteSync(recursive: true);
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
    'js/content.dart',
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

Future<void> _doProcess(String command, List<String> args) async {
  final process = await Process.start(command, args);
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
  await _doProcess(command, args);
  args = ["pub", "get"];
  await _doProcess(command, args);
}

///  'build','web','--wasm', fix
Future<void> _build(
    {bool wasm = true,
    bool csp = false,
    bool minify = false,
    String? baseHref}) async {
  const String command = 'flutter';
  List<String> args = [
    'build',
    'web',
    if (wasm) '--wasm',
    // if (!csp) '-O0',
    if (!minify) '--profile' else '--release',
    if (csp) '--csp',
    if (baseHref != null) baseHref,
  ];
  print("is csp $csp");
  await _doProcess(command, args);
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
  await buildCrypto();
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
  final fixedArgs = List<String>.from(args);
  bool minify = fixedArgs.contains("--release");
  bool clean = fixedArgs.contains("--clean");

  if (fixedArgs.contains("-extension")) {
    final bool mozila = fixedArgs.contains("--mozila");
    await _buildWeb(
        extension: true, mozila: mozila, minify: minify, clean: clean);
  } else if (fixedArgs.contains("-web")) {
    await _buildWeb(
        minify: minify, baseHref: "--base-href=/mrtwallet/", clean: clean);
  } else if (fixedArgs.contains("-webview")) {
    await buildWebView(minify: minify);
  }

  if (fixedArgs.isEmpty) {
    await buildContent();
    await buildBackground();
    await buildPage();
    return;
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

/// dart compile js -m -o extension/content.js js/extension.dart
