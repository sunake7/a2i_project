import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/predict/detect/detected_object.dart';

class ObjectDetectorBlur extends StatelessWidget {
  final List<DetectedObject> detectionResults;

  const ObjectDetectorBlur({
    Key? key,
    required this.detectionResults,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: detectionResults.map((detectedObject) {
        final left = detectedObject.boundingBox.left;
        final top = detectedObject.boundingBox.top;
        final width = detectedObject.boundingBox.width;
        final height = detectedObject.boundingBox.height;

        // NaN 값이 있으면 생략
        if (left.isNaN || top.isNaN || width.isNaN || height.isNaN) {
          return Container();
        }

        return Positioned(
          left: left,
          top: top,
          width: width,
          height: height,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.transparent, // 투명한 컨테이너로 해당 영역에만 블러 적용
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}