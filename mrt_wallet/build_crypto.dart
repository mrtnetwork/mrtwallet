// ignore_for_file: avoid_print

import 'dart:io';

Future<void> buildWebView() async {}

void main() async {
  print("Building crypto wasm. please wait...");
  // Define the command and its arguments
  const String command = 'dart';
  final List<String> arguments = [
    'compile',
    'wasm',
    '-o',
    'crypto_builder/crypto.wasm',
    'crypto_builder/crypto.dart',
  ];

  // Run the command
  final process = await Process.start(command, arguments);

  // Capture and print the standard output
  await stdout.addStream(process.stdout);
  await stderr.addStream(process.stderr);

  // Wait for the process to exit and get the exit code
  await process.exitCode;
}
