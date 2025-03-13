import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/model/batch_model.dart';
import 'package:gyansagar_frontend/states/teacher/video/video_state.dart';
import 'package:gyansagar_frontend/ui/kit/overlay_loader.dart';
import 'package:gyansagar_frontend/ui/page/batch/pages/video/widget/batch_video_Card.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:gyansagar_frontend/ui/widget/p_loader.dart';
import 'package:provider/provider.dart';

class BatchVideosPage extends StatefulWidget {
  const BatchVideosPage({Key key, this.model, this.loader}) : super(key: key);
  final BatchModel model;
  final CustomLoader loader;
  static MaterialPageRoute getRoute(BatchModel model, CustomLoader loader) {
    return MaterialPageRoute(
        builder: (_) => BatchVideosPage(model: model, loader: loader));
  }

  @override
  _BatchVideosPageState createState() => _BatchVideosPageState();
}

class _BatchVideosPageState extends State<BatchVideosPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Consumer<VideoState>(
        builder: (context, state, child) {
          if (state.isBusy) {
            return Ploader();
          }
          if (state.list.isEmpty) {
            return Container(
              height: 100,
              margin: EdgeInsets.symmetric(horizontal: 16),
              width: AppTheme.fullWidth(context),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Nothing  to see here",
                      style: Theme.of(context).textTheme.titleLarge.copyWith(
                            color: PColors.gray,
                          )),
                  SizedBox(height: 10),
                  Text("No video is uploaded yet for this batch!!",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center),
                ],
              ),
            );
          }
          return ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            itemCount: state.list.length,
            itemBuilder: (_, index) {
              return BatchVideoCard(
                model: state.list[index],
                loader: widget.loader,
              );
            },
          );
        },
      ),
    );
  }
}
