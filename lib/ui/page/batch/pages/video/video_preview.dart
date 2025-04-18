import 'package:flutter/material.dart';

class ThumbnailPreview extends StatelessWidget {
  const ThumbnailPreview({super.key, required this.title, required this.url});
  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey(4),
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 20),
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Opacity(
                opacity: 0.5,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}