import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/helper/images.dart';
import 'package:gyansagar_frontend/model/batch_model.dart';
import 'package:gyansagar_frontend/model/video_model.dart';
import 'package:gyansagar_frontend/model/batch_material_model.dart';
import 'package:gyansagar_frontend/states/home_state.dart';
import 'package:gyansagar_frontend/states/teacher/announcement_state.dart';
import 'package:gyansagar_frontend/states/quiz/quiz_state.dart';
import 'package:gyansagar_frontend/states/teacher/batch_detail_state.dart';
import 'package:gyansagar_frontend/states/teacher/material/batch_material_state.dart';
import 'package:gyansagar_frontend/states/teacher/video/video_state.dart';
import 'package:gyansagar_frontend/ui/kit/alert.dart';
import 'package:gyansagar_frontend/ui/kit/overlay_loader.dart';
import 'package:gyansagar_frontend/ui/page/announcement/create_announcement.dart';
import 'package:gyansagar_frontend/ui/page/batch/create_batch/create_batch.dart';
import 'package:gyansagar_frontend/ui/page/batch/pages/batch_assignment_page.dart';
import 'package:gyansagar_frontend/ui/page/batch/pages/material/batch_study_material_page.dart';
import 'package:gyansagar_frontend/ui/page/batch/pages/detail/batch_detail_page.dart';
import 'package:gyansagar_frontend/ui/page/batch/pages/material/upload_material.dart';
import 'package:gyansagar_frontend/ui/page/batch/pages/video/add_video_page.dart';
import 'package:gyansagar_frontend/ui/page/batch/pages/video/batch_videos_page.dart';
import 'package:gyansagar_frontend/model/choice.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:gyansagar_frontend/ui/widget/fab/animated_fab.dart';
import 'package:gyansagar_frontend/ui/widget/fab/fab_button.dart';
import 'package:provider/provider.dart';
import 'package:gyansagar_frontend/ui/page/chat/batch_chat_tab.dart'; // <-- Add this import

class BatchMasterDetailPage extends StatefulWidget {
  const BatchMasterDetailPage({
    super.key,
    required this.model,
    required this.isTeacher,
  });
  final BatchModel model;
  final bool isTeacher;
  static MaterialPageRoute getRoute(
    BatchModel model, {
    required bool isTeacher,
  }) {
    return MaterialPageRoute(
      builder:
          (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create:
                    (_) => VideoState(
                      batchId: model.id,
                      subject: model.subject,
                      videoModel: VideoModel(
                        id: '',
                        title: '',
                        description: '',
                        subject: '',
                        videoUrl: '',
                        thumbnailUrl: '',
                        batchId: '',
                        createdAt: DateTime.now().toIso8601String(),
                      ),
                    ),
              ),
              ChangeNotifierProvider(
                create: (_) => BatchDetailState(batchId: model.id),
              ),
              ChangeNotifierProvider(
                create:
                    (_) => BatchMaterialState(
                      batchId: model.id,
                      subject: model.subject,
                      materialModel: BatchMaterialModel(
                        id: '',
                        fileUrl: '',
                        title: '',
                        subject: '',
                        description: '',
                        batchId: '',
                        filePath: '',
                        isPrivate: false,
                        fileUploadedOn: '',
                        createdAt: DateTime.now(), // Use DateTime directly
                        updatedAt: DateTime.now(), // Use DateTime directly
                      ),
                    ),
              ),
              ChangeNotifierProvider(
                create: (_) => AnnouncementState(batchId: model.id),
              ),
              ChangeNotifierProvider(
                create: (_) => QuizState(batchId: model.id),
              ),
            ],
            builder:
                (_, child) =>
                    BatchMasterDetailPage(model: model, isTeacher: isTeacher),
          ),
    );
  }

  @override
  _BatchMasterDetailPageState createState() => _BatchMasterDetailPageState();
}

class _BatchMasterDetailPageState extends State<BatchMasterDetailPage>
    with TickerProviderStateMixin {
  double _angle = 0;
  late BatchModel model;
  late AnimationController _controller;
  late TabController _tabController;
  bool isOpened = false;
  late AnimationController _animationController;
  final Curve _curve = Curves.easeOut;
  late CustomLoader loader;
  late Animation<double> _translateButton;
  final ValueNotifier<bool> showFabButton = ValueNotifier<bool>(false);
  final ValueNotifier<int> currentPageNo = ValueNotifier<int>(0);

  final List<Choice> choices = [
    const Choice(title: 'Edit', index: 0),
    const Choice(title: 'Delete', index: 1),
  ];

  @override
  void initState() {
    super.initState();
    loader = CustomLoader();
    model = widget.model;
    setupAnimations();
    _tabController = TabController(
      length: 5,
      vsync: this,
    ) // <-- Change length to 5
    ..addListener(tabListener);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<VideoState>(context, listen: false).getVideosList();
      Provider.of<BatchMaterialState>(
        context,
        listen: false,
      ).getBatchMaterialList();
      Provider.of<AnnouncementState>(
        context,
        listen: false,
      ).getBatchAnnouncementList();
      Provider.of<QuizState>(context, listen: false).getQuizList();
      Provider.of<BatchDetailState>(context, listen: false).getBatchTimeLine();
    });
    super.initState();
  }

  void tabListener() {
    currentPageNo.value = _tabController.index;
  }

  @override
  void dispose() {
    showFabButton.dispose();
    _animationController.dispose();
    _tabController.dispose();
    _controller.dispose();
    currentPageNo.dispose();
    super.dispose();
  }

  void setupAnimations() {
    if (!widget.isTeacher) {
      return;
    }
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _controller.repeat();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
      setState(() {});
    });

    _translateButton = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 1.0, curve: _curve),
      ),
    );
  }

  void animate() {
    if (!isOpened) {
      _angle = .785;
      _animationController.forward();
    } else {
      _angle = 0;
      _animationController.reverse();
      _angle = 0;
    }
    isOpened = !isOpened;
    showFabButton.value = !showFabButton.value;
  }

  Widget _floatingActionButton() {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).primaryColor,
      onPressed: animate,
      tooltip: 'Toggle',
      child: Transform.rotate(
        angle: _angle,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  List<Widget> _floatingButtons(int index) {
    return <Widget>[
      if (index != 5) ...[
        FabButton(
          icon: Images.edit,
          text: 'Add  Video',
          translateButton: _translateButton,
          animationValue: 3,
          onPressed: () {
            animate();
            Navigator.push(
              context,
              AddVideoPage.getRoute(
                subject: model.subject,
                batchId: model.id,
                state: Provider.of<VideoState>(context, listen: false),
              ),
            );
          },
        ),
        FabButton(
          icon: Images.upload,
          text: 'Upload Material',
          animationValue: 2,
          translateButton: _translateButton,
          onPressed: () {
            animate();
            Navigator.push(
              context,
              UploadMaterialPage.getRoute(
                subject: model.subject,
                batchId: model.id,
                state: Provider.of<BatchMaterialState>(context, listen: false),
              ),
            );
          },
        ),
        FabButton(
          icon: Images.announcements,
          text: 'Add Announcement',
          translateButton: _translateButton,
          animationValue: 1,
          onPressed: () {
            animate();
            final model = widget.model;
            model.isSelected = true;
            Navigator.push(
              context,
              CreateAnnouncement.getRoute(
                batch: model,
                onAnnouncementCreated: onAnnouncementCreated,
              ),
            );
          },
        ),
      ],
    ];
  }

  void onAnnouncementCreated() async {
    Provider.of<AnnouncementState>(
      context,
      listen: false,
    ).getBatchAnnouncementList();

    context.read<BatchDetailState>().getBatchTimeLine();
  }

  void deleteBatch() async {
    Alert.yesOrNo(
      context,
      message: "Are you sure, you want to delete this batch ?",
      title: "Message",
      barrierDismissible: true,
      onCancel: () {},
      onYes: () async {
        loader.showLoader(context);
        final isDeleted = await Provider.of<HomeState>(
          context,
          listen: false,
        ).deleteBatch(widget.model.id);
        if (isDeleted) {
          Navigator.pop(context);
        }
        loader.hideLoader();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // <-- Change length to 5
      child: Scaffold(
        floatingActionButton:
            !widget.isTeacher ? null : _floatingActionButton(),
        appBar: AppBar(
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Theme.of(context).textTheme.bodyLarge?.color,
            tabs: const [
              Tab(text: "Detail"),
              Tab(text: "Videos"),
              Tab(text: "Chat"), // <-- Add this tab
              Tab(text: "Quiz"),
              Tab(text: "Study Material"),
            ],
          ),
          title: Title(color: PColors.black, child: Text(model.name)),
          actions: [
            if (widget.isTeacher)
              PopupMenuButton<Choice>(
                onSelected: (d) {
                  if (d.index == 1) {
                    deleteBatch();
                  } else if (d.index == 0) {
                    Navigator.push(
                      context,
                      CreateBatch.getRoute(model: widget.model),
                    );
                  }
                },
                padding: EdgeInsets.zero,
                offset: const Offset(40, 20),
                color: Colors.white,
                itemBuilder: (BuildContext context) {
                  return choices.map((Choice choice) {
                    return PopupMenuItem<Choice>(
                      value: choice,
                      child: Text(choice.title),
                    );
                  }).toList();
                },
              ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            TabBarView(
              controller: _tabController,
              children: [
                BatchDetailPage(batchModel: model, loader: loader),
                BatchVideosPage(model: model, loader: loader),
                BatchChatTab(batchModel: model), // <-- Add this widget
                BatchAssignmentPage(model: model, loader: loader),
                BatchStudyMaterialPage(model: model, loader: loader),
              ],
            ),
            if (widget.isTeacher)
              ValueListenableBuilder<int>(
                valueListenable: currentPageNo,
                builder: (BuildContext context, int index, Widget? child) {
                  return AnimatedFabButton(
                    showFabButton: showFabButton,
                    children: _floatingButtons(index),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
