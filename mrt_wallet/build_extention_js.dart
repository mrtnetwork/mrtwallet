// ignore_for_file: avoid_print

import 'dart:io';

Future<void> buildWebView() async {
  print("Building webview script. please wait...");
  // Define the command and its arguments
  const String command = 'dart';
  final List<String> arguments = [
    'compile',
    'js',
    "--no-source-maps",
    // '-m',
    '-o',
    '/Users/macbookpro/Documents/bitcoin/nod_server/public/a.js',
    'js/webview.dart'
  ];

  // Run the command
  final process = await Process.start(command, arguments);

  // Capture and print the standard output
  await stdout.addStream(process.stdout);
  await stderr.addStream(process.stderr);

  // Wait for the process to exit and get the exit code
  await process.exitCode;
}

Future<void> buildContent({bool isMozila = false}) async {
  print("Building content. please wait...");
  // Define the command and its arguments
  const String command = 'dart';
  final List<String> arguments = [
    'compile',
    'js',
    "--no-source-maps",
    // '-m',

    '-o',
    'mozila/content.js',
    'js/extention_content.dart',
    // '-O4',
  ];

  // Run the command
  final process = await Process.start(command, arguments);

  // Capture and print the standard output
  await stdout.addStream(process.stdout);
  await stderr.addStream(process.stderr);

  // Wait for the process to exit and get the exit code
  await process.exitCode;

  // const canvasUri = r"https://www\.gstatic\.com/flutter-canvaskit/([a-f0-9]+)/";
  // print('Process exited with code $exitCode');
  final file = File("mozila/content.js");
  if (isMozila) {
    String data = file.readAsStringSync();
    data = data.replaceFirst("main() {", r'''    main() {
      if(self.browser === undefined){
        self.browser = browser
        self.cloneInto = cloneInto
      }''');
    await file.writeAsString(data);
  }
  await file.copy("build/web/content.js");
}

Future<void> buildBackground() async {
  print("Building background. please wait...");
  // Define the command and its arguments
  const String command = 'dart';
  final List<String> arguments = [
    'compile',
    'js',
    "--no-source-maps",
    // '-m',
    '-o',
    'mozila/background.js',
    'js/extention_background.dart'
  ];

  // Run the command
  final process = await Process.start(command, arguments);

  // Capture and print the standard output
  await stdout.addStream(process.stdout);
  await stderr.addStream(process.stderr);

  // Wait for the process to exit and get the exit code
  await process.exitCode;

  // const canvasUri = r"https://www\.gstatic\.com/flutter-canvaskit/([a-f0-9]+)/";
  // print('Process exited with code $exitCode');
  final file = File("mozila/background.js");
  await file.copy("build/web/background.js");
}

Future<void> buildPage() async {
  print("Building page. please wait...");
  // Define the command and its arguments
  const String command = 'dart';
  final List<String> arguments = [
    'compile',
    'js',
    "--no-source-maps",
    // '-m',
    '-o',
    'mozila/page.js',
    'js/extention_page.dart'
  ];

  // Run the command
  final process = await Process.start(command, arguments);

  // Capture and print the standard output
  await stdout.addStream(process.stdout);
  await stderr.addStream(process.stderr);

  // Wait for the process to exit and get the exit code
  await process.exitCode;

  // const canvasUri = r"https://www\.gstatic\.com/flutter-canvaskit/([a-f0-9]+)/";
  // print('Process exited with code $exitCode');
  final file = File("mozila/page.js");
  await file.copy("build/web/page.js");
}

void main(List<String> args) async {
  final fixedArgs = args
      .where((e) => e.trim().isNotEmpty)
      .map((e) => e.toLowerCase())
      .toList();

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

/// dart compile js -m -o mozila/content.js js/extention.dart
