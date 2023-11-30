import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_native_support/mrt_native_support.dart';

MrtPlatformInterface getPlatformInterface() => throw UnsupportedError(
    'Cannot create a client instance dart:html or dart:io.');
AppPlatform getPlatform() => throw UnsupportedError(
    'Cannot create a client instance dart:html or dart:io.');
