import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/helper/images.dart';
import 'package:gyansagar_frontend/model/batch_model.dart';
import 'package:gyansagar_frontend/model/create_announcement_model.dart';
import 'package:gyansagar_frontend/states/home_state.dart';
import 'package:gyansagar_frontend/states/teacher/announcement_state.dart';
import 'package:gyansagar_frontend/ui/kit/alert.dart';
import 'package:gyansagar_frontend/ui/page/batch/create_batch/widget/search_batch_delegate.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:gyansagar_frontend/ui/widget/form/p_textfield.dart';
import 'package:gyansagar_frontend/ui/widget/p_button.dart';
import 'package:gyansagar_frontend/ui/widget/p_chiip.dart';
import 'package:gyansagar_frontend/ui/widget/secondary_app_bar.dart';
import 'package:provider/provider.dart';

class CreateAnnouncement extends StatefulWidget {
  CreateAnnouncement({
    Key? key,
    this.selectedBatch,
    this.announcementModel,
    required this.onAnnouncementCreated,
  }) : super(key: key);

  final BatchModel? selectedBatch;
  final Function onAnnouncementCreated;
  final AnnouncementModel? announcementModel;

  static MaterialPageRoute getRoute({
    required BatchModel batch,
    required Function onAnnouncementCreated,
  }) {
    return MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider<AnnouncementState>(
        create: (context) => AnnouncementState(),
        child: CreateAnnouncement(
          selectedBatch: batch,
          onAnnouncementCreated: onAnnouncementCreated,
        ),
      ),
    );
  }

  /// callback function `onAnnouncementCreated()` will invoke when announcement is created or edited
  static MaterialPageRoute getEditRoute({
    required BatchModel batch,
    required AnnouncementModel announcementModel,
    required Function onAnnouncementCreated,
  }) {
    return MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider<AnnouncementState>(
        create: (context) => AnnouncementState(
          announcementModel: announcementModel,
          isEditMode: true,
          batchId: batch.id,
        ),
        child: CreateAnnouncement(
          selectedBatch: batch,
          announcementModel: announcementModel,
          onAnnouncementCreated: onAnnouncementCreated,
        ),
      ),
    );
  }

  @override
  _CreateBatchState createState() => _CreateBatchState();
}

class _CreateBatchState extends State<CreateAnnouncement> {
  late TextEditingController _description;
  late TextEditingController _title;
  final _formKey = GlobalKey<FormState>();
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  ValueNotifier<List<BatchModel>> batchList = ValueNotifier<List<BatchModel>>([]);
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    var state = Provider.of<AnnouncementState>(context, listen: false);
    _description = TextEditingController(text: state.announcementModel.description ?? "");
    _title = TextEditingController(text: state.announcementModel.title ?? "");
    batchList.value = widget.selectedBatch != null ? [widget.selectedBatch!] : [];
    super.initState();
  }

  @override
  void dispose() {
    isLoading.dispose();
    _title.dispose();
    batchList.dispose();
    _description.dispose();
    super.dispose();
  }

  Widget _titleText(context, String name) {
    return Text(name,
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16));
  }

  Widget _secondaryButton(BuildContext context,
      {required String label, required Function onPressed}) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
        onPressed: onPressed as void Function()?,
        icon: Icon(Icons.add_circle, color: PColors.primary, size: 17),
        label: Text(
          label,
          style: theme.textTheme.labelLarge
              ?.copyWith(color: PColors.primary, fontWeight: FontWeight.bold),
        ));
  }

  void displayBatchList() async {
    final list = Provider.of<HomeState>(context, listen: false).batchList;
    if (list.isEmpty) {
      return;
    }
    await showSearch(
        context: context,
        delegate: BatchSearch(
            list, Provider.of<HomeState>(context, listen: false), batchList));
  }

  void pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      PlatformFile file = result.files.first;
      final state = Provider.of<AnnouncementState>(context, listen: false);
      state.setImageForAnnouncement = File(file.path!);
    }
  }

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc', 'xlsx', 'xls'],
    );
    if (result != null) {
      PlatformFile file = result.files.first;
      final state = Provider.of<AnnouncementState>(context, listen: false);
      state.setDocForAnnouncement = File(file.path!);
    }
  }

  void createAnnouncement() async {
    final state = context.read<AnnouncementState>();
    // validate batch name and batch description
    final isTrue = _formKey.currentState?.validate() ?? false;

    if (!isTrue) {
      return;
    }

    isLoading.value = true;
    final addNewAnnouncement = await state.createAnnouncement(
        title: _title.text,
        description: _description.text,
        batches: batchList.value);
    isLoading.value = false;
    Alert.success(
      context,
      message: state.isEditMode
          ? "Announcement updated successfully!!"
          : "Announcement created successfully!!",
      title: "Message",
      onPressed: () {
        /// Refresh announcement on batch detail screen
        widget.onAnnouncementCreated();

        /// Refresh announcement on home screen
        final homeState = context.read<HomeState>();
        homeState.fetchAnnouncementList();
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: CustomAppBar("Create Announcement"),
      body: Container(
        padding: EdgeInsets.only(left: 16, right: 16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 16),
                PTextField(
                  type: Type.text,
                  controller: _title,
                  label: "Title",
                  hintText: "Enter title here",
                ),
                PTextField(
                    type: Type.text,
                    controller: _description,
                    label: "Description",
                    hintText: "Enter here",
                    maxLines: null,
                    height: null,
                    padding: EdgeInsets.symmetric(vertical: 16)),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _titleText(context, "All Batch"),

                    /// Hide Pick Batch button if
                    /// If announcement is created from batch detail screen
                    /// If announcement is in edit mode
                    if (widget.selectedBatch == null &&
                        !context.watch<AnnouncementState>().isEditMode)
                      _secondaryButton(context,
                          label: "Pick Batch", onPressed: displayBatchList),
                  ],
                ),
                ValueListenableBuilder<List<BatchModel>>(
                    valueListenable: batchList,
                    builder: (context, listenableList, child) {
                      return Wrap(
                          children: listenableList
                              .where((element) => element.isSelected)
                              .map((e) => Padding(
                              padding: EdgeInsets.only(right: 4, top: 4),
                              child: PChip(label: e.name)))
                              .toList());
                    }),
                SizedBox(height: 10),
                Consumer<AnnouncementState>(
                  builder: (context, state, child) {
                    return Stack(
                      children: [
                        Container(
                          width: AppTheme.fullWidth(context) - 32,
                          height: 230,
                          margin: EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: state.imagefile != null
                                ? DecorationImage(
                              image: FileImage(state.imagefile!),
                              fit: BoxFit.cover,
                            )
                                : null,
                          ),
                        ),
                        if (state.imagefile != null)
                          Positioned(
                            top: 15,
                            right: 0,
                            child: Container(
                              color: Theme.of(context).disabledColor,
                              child: IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.cancel_outlined,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                              ).ripple(() {
                                state.removeAnnouncementImage();
                              }),
                            ).circular,
                          ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 10),
                Text("---------- OR ----------",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 12, color: PColors.gray))
                    .alignCenter,
                SizedBox(height: 10),
                Container(
                  width: AppTheme.fullWidth(context) - 32,
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
                      Text("File should be PDF, DOCX, Sheet, Image",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontSize: 12, color: PColors.gray))
                    ],
                  ),
                ).ripple(pickFile),
                Consumer<AnnouncementState>(
                  builder: (context, state, child) {
                    if (state.docfile != null) {
                      return SizedBox(
                        height: 65,
                        width: AppTheme.fullWidth(context),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                SizedBox(
                                    width: 50,
                                    child: Image.asset(
                                      Images.getFileTypeIcon(
                                          state.docfile!.path.split(".").last),
                                      height: 30,
                                    )),
                                Text(state.docfile!.path.split("/").last)
                                    .extended,
                                IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(Icons.cancel),
                                    onPressed: state.removeAnnouncementDoc)
                              ],
                            ),
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
                    }
                    return SizedBox();
                  },
                ),
                SizedBox(height: 40),
                PFlatButton(
                  label: context.watch<AnnouncementState>().isEditMode
                      ? "Update"
                      : "Create",
                  isLoading: isLoading,
                  onPressed: createAnnouncement,
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}