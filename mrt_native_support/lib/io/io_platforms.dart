library io_platform_interface;

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mrt_native_support/exception/exception.dart';
import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_native_support/mrt_native_support.dart';
import 'package:mrt_native_support/constant/constant.dart';

part 'webview.dart';
part 'io_impl.dart';
part 'desktop_impl.dart';

MrtPlatformInterface getPlatformInterface() => IoPlatformInterface();
