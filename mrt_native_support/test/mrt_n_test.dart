// import 'package:flutter_test/flutter_test.dart';
// import 'package:mrt_n/mrt_n.dart';
// import 'package:mrt_n/mrt_n_platform_interface.dart';
// import 'package:mrt_n/mrt_n_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockMrt_nPlatform
//     with MockPlatformInterfaceMixin
//     implements Mrt_nPlatform {

//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final Mrt_nPlatform initialPlatform = Mrt_nPlatform.instance;

//   test('$MethodChannelMrt_n is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelMrt_n>());
//   });

//   test('getPlatformVersion', () async {
//     Mrt_n mrt_nPlugin = Mrt_n();
//     MockMrt_nPlatform fakePlatform = MockMrt_nPlatform();
//     Mrt_nPlatform.instance = fakePlatform;

//     expect(await mrt_nPlugin.getPlatformVersion(), '42');
//   });
// }
