import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:ultralytics_yolo/yolo_model.dart';

void main() {
  runApp(const MyApp());
}



class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final controller = UltralyticsYoloCameraController();
  bool _isCameraReady = false;
  @override
  Widget build(BuildContext context) {
    try {
      return MaterialApp(
        home: Scaffold(
          body: FutureBuilder(
            future: _checkPermissions(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print('Error: ${snapshot.error}');
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              final predictor = snapshot.data;

              final allPermissionsGranted = snapshot.data ?? false;
              if (!allPermissionsGranted) {
                return Container();
              }
              return FutureBuilder(
                future: _initObjectDetectorWithLocalModel(),
                builder: (context, snapshot) {
                  final predictor = snapshot.data;
                  if (predictor == null) {
                    return Container();
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isFoldable = constraints.maxWidth > 600;
                      return Stack(
                        children: [
                          UltralyticsYoloCameraPreview(
                            controller: controller,
                            predictor: predictor,
                            onCameraCreated: () async {
                              try {
                                await predictor.loadModel(useGpu: true);
                                print('Model loaded successfully');
                              } catch (e) {
                                print('Error loading model: $e');
                              }
                              setState(() {
                                print('Camera created successfully');
                                _isCameraReady = true;
                              });
                            },
                          ),
                          StreamBuilder(
                            stream: predictor.inferenceTime,
                            builder: (context, snapshot) {
                              final inferenceTime = snapshot.data;
                              return StreamBuilder(
                                stream: predictor.fpsRate,
                                builder: (context, snapshot) {
                                  final fpsRate = snapshot.data;
                                  return Times(
                                    inferenceTime: inferenceTime,
                                    fpsRate: fpsRate,
                                  );
                                },
                              );
                            },
                          ),
                          if (isFoldable) ...[
                            // Additional UI elements or adjustments for foldable screens
                            Positioned(
                              top: 50,
                              left: 50,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Foldable Mode',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 100,
                              right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      // 추가 기능 구현
                                    },
                                    child: Text('Additional Feature'),
                                  ),
                                  SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      // 설정 화면으로 이동
                                    },
                                    child: Text('Settings'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.cameraswitch),
            onPressed: () async {
              if (await isCameraReady()) {
                try {
                  await controller.toggleLensDirection();
                } catch (e) {
                  print('Error toggling lens direction: $e');
                }
              } else {
                print('Camera is not ready');
              }
            },
          ),
        ),
      );
    }
    catch (e, stackTrace) {
      print('Error in build method: $e');
      print('Stack trace: $stackTrace');
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('An error occurred: $e'),
          ),
        ),
      );
    }
  }

  Future<bool> isCameraReady() async {
    // 카메라 상태를 확인하는 로직을 구현합니다.
    // 예를 들어, controller의 상태를 확인하는 메서드를 호출할 수 있습니다.
    return _isCameraReady;
  }

  Future<ObjectDetector?> _initObjectDetectorWithLocalModel() async {
    // final modelPath = await _copy('assets/yolov8n.mlmodel');
    // final model = LocalYoloModel(
    //   id: '',
    //   task: Task.detect,
    //   format: Format.coreml,
    //   modelPath: modelPath,
    // );
    try {

      //final modelPath = await _copy('assets/yolov8n_int8.tflite');
      //final modelPath = await _copy('assets/test_int8.tflite');
      final modelPath = await _copy('assets/best_240825_320.tflite');
      //final metadataPath = await _copy('assets/metadata.yaml');
      final metadataPath = await _copy('assets/metadata_signboard.yaml');
      print('Model path: $modelPath');
      print('Metadata path: $metadataPath');
      final model = LocalYoloModel(
        id: '',
        task: Task.detect,
        format: Format.tflite,
        modelPath: modelPath,
        metadataPath: metadataPath,
      );
      return ObjectDetector(model: model);
    } catch (e) {
      print('Error initializing model: $e');
      return null;
    }

  }

  Future<ImageClassifier> _initImageClassifierWithLocalModel() async {
    final modelPath = await _copy('assets/yolov8n-cls.mlmodel');
    final model = LocalYoloModel(
      id: '',
      task: Task.classify,
      format: Format.coreml,
      modelPath: modelPath,
    );

    // final modelPath = await _copy('assets/yolov8n-cls.bin');
    // final paramPath = await _copy('assets/yolov8n-cls.param');
    // final metadataPath = await _copy('assets/metadata-cls.yaml');
    // final model = LocalYoloModel(
    //   id: '',
    //   task: Task.classify,
    //   modelPath: modelPath,
    //   paramPath: paramPath,
    //   metadataPath: metadataPath,
    // );

    return ImageClassifier(model: model);
  }

  Future<String> _copy(String assetPath) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$assetPath';
    await io.Directory(dirname(path)).create(recursive: true);
    final file = io.File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  Future<bool> _checkPermissions() async {
    // 카메라 권한 요청
    var cameraStatus = await Permission.camera.request();
    if (!cameraStatus.isGranted) {
      print('Camera permission denied');
      return false;
    }

    // Android 13 (SDK 33) 이상인지 확인
    if (io.Platform.isAndroid) {
      if (await Permission.storage.status.isPermanentlyDenied) {
        // Android 13 이상에서는 특정 미디어 타입에 대한 권한을 요청
        Map<Permission, PermissionStatus> statuses = await [
          Permission.photos,
          Permission.videos,
        ].request();

        if (statuses[Permission.photos] != PermissionStatus.granted ||
            statuses[Permission.videos] != PermissionStatus.granted) {
          print('Media permissions denied');
          return false;
        }
      } else {
        // Android 12 이하에서는 기존 저장소 권한 요청
        var storageStatus = await Permission.storage.request();
        if (!storageStatus.isGranted) {
          print('Storage permission denied');
          return false;
        }
      }
    }

    print('All required permissions granted');
    return true;
  }
}

class Times extends StatelessWidget {
  const Times({
    super.key,
    required this.inferenceTime,
    required this.fpsRate,
  });

  final double? inferenceTime;
  final double? fpsRate;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.black54,
            ),
            child: Text(
              '${(inferenceTime ?? 0).toStringAsFixed(1)} ms  -  ${(fpsRate ?? 0).toStringAsFixed(1)} FPS',
              style: const TextStyle(color: Colors.white70),
            )),
      ),
    );
  }
}
