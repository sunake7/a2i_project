import 'package:flutter_test/flutter_test.dart';
import 'package:yolo_flutter_app/yolo_flutter_app.dart';
import 'package:yolo_flutter_app/yolo_flutter_app_platform_interface.dart';
import 'package:yolo_flutter_app/yolo_flutter_app_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockYoloFlutterAppPlatform
    with MockPlatformInterfaceMixin
    implements YoloFlutterAppPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final YoloFlutterAppPlatform initialPlatform = YoloFlutterAppPlatform.instance;

  test('$MethodChannelYoloFlutterApp is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelYoloFlutterApp>());
  });

  test('getPlatformVersion', () async {
    YoloFlutterApp yoloFlutterAppPlugin = YoloFlutterApp();
    MockYoloFlutterAppPlatform fakePlatform = MockYoloFlutterAppPlatform();
    YoloFlutterAppPlatform.instance = fakePlatform;

    expect(await yoloFlutterAppPlugin.getPlatformVersion(), '42');
  });
}
