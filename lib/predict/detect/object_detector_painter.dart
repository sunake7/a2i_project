import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/predict/detect/detected_object.dart';

/// A painter used to draw the detected objects on the screen.

class ObjectDetectorPainter extends CustomPainter {
  /// Creates a [ObjectDetectorPainter].
  ObjectDetectorPainter(
    this._detectionResults, [
    this._colors,
    this._strokeWidth = 2.5,
  ]);

  final List<DetectedObject> _detectionResults;
  final List<Color>? _colors;
  final double _strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;
    final colors = _colors ?? Colors.primaries;

    for (final detectedObject in _detectionResults) {
      final left = detectedObject.boundingBox.left;
      final top = detectedObject.boundingBox.top;
      final right = detectedObject.boundingBox.right;
      final bottom = detectedObject.boundingBox.bottom;
      final width = detectedObject.boundingBox.width;
      final height = detectedObject.boundingBox.height;

      // NaN 값이 있으면 생략
      if (left.isNaN || top.isNaN || right.isNaN || bottom.isNaN || width.isNaN || height.isNaN) {
        return;
      }

      // 블러 처리할 영역 정의
      final blurRect = Rect.fromLTWH(left, top, width, height);

      // 레이어를 블러 필터로 저장하여 해당 영역에 블러 처리
      canvas.saveLayer(blurRect, Paint());
      canvas.drawRect(
        blurRect,
        Paint()..imageFilter = ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
