import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/helper/images.dart';
import 'package:gyansagar_frontend/model/actor_model.dart';
import 'package:gyansagar_frontend/states/home_state.dart';
import 'package:gyansagar_frontend/ui/page/home/home_Scaffold.dart';
import 'package:gyansagar_frontend/ui/page/home/widget/announcement_widget.dart';
import 'package:gyansagar_frontend/ui/page/home/widget/batch_widget.dart';
import 'package:gyansagar_frontend/ui/page/home/widget/poll_widget.dart';
import 'package:gyansagar_frontend/ui/page/notification/notifications_page.dart';
import 'package:gyansagar_frontend/ui/page/poll/View_all_poll_page.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:gyansagar_frontend/ui/widget/p_title_text.dart';
import 'package:provider/provider.dart';
import 'package:gyansagar_frontend/ui/kit/overlay_loader.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({Key? key}) : super(key: key);
  static MaterialPageRoute getRoute() {
    return MaterialPageRoute(builder: (_) => const StudentHomePage());
  }

  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  bool isOpened = false;
  late AnimationController _animationController;
  Curve _curve = Curves.easeOut;
  late Animation<double> _translateButton;
  bool showFabButton = false;
  double _angle = 0;
  late CustomLoader loader;

  @override
  void initState() {
    super.initState();
    setupAnimations();
    loader = CustomLoader();
    Provider.of<HomeState>(context, listen: false).getBatchList();
    Provider.of<HomeState>(context, listen: false).fetchAnnouncementList();
    Provider.of<HomeState>(context, listen: false).getPollList();
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
    showFabButton = !showFabButton;
  }

  setupAnimations() {
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    _controller.repeat();
    _animationController =
    AnimationController(vsync: this, duration: Duration(milliseconds: 200))
      ..addListener(() {
        setState(() {});
      });
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
      child: Transform.rotate(
        angle: _angle,
        child: const Icon(
          Icons.add,
          size: 30,
        ),
      ),
    );
  }

  Widget _floatingActionButtonColumn() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: showFabButton ? 1 : 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          _smallFabButton(
            Images.announcements,
            text: 'Notifications',
            animationValue: 1,
            onPressed: () {
              animate();
              Navigator.push(context, NotificationPage.getRoute());
            },
          ),
        ],
      ),
    );
  }

  Widget _smallFabButton(String icon,
      {required Function onPressed, required double animationValue, String text = ''}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Transform(
        transform: Matrix4.translationValues(
          _translateButton.value * animationValue,
          0.0,
          0.0,
        ),
        child: Material(
          elevation: 4,
          color: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                topRight: Radius.circular(40)),
          ),
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    topRight: Radius.circular(40)),
                color: Theme.of(context).primaryColor,
              ),
              child: Row(
                children: <Widget>[
                  Image.asset(icon, height: 20),
                  const SizedBox(width: 8),
                  Text(text,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary)),
                ],
              )).ripple(
            onPressed,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              topRight: Radius.circular(40),
            ),
          ),
        ),
      ),
    );
  }

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16,
        left: 16,
      ),
      child: PTitleText(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HomeScaffold<HomeState>(
      floatingButtons: _floatingActionButtonColumn(),
      floatingActionButton: _floatingActionButton(),
      showFabButton: ValueNotifier<bool>(showFabButton),
      slivers: [],
      onNotificationTap: () {
        Navigator.push(context, NotificationPage.getRoute());
      },
      builder: (context, state, child) {
        return CustomScrollView(
          slivers: <Widget>[
            if (!(state.batchList.isNotEmpty))
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    FutureBuilder<ActorModel?>(
                        future: state.getUser(),
                        builder: (context, AsyncSnapshot<ActorModel?> snapShot) {
                          if (snapShot.hasData) {
                            return PTitleTextBold("Hi, ${snapShot.data!.name}")
                                .hP16
                                .pT(10);
                          } else {
                            return const SizedBox.shrink();
                          }
                        }),
                    _title("My Batches"),
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
                            Text("You have no batch",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                  color: PColors.gray,
                                )),
                            const SizedBox(height: 10),
                            Text("Ask your teacher to add you in a batch!!",
                                style: Theme.of(context).textTheme.bodyLarge),
                          ],
                        ))
                  ],
                ),
              ),
            if (state.batchList.isNotEmpty)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _title("${state.batchList.length} Batches"),
                    const SizedBox(height: 5),
                    Container(
                      height: 150,
                      width: AppTheme.fullWidth(context),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.batchList.length,
                        itemBuilder: (context, index) {
                          return BatchWidget(
                            state.batchList[index],
                            isTeacher: false,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10)
                  ],
                ),
              ),
            SliverToBoxAdapter(
              child: Column(
                children: const [
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
                        PTitleText("Poll").hP16,
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
                      model: state.polls[index - 1],
                      loader: loader,
                      hideFinishButton: false);
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
                    if (index == 0) return _title("Announcement");
                    return AnnouncementWidget(
                      state.announcementList[index - 1],
                      loader: loader,
                      onAnnouncementEdit: (model) {
                        // Handle announcement edit
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