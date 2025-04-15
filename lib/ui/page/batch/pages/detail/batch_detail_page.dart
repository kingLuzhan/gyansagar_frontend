import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/helper/images.dart';
import 'package:gyansagar_frontend/helper/utility.dart';
import 'package:gyansagar_frontend/model/batch_material_model.dart';
import 'package:gyansagar_frontend/model/batch_model.dart';
import 'package:gyansagar_frontend/model/batch_time_slot_model.dart';
import 'package:gyansagar_frontend/model/create_announcement_model.dart';
import 'package:gyansagar_frontend/model/video_model.dart';
import 'package:gyansagar_frontend/states/teacher/announcement_state.dart';
import 'package:gyansagar_frontend/states/teacher/batch_detail_state.dart';
import 'package:gyansagar_frontend/ui/kit/overlay_loader.dart';
import 'package:gyansagar_frontend/ui/page/announcement/create_announcement.dart';
import 'package:gyansagar_frontend/ui/page/batch/pages/detail/student_list.dart';
import 'package:gyansagar_frontend/ui/page/batch/pages/material/widget/batch_material_card.dart';
import 'package:gyansagar_frontend/ui/page/batch/pages/video/widget/batch_video_Card.dart';
import 'package:gyansagar_frontend/ui/page/home/widget/announcement_widget.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:gyansagar_frontend/ui/widget/p_avatar.dart';
import 'package:gyansagar_frontend/ui/widget/p_chiip.dart';
import 'package:gyansagar_frontend/ui/widget/p_loader.dart';
import 'package:provider/provider.dart';

class BatchDetailPage extends StatelessWidget {
  const BatchDetailPage({
    super.key,
    required this.batchModel,
    required this.loader,
  });

  final BatchModel batchModel;
  final CustomLoader loader;

  static MaterialPageRoute getRoute(BatchModel model, CustomLoader loader) {
    return MaterialPageRoute(
        builder: (_) => BatchDetailPage(batchModel: model, loader: loader));
  }

  Widget _title(BuildContext context, String text, {double fontSize = 22}) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontSize: fontSize, fontWeight: FontWeight.w500),
    );
  }

  Widget _timing(BuildContext context, BatchTimeSlotModel model) {
    return Text(
      "${model.toShortDay()}  ${Utility.timeFrom24(model.startTime)} - ${Utility.timeFrom24(model.endTime)}",
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16) ?? const TextStyle(fontSize: 16),
    );
  }

  Widget _students(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        children: batchModel.studentModel
            .map((model) => SizedBox(
          height: 35,
          child: Padding(
            padding: const EdgeInsets.only(right: 5),
            child: UsernameWidget(
              name: model.name,
              textStyle: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 12,
                color: theme.colorScheme.onPrimary,
              ) ?? TextStyle(fontSize: 12, color: theme.colorScheme.onPrimary),
              backGroundColor: PColors.randomColor(model.name),
            ),
          ),
        ))
            .toList(),
      ),
    );
  }

  Future<void> onAnnouncementDeleted(
      BuildContext context, AnnouncementModel model) async {
    context.read<AnnouncementState>().onAnnouncementDeleted(model);
    await context.read<BatchDetailState>().getBatchTimeLine();
    return Future.value(); // Ensure a non-null Future is returned
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildListDelegate(
            [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: _title(context, batchModel.name),
                    ),
                    Wrap(
                      children: <Widget>[
                        PChip(
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ) ?? TextStyle(color: theme.colorScheme.onPrimary),
                          borderColor: Colors.transparent,
                          label: batchModel.subject,
                          backgroundColor: PColors.randomColor(batchModel.subject),
                        ),
                      ],
                    ),
                    const SizedBox(height: 19),
                    Row(
                      children: <Widget>[
                        Image.asset(Images.calender, width: 20),
                        const SizedBox(width: 10),
                        _title(context, "${batchModel.classes.length} Classes",
                            fontSize: 18),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 11),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: batchModel.classes
                      .map((e) => Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: _timing(context, e),
                  ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(Images.peopleBlack, width: 20),
                    const SizedBox(width: 10),
                    _title(context, "${batchModel.studentModel.length} Student",
                        fontSize: 18),
                    const Spacer(),
                    SizedBox(
                      height: 30,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              StudentListPage.getRoute(
                                  batchModel.studentModel));
                        },
                        child: const Text("View All"),
                      ),
                    )
                  ],
                ),
              ),
              _students(theme),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: Divider(height: 1, thickness: 1)),
        Consumer<AnnouncementState>(
          builder: (context, state, child) {
            if (state.isBusy) {
              return const SliverToBoxAdapter(child: PCLoader(stroke: 2));
            }
            if (state.batchAnnouncementList.isNotEmpty) {
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _title(context, "Recent Announcement",
                            fontSize: 18),
                      );
                    }
                    return AnnouncementWidget(
                      state.batchAnnouncementList[index - 1],
                      loader: loader,
                      onAnnouncementDeleted: (model) async {
                        await onAnnouncementDeleted(context, model);
                      },
                      onAnnouncementEdit: (model) {
                        Navigator.push(
                          context,
                          CreateAnnouncement.getEditRoute(
                            batch: batchModel,
                            announcementModel: model,
                            onAnnouncementCreated: () {
                              // if an announcement is created or edited then
                              // refresh timelime api
                              context
                                  .read<BatchDetailState>()
                                  .getBatchTimeLine();
                            },
                          ),
                        );
                      },
                    );
                  },
                  childCount: state.batchAnnouncementList.length + 1,
                ),
              );
            }

            return const SliverToBoxAdapter();
          },
        ),
        // Batch video, announcement, study material timeline
        // In the Consumer<BatchDetailState> section:
        Consumer<BatchDetailState>(builder: (context, state, child) {
          if (state.isBusy) {
            return const SliverToBoxAdapter(child: PCLoader(stroke: 2));
          }
          
          if (state.timeLineList != null && state.timeLineList!.isNotEmpty) {
            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _title(context, "Batch Timeline", fontSize: 18),
                  );
                }
                final model = state.timeLineList![index - 1];
                
                // Handle different types of timeline items
                switch(model.type) {
                  case 'video':
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: BatchVideoCard(
                        model: model.datum,
                        loader: loader,
                        actions: const ["Delete"],
                      ),
                    );
                  case 'announcement':
                    return Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: AnnouncementWidget(
                        model.datum,
                        actions: const ["Delete"],
                        loader: loader,
                        onAnnouncementDeleted: (announcementModel) async {
                          await onAnnouncementDeleted(context, announcementModel);
                        },
                        onAnnouncementEdit: (announcementModel) {
                          Navigator.push(
                            context,
                            CreateAnnouncement.getEditRoute(
                              batch: batchModel,
                              announcementModel: announcementModel,
                              onAnnouncementCreated: () {
                                context.read<BatchDetailState>().getBatchTimeLine();
                              },
                            ),
                          );
                        },
                      ),
                    );
                  case 'material':
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: BatchMaterialCard(
                        model: model.datum,
                        loader: loader,
                        actions: const ["Delete"],
                      ),
                    );
                  default:
                    print("Unknown timeline item type: ${model.type}");
                    return const SizedBox();
                }
              }, childCount: state.timeLineList!.length + 1),
            );
          }
          
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("No timeline items available"),
            ),
          );
        }),
        const SliverToBoxAdapter(child: SizedBox(height: 70))
      ],
    );
  }
}