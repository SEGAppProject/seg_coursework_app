import 'package:flutter/material.dart';
import 'package:seg_coursework_app/models/image_details.dart';

class ImageSquare extends StatelessWidget {
  const ImageSquare({super.key, required this.image, this.height = 150, this.width = 200});

  final ImageDetails image;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      // padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Image.network(
        image.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (BuildContext context, Object exception,
            StackTrace? stackTrace) {
          return Text('!Error loading image! $exception');
        },
      ),
    );
      // child: Image.network(imageURL),
  }
}