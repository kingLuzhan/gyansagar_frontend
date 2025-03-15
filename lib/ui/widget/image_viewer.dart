import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/ui/widget/secondary_app_bar.dart';

class ImageViewer extends StatelessWidget {
  static MaterialPageRoute getRoute(String path) {
    return MaterialPageRoute(
      builder: (_) => ImageViewer(
        path: path,
      ),
    );
  }

  const ImageViewer({super.key, required this.path}); // Marked 'key' as nullable and 'path' as required
  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(""),
      body: Container(
        child: Center(
          child: InteractiveViewer(
            minScale: .3,
            maxScale: 5,
            child: CachedNetworkImage(imageUrl: path),
          ),
        ),
      ),
    );
  }
}