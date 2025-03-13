import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/helper/images.dart';
import 'package:gyansagar_frontend/helper/utility.dart';
import 'package:gyansagar_frontend/model/video_model.dart';
import 'package:gyansagar_frontend/states/home_state.dart';
import 'package:gyansagar_frontend/states/teacher/batch_detail_state.dart';
import 'package:gyansagar_frontend/states/teacher/video/video_state.dart';
import 'package:gyansagar_frontend/ui/kit/alert.dart';
import 'package:gyansagar_frontend/ui/kit/overlay_loader.dart';
import 'package:gyansagar_frontend/ui/page/batch/pages/video/add_video_page.dart';
import 'package:gyansagar_frontend/ui/page/batch/pages/video/video_player_pag2e.dart';
import 'package:gyansagar_frontend/ui/page/batch/widget/tile_action_widget.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:gyansagar_frontend/ui/widget/p_chiip.dart';
import 'package:provider/provider.dart';

class BatchVideoCard extends StatelessWidget {
  const BatchVideoCard(
      {Key key,
      this.model,
      this.loader,
      this.actions = const ["Edit", "Delete"]})
      : super(key: key);

  final VideoModel model;
  final CustomLoader loader;
  final List<String> actions;

  Widget _picture(String url) {
    // return empty widget if space has no pictures
    if (!(url.contains("jpg") || url.contains("png"))) {
      return ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(5),
          bottomLeft: Radius.circular(5),
        ),
        child: Container(
          alignment: Alignment.center,
          color: Color(0xffeaeaea),
          child: url == null
              ? Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(Images.videoPlay),
                          fit: BoxFit.cover)),
                )
              : Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(30),
                    color: Color(0xffffffff),
                  ),
                  child: Center(child: Icon(Icons.play_arrow)),
                ),
        ),
      );
    }

    return // Picture
        ClipRRect(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
      child: Image.network(
        url != null ? url : "",
        fit: BoxFit.cover,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent loadingProgress) {
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes
                  : null,
            ),
          );
        },
      ),
    );
  }

  void deleteVideo(BuildContext context, String id) async {
    Alert.yesOrNo(context,
        message: "Are you sure, you want to delete this video ?",
        title: "Message",
        barrierDismissible: true,
        onCancel: () {}, onYes: () async {
      loader.showLoader(context);
      final isDeleted = await context.read<VideoState>().deleteVideo(id);
      await context.read<BatchDetailState>().getBatchTimeLine();
      if (isDeleted) {
        Utility.displaySnackbar(context, msg: "Video Deleted");
      }
      loader.hideLoader();
    });
  }

  void editVideo(BuildContext context, VideoModel model) {
    Navigator.push(
      context,
      AddVideoPage.getEditRoute(
        model,
        state: Provider.of<VideoState>(context, listen: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.decoration(context),
      margin: EdgeInsets.only(bottom: 12),
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: _picture(model.thumbnailUrl),
          ),
          Expanded(
              child: InkWell(
            onTap: () {
              Navigator.push(context,
                  VideoPlayerPage2.getRoute(model.video, title: model.title));
                        },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    model.title,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 3,
                  ),
                  // Text(model.description,style: Theme.of(context).textTheme.bodyText2,maxLines: 2, ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      PChip(
                        backgroundColor: PColors.randomColor(model.subject),
                        style: Theme.of(context).textTheme.bodyMedium.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                        borderColor: Colors.transparent,
                        label: model.subject ?? "N/A",
                      ),
                      Text(
                        Utility.toDMformate(model.createdAt),
                        style: Theme.of(context).textTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Theme.of(context).disabledColor),
                      )
                    ],
                  )
                ],
              ),
            ),
          )),
          if (context.watch<HomeState>().isTeacher)
            TileActionWidget(
              list: actions,
              onDelete: () => deleteVideo(context, model.id),
              onEdit: () => editVideo(context, model),
            ),
        ],
      ),
    );
  }
}
