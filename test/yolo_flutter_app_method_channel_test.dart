import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yolo_flutter_app/yolo_flutter_app_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelYoloFlutterApp platform = MethodChannelYoloFlutterApp();
  const MethodChannel channel = MethodChannel('yolo_flutter_app');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
