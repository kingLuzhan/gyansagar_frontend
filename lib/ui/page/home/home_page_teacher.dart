import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/helper/images.dart';
import 'package:gyansagar_frontend/model/actor_model.dart';
import 'package:gyansagar_frontend/model/batch_model.dart'; // Import BatchModel
// Import AnnouncementModel
import 'package:gyansagar_frontend/states/home_state.dart';
import 'package:gyansagar_frontend/ui/kit/overlay_loader.dart';
import 'package:gyansagar_frontend/ui/page/announcement/create_announcement.dart';
import 'package:gyansagar_frontend/ui/page/batch/create_batch/create_batch.dart';
import 'package:gyansagar_frontend/ui/page/home/home_Scaffold.dart';
import 'package:gyansagar_frontend/ui/page/home/widget/announcement_widget.dart';
import 'package:gyansagar_frontend/ui/page/home/widget/batch_widget.dart';
import 'package:gyansagar_frontend/ui/page/home/widget/poll_widget.dart';
import 'package:gyansagar_frontend/ui/page/poll/View_all_poll_page.dart';
import 'package:gyansagar_frontend/ui/page/poll/create_poll.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:gyansagar_frontend/ui/widget/fab/fab_button.dart';
import 'package:gyansagar_frontend/ui/widget/p_title_text.dart';
import 'package:provider/provider.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});
  static MaterialPageRoute getRoute() {
    return MaterialPageRoute(builder: (_) => const TeacherHomePage());
  }

  @override
  _TeacherHomePageState createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage>
    with TickerProviderStateMixin {
  double _angle = 0;
  late AnimationController _controller;
  bool isOpened = false;
  late AnimationController _animationController;
  late CustomLoader loader;
  final Curve _curve = Curves.easeOut;
  late Animation<double> _translateButton;
  late Animation<double> _animateIcon;
  ValueNotifier<bool> showFabButton = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    setupAnimations();
    loader = CustomLoader();
    context.read<HomeState>().getBatchList();
    context.read<HomeState>().fetchAnnouncementList();
    context.read<HomeState>().getPollList();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _angle = .785;
      _animationController.forward();
    } else {
      _angle = 0;
      _animationController.reverse();
    }
    isOpened = !isOpened;
    showFabButton.value = !showFabButton.value;
  }

  setupAnimations() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
    _controller.repeat();
    _animationController =
    AnimationController(vsync: this, duration: const Duration(milliseconds: 200))
      ..addListener(() {
        setState(() {});
      });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _translateButton = Tween<double>(
      begin: 100,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        1,
        curve: _curve,
      ),
    ));
  }

  Widget _floatingActionButton() {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).primaryColor,
      onPressed: animate,
      tooltip: 'Toggle',
      child: AnimatedIcon(
        icon: AnimatedIcons.add_event,
        progress: _animateIcon,
      ),
    );
  }

  Widget _floatingActionButtonColumn() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: showFabButton.value ? 1 : 0,
      child: Column(
        children: <Widget>[
          FabButton(
            icon: Images.megaphone,
            text: 'Create Poll',
            animationValue: 3,
            translateButton: _translateButton,
            onPressed: () {
              animate();
              Navigator.push(context, CreatePoll.getRoute());
            },
          ),
          FabButton(
            icon: Images.peopleWhite,
            text: 'Create Batch',
            animationValue: 2,
            translateButton: _translateButton,
            onPressed: () {
              animate();
              Navigator.push(context, CreateBatch.getRoute(model: BatchModel(
                id: '',
                name: '',
                description: '',
                classes: [],
                subject: '',
                students: [],
                studentModel: [],
              )));
            },
          ),
          FabButton(
            icon: Images.announcements,
            text: 'Create Announcement',
            translateButton: _translateButton,
            animationValue: 1,
            onPressed: () {
              animate();
              Navigator.push(context, CreateAnnouncement.getRoute(
                batch: BatchModel(
                  id: '',
                  name: '',
                  description: '',
                  classes: [],
                  subject: '',
                  students: [],
                  studentModel: [],
                ),
                onAnnouncementCreated: () {
                  context.read<HomeState>().fetchAnnouncementList();
                },
              ));
            },
          ),
        ],
      ),
    );
  }

  Widget _title(String text) {
    return Padding(
        padding: const EdgeInsets.only(
          top: 8,
          left: 16,
        ),
        child: PTitleText(text));
  }

  @override
  Widget build(BuildContext context) {
    return HomeScaffold<HomeState>(
      floatingButtons: _floatingActionButtonColumn(),
      floatingActionButton: _floatingActionButton(),
      showFabButton: showFabButton,
      slivers: const [],
      onNotificationTap: () {
        print("Notification");
      },
      builder: (context, state, child) {
        return CustomScrollView(
          slivers: <Widget>[
            FutureBuilder<ActorModel?>(
              future: state.getUser(),
              builder: (context, AsyncSnapshot<ActorModel?> snapShot) {
                if (snapShot.hasData) {
                  return SliverToBoxAdapter(
                    child: Text("Hi, ${snapShot.data!.name}",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontSize: 22))
                        .hP16
                        .pT(10),
                  );
                } else {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
              },
            ),
            if (!(state.batchList.isNotEmpty))
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _title("Batches"),
                    const SizedBox(height: 20),
                    Container(
                      height: 100,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: AppTheme.outline(context),
                      width: AppTheme.fullWidth(context),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("You haven't created any batch yet",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                color: PColors.gray,
                              )),
                          const SizedBox(height: 10),
                          Text("Tap on below fab button to create new",
                              style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20)
                  ],
                ),
              ),
            if (state.batchList.isNotEmpty)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _title("You have ${state.batchList.length} Batches"),
                    const SizedBox(height: 5),
                    SizedBox(
                      height: 150,
                      width: AppTheme.fullWidth(context),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.batchList.length,
                        itemBuilder: (context, index) {
                          return BatchWidget(state.batchList[index]);
                        },
                      ),
                    ),
                    const SizedBox(height: 10)
                  ],
                ),
              ),
            const SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: 16),
                  Divider(),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  if (index == 0) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        _title("Poll"),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                                context, ViewAllPollPage.getRoute());
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Theme.of(context).primaryColor),
                          ),
                          child: Text("View All", style: TextStyle(color: Theme.of(context).primaryColor)),
                        ).hP16
                      ],
                    );
                  }
                  return PollWidget(
                      model: state.polls[index - 1], loader: loader);
                },
                childCount: state.polls.length + 1,
              ),
            ),
            const SliverToBoxAdapter(
              child: Divider(),
            ),
            if (state.announcementList.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    if (index == 0) {
                      return _title(
                          "${state.announcementList.length} Announcement");
                    }
                    return AnnouncementWidget(
                      state.announcementList[index - 1],
                      loader: loader,
                      onAnnouncementEdit: (model) {
                        Navigator.push(
                          context,
                          CreateAnnouncement.getEditRoute(
                            batch: state.batchList.firstWhere((batch) => batch.id == model.batches.first),
                            announcementModel: model,
                            onAnnouncementCreated: () {
                              context.read<HomeState>().fetchAnnouncementList();
                            },
                          ),
                        );
                      },
                      onAnnouncementDeleted: (model) async {
                        context.read<HomeState>().fetchAnnouncementList();
                      },
                    );
                  },
                  childCount: state.announcementList.length + 1,
                ),
              ),
          ],
        );
      },
    );
  }
}