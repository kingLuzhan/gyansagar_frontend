import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/helper/images.dart';
import 'package:gyansagar_frontend/helper/utility.dart';
import 'package:gyansagar_frontend/model/create_announcement_model.dart';
import 'package:gyansagar_frontend/states/home_state.dart';
import 'package:gyansagar_frontend/ui/kit/alert.dart';
import 'package:gyansagar_frontend/ui/kit/overlay_loader.dart';
import 'package:gyansagar_frontend/ui/page/batch/widget/tile_action_widget.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:gyansagar_frontend/ui/widget/url_Text.dart';
import 'package:provider/provider.dart';

class AnnouncementWidget extends StatelessWidget {
  const AnnouncementWidget(this.model,
      {Key? key,
        required this.loader,
        required this.onAnnouncementDeleted,
        required this.onAnnouncementEdit,
        this.actions = const ["Edit", "Delete"]})
      : super(key: key);
  final AnnouncementModel model;
  final CustomLoader loader;
  final List<String> actions;
  final Future Function(AnnouncementModel) onAnnouncementDeleted;
  final Function(AnnouncementModel) onAnnouncementEdit;

  void deleteAnnouncement(BuildContext context, String id) async {
    Alert.yesOrNo(context,
        message: "Are you sure, you want to delete this announcement?",
        title: "Message",
        barrierDismissible: true,
        onCancel: () {}, onYes: () async {
          loader.showLoader(context);
          final isDeleted = await Provider.of<HomeState>(context, listen: false)
              .deleteAnnouncement(id);
          if (isDeleted) {
            Utility.displaySnackbar(context, msg: "Announcement Deleted");
            await onAnnouncementDeleted(model);
          }
          loader.hideLoader();
        });
  }

  @override
  Widget build(BuildContext context) {
    var isTeacher = context.watch<HomeState>().isTeacher;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: AppTheme.decoration(context)
          .copyWith(color: Theme.of(context).primaryColor),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  child: Container(
                    child: Image.asset(
                      Images.megaphone,
                      fit: BoxFit.contain,
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 12,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Theme.of(context).colorScheme.onPrimary,
                      padding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 16) +
                          EdgeInsets.only(right: isTeacher ? 10 : 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          UrlText(text: model.description),
                          SizedBox(height: 8),
                          if (model.image.isNotEmpty) ...[
                            CachedNetworkImage(
                                imageUrl: model.image, height: 120),
                            SizedBox(height: 8),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Image.asset(
                                  Images.getFileTypeIcon(model.file),
                                  height: 20),
                              SizedBox(width: 8),
                              RotatedBox(
                                quarterTurns: 1,
                                child: Icon(Icons.attach_file_outlined),
                              )
                            ],
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    "by ${model.owner.name} ~ ",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Text(
                                  Utility.toTimeOfDate(model.createdAt),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).extended,
                  ],
                ),
              ),
            ],
          ).ripple(() {
            Utility.launchOnWeb(model.file);
          }),
          if (isTeacher)
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              child: Container(
                width: 20,
                alignment: Alignment.topRight,
                color: Theme.of(context).colorScheme.onPrimary,
                child: TileActionWidget(
                  list: actions,
                  onDelete: () => deleteAnnouncement(context, model.id),
                  onEdit: () => onAnnouncementEdit(model),
                ),
              ),
            )
        ],
      ),
    );
  }
}