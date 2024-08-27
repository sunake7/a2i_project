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

      // 레이블 그리기 (원본 코드 유지)
      final index = detectedObject.index % colors.length;
      final color = colors[index];

      // 레이블을 해당 객체 위에 그리기
      final builder = ui.ParagraphBuilder(
        ui.ParagraphStyle(
          textAlign: TextAlign.left,
          fontSize: 16,
          textDirection: TextDirection.ltr,
        ),
      )
        ..pushStyle(
          ui.TextStyle(
            color: Colors.white,
            background: Paint()..color = color.withOpacity(0.7),
          ),
        )
        ..addText(' ${detectedObject.label} '
            '${(detectedObject.confidence * 100).toStringAsFixed(1)}%\n')
        ..pop();

      canvas.drawParagraph(
        builder.build()..layout(ui.ParagraphConstraints(width: width)),
        Offset(max(0, left), max(0, top)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
