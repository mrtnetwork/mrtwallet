part of '../scripts.dart';

typedef PostWalletMessage = void Function(PageMessage);
typedef GetWalletMessage = Future<JSAny?> Function(PageMessage);

abstract class PageNetworkController {
  const PageNetworkController({required this.getWalletMessage});
  final GetWalletMessage getWalletMessage;
}
