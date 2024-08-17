export 'platforms/cross.dart'
    if (dart.library.js_interop) 'platforms/web.dart'
    if (dart.library.io) 'platforms/io.dart';
