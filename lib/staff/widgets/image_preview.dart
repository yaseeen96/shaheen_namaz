import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview({
    super.key,
    required this.onTap,
    this.image,
  });
  final void Function() onTap;
  final XFile? image;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Stack(
        children: [
          Ink(
            height: (image != null) ? 200 : null,
            width: (image != null) ? 200 : null,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              image: (image != null)
                  ? DecorationImage(
                      image: FileImage(
                        File(image!.path),
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
              shape: BoxShape.circle,
              color: (image == null) ? Colors.grey[300] : null,
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
              ),
            ),
            child: (image == null)
                ? const Icon(
                    Icons.camera,
                    size: 150,
                  )
                : null,
          ),
          if (image == null)
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
