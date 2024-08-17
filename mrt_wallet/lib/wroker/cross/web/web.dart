library web_crypto;

import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:blockchain_utils/crypto/crypto/chacha20poly1305/chacha20poly1305.dart';
import 'package:blockchain_utils/crypto/quick_crypto.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_native_support/web/api/window/window.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wroker/core/worker.dart';
import 'package:mrt_wallet/wroker/crypto/crypto.dart';
import 'package:mrt_wallet/wroker/requets/argruments/argruments.dart';
import 'package:mrt_wallet/wroker/requets/completer/completer.dart';
import 'package:mrt_wallet/wroker/requets/messages/models/models.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart' as web;
import '../exception.dart';
part 'browser.dart';

IsolateCryptoWoker getCryptoWorker() {
  return BrowserCryptoWorker._();
}
