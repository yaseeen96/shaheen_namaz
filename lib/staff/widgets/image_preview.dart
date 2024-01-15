import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview({
    super.key,
    required this.onTap,
  });
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Stack(
        children: [
          Ink(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
                border: const GradientBoxBorder(
                  width: 6,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff002B5E),
                      Color(0xffED1A23),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                )),
            child: const Icon(
              Icons.camera,
              size: 150,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 25,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff002B5E),
                      Color(0xffED1A23),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  )),
              child: const Icon(
                Icons.add_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
