// ignore_for_file: avoid_print

import 'dart:io';

void main() async {
  // Define the command and its arguments
  const String command = 'flutter';
  final List<String> arguments = [
    'build',
    'web',
    // '--wasm',
    '--profile',
    '--csp'
  ];

  // Run the command
  final process = await Process.start(command, arguments);

  // Capture and print the standard output
  await stdout.addStream(process.stdout);
  await stderr.addStream(process.stderr);

  // Wait for the process to exit and get the exit code
  await process.exitCode;

  const canvasUri = r"https://www\.gstatic\.com/flutter-canvaskit/([a-f0-9]+)/";
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
