import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/helper/images.dart';
import 'package:gyansagar_frontend/helper/utility.dart';
import 'package:gyansagar_frontend/model/video_model.dart';
import 'package:gyansagar_frontend/states/teacher/video/video_state.dart';
import 'package:gyansagar_frontend/ui/kit/alert.dart';
import 'package:gyansagar_frontend/ui/page/batch/pages/video/video_preview.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:gyansagar_frontend/ui/widget/form/p_textfield.dart';
import 'package:gyansagar_frontend/ui/widget/p_button.dart';
import 'package:gyansagar_frontend/ui/widget/p_chiip.dart';
import 'package:gyansagar_frontend/ui/widget/secondary_app_bar.dart';
import 'package:provider/provider.dart';

class AddVideoPage extends StatefulWidget {
  final String subject;
  final VideoState state;
  final VideoModel videoModel;
  const AddVideoPage({
    Key? key,
    required this.subject,
    required this.state,
    required this.videoModel,
  }) : super(key: key);

  static MaterialPageRoute getRoute(
      {required String subject, required String batchId, required VideoState state}) {
    return MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider<VideoState>(
        create: (context) => VideoState(
          subject: subject,
          batchId: batchId,
          videoModel: VideoModel(
            id: '',
            title: '',
            description: '',
            subject: subject,
            videoUrl: '',
            thumbnailUrl: '',
            batchId: batchId,
            createdAt: DateTime.now().toIso8601String(), // Assign current date
          ),
        ),
        child: AddVideoPage(subject: subject, state: state, videoModel: VideoModel(
          id: '',
          title: '',
          description: '',
          subject: subject,
          videoUrl: '',
          thumbnailUrl: '',
          batchId: batchId,
          createdAt: DateTime.now().toIso8601String(), // Assign current date
        )),
      ),
    );
  }

  static MaterialPageRoute getEditRoute(VideoModel videoModel,
      {required VideoState state}) {
    return MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider<VideoState>(
        create: (context) => VideoState(
          subject: videoModel.subject,
          batchId: videoModel.batchId,
          videoModel: videoModel,
          isEditMode: true,
        ),
        child: AddVideoPage(
            subject: videoModel.subject, videoModel: videoModel, state: state),
      ),
    );
  }

  @override
  _AddVideoPageState createState() => _AddVideoPageState();
}

class _AddVideoPageState extends State<AddVideoPage> {
  late TextEditingController _description;
  late TextEditingController _title;
  final _formKey = GlobalKey<FormState>();
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  final GlobalKey<ScaffoldMessengerState> scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  @override
  void initState() {
    _description = TextEditingController(text: widget.videoModel.description);
    _title = TextEditingController(text: widget.videoModel.title);
    super.initState();
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Widget _titleText(BuildContext context, String name) {
    return Text(
      name,
      style: Theme.of(context)
          .textTheme
          .bodyLarge
          ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  Widget _secondaryButton(BuildContext context,
      {required String label, required VoidCallback onPressed}) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(Icons.add_circle, color: PColors.primary, size: 17),
        label: Text(
          label,
          style: theme.textTheme.labelLarge
              ?.copyWith(color: PColors.primary, fontWeight: FontWeight.bold),
        ));
  }

  void addLink() async {
    // Your add link logic
  }

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'avi', "flv", "mkv", "mov"],
    );
    if (result != null) {
      PlatformFile file = result.files.first;
      final state = Provider.of<VideoState>(context, listen: false);
      state.setFile = File(file.path!);
    }
  }

  void saveVideo() async {
    final state = context.read<VideoState>();
    // validate batch name and batch description
    final isTrue = _formKey.currentState?.validate() ?? false;
    FocusManager.instance.primaryFocus?.unfocus();
    if (!isTrue) {
      return;
    }
    if (state.file == null && state.videoUrl == null) {
      Utility.displaySnackbar(context,
          msg: "please add a video link or upload a video", key: scaffoldKey);
      return;
    }
    isLoading.value = true;

    final isOk = await state.addVideo(_title.text, _description.text);
    isLoading.value = false;
    if (isOk) {
      String message = "Video added successfully!!";
      if (state.isEditMode) {
        message = "Video updated successfully!!";
      }
      widget.state.getVideosList();
      Alert.success(context, message: message, title: "Message", onPressed: () {
        Navigator.pop(context);
      });
    } else {
      Alert.success(context,
          message: "Some error occurred. Please try again in some time!!",
          title: "Message",
          height: 170,
          onPressed: () {
            Navigator.pop(context);
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xffeeeeee),
        appBar: CustomAppBar("Add Video"),
        body: Container(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    color: Color(0xfffafafa),
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 16),
                        PTextField(
                          type: FieldType.text,
                          controller: _title,
                          label: "Title",
                          hintText: "Enter title here",
                          maxLines: 1,
                          height: 70, // Provide a non-null value
                        ),
                        SizedBox(height: 16),
                        PTextField(
                            type: FieldType.optional,
                            controller: _description,
                            label: "Description",
                            hintText: "Enter here",
                            maxLines: 1,
                            height: 70, // Provide a non-null value
                            padding: EdgeInsets.symmetric(vertical: 16)),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            _titleText(context, "Subject"),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(right: 4, top: 10),
                              child: PChip(
                                label: widget.subject,
                                backgroundColor:
                                PColors.randomColor(widget.subject),
                                borderColor: Colors.transparent,
                                style: TextStyle(color: Colors.white),
                                isCrossIcon: false,
                                onDeleted: () {},
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _titleText(context, "Add Link"),
                      _secondaryButton(context,
                          label: "Add", onPressed: addLink),
                    ],
                  ).p16,
                  Container(
                    width: AppTheme.fullWidth(context),
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: AppTheme.outline(context),
                    child: Column(
                      children: <Widget>[
                        Text("Browse file",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        Image.asset(Images.uploadVideo, height: 25).vP16,
                        Text("File should be mp4,mov,avi",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontSize: 12, color: PColors.gray)),
                      ],
                    ),
                  ).ripple(pickFile),
                  Consumer<VideoState>(
                    builder: (context, state, child) {
                      return SizedBox(
                        height: 65,
                        width: AppTheme.fullWidth(context),
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 10),
                            Row(children: <Widget>[
                              SizedBox(
                                  width: 50,
                                  child: Image.asset(
                                    Images.getFileTypeIcon(
                                        state.file.path.split(".").last),
                                    height: 30,
                                  )),
                              Text(
                                state.file.path.split("/").last,
                                maxLines: 2,
                              ).extended,
                              IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(Icons.cancel),
                                  onPressed: () {
                                    state.removeFile();
                                  })
                            ]),
                            Container(
                              height: 5,
                              margin: EdgeInsets.symmetric(horizontal: 16),
                              width: AppTheme.fullWidth(context),
                              decoration: BoxDecoration(
                                  color: Color(0xff0CC476),
                                  borderRadius: BorderRadius.circular(20)),
                            )
                          ],
                        ),
                      ).vP8;
                                          return SizedBox();
                    },
                  ),
                  SizedBox(height: 20),
                  Consumer<VideoState>(
                    builder: (context, state, child) {
                      return SizedBox(
                        height: 284,
                        child: ThumbnailPreview(
                          title: state.yTitle ?? 'Preview', // Provide default value
                          url: state.thumbnailUrl,
                        ),
                      );
                                          return SizedBox();
                    },
                  ),
                  SizedBox(
                      height: Provider.of<VideoState>(context).videoUrl == null
                          ? 100
                          : 10),
                  Consumer<VideoState>(
                    builder: (context, state, child) {
                      return PFlatButton(
                        label: state.isEditMode ? "Update" : "Create",
                        isLoading: isLoading,
                        onPressed: saveVideo,
                      ).p16;
                    },
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ));
  }
}