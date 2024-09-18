import 'package:mrt_wallet/app/euqatable/equatable.dart';
import 'package:mrt_wallet/app/models/models/image.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/authenticated.dart';

class Web3ClientInfo with Equatable {
  final APPImage? image;
  final String url;
  final String applicationId;
  final String name;
  final String clientId;
  const Web3ClientInfo._({
    required this.image,
    required this.url,
    required this.applicationId,
    required this.clientId,
    required this.name,
  });
  static Web3ClientInfo? info(
      {required String clientId,
      required String? url,
      String? name,
      required APPImage faviIcon}) {
    final applicationId = Web3APPAuthentication.toApplicationId(url);
    if (applicationId == null) return null;
    Uri uri = Uri.parse(applicationId);
    return Web3ClientInfo._(
        image: faviIcon,
        url: url!,
        applicationId: applicationId,
        clientId: clientId,
        name: (name?.isEmpty ?? true) ? uri.host : name!);
  }

  @override
  List get variabels => [applicationId, url];
}
