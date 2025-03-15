import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/helper/images.dart';
import 'package:gyansagar_frontend/model/batch_material_model.dart';
import 'package:gyansagar_frontend/model/batch_model.dart';
import 'package:gyansagar_frontend/states/teacher/material/batch_material_state.dart';
import 'package:gyansagar_frontend/ui/kit/alert.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:gyansagar_frontend/ui/widget/form/p_textfield.dart';
import 'package:gyansagar_frontend/ui/widget/p_button.dart';
import 'package:gyansagar_frontend/ui/widget/p_chiip.dart';
import 'package:gyansagar_frontend/ui/widget/secondary_app_bar.dart';
import 'package:provider/provider.dart';

class UploadMaterialPage extends StatefulWidget {
  final String subject;
  final BatchMaterialState state;
  final BatchMaterialModel materialModel;
  const UploadMaterialPage({
    super.key,
    required this.subject,
    required this.state,
    required this.materialModel,
  });

  static MaterialPageRoute getRoute({
    required String subject,
    required String batchId,
    required BatchMaterialState state,
    bool isEdit = false,
  }) {
    return MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider<BatchMaterialState>(
        create: (context) => BatchMaterialState(
          subject: subject,
          batchId: batchId,
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
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
        child: UploadMaterialPage(
          subject: subject,
          state: state,
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
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
      ),
    );
  }

  static MaterialPageRoute getEditRoute(BatchMaterialModel materialModel, {required BatchMaterialState state, bool isEdit = false}) {
    return MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider<BatchMaterialState>(
        create: (context) => BatchMaterialState(
          subject: materialModel.subject,
          batchId: materialModel.batchId,
          materialModel: materialModel,
          isEditMode: true,
        ),
        child: UploadMaterialPage(
          subject: materialModel.subject,
          materialModel: materialModel,
          state: state,
        ),
      ),
    );
  }

  @override
  _UploadMaterialPageState createState() => _UploadMaterialPageState();
}

class _UploadMaterialPageState extends State<UploadMaterialPage> {
  late TextEditingController _description;
  late TextEditingController _title;
  late TextEditingController _link;
  final _formKey = GlobalKey<FormState>();
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  ValueNotifier<List<BatchModel>> batchList = ValueNotifier<List<BatchModel>>([]);
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> urlList = [""];

  @override
  void initState() {
    _description = TextEditingController(text: widget.materialModel.description);
    _title = TextEditingController(text: widget.materialModel.title);
    _link = TextEditingController(text: widget.materialModel.articleUrl ?? "");
    super.initState();
  }

  @override
  void dispose() {
    _title.dispose();
    batchList.dispose();
    _description.dispose();
    super.dispose();
  }

  Widget _titleText(BuildContext context, String name) {
    return Text(
      name,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc', 'xlsx', 'xls'],
    );
    if (result != null) {
      PlatformFile file = result.files.first;
      final state = Provider.of<BatchMaterialState>(context, listen: false);
      state.setFile = File(file.path!);
    }
  }

  void saveMaterial() async {
    final state = Provider.of<BatchMaterialState>(context, listen: false);
    final isTrue = _formKey.currentState?.validate() ?? false;

    if (!isTrue) {
      return;
    }
    if (_link.text.isNotEmpty) {
      state.setArticleUrl(_link.text);
    }

    isLoading.value = true;

    final isOk = await state.uploadMaterial(_title.text, _description.text);
    isLoading.value = false;
    if (isOk) {
      String message = "Material added successfully!!";
      if (state.isEditMode) {
        message = "Material updated successfully!!";
      }
      await widget.state.getBatchMaterialList();
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
      backgroundColor: const Color(0xffeeeeee),
      appBar: const CustomAppBar("Upload Material"),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                color: const Color(0xfffafafa),
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: PTextField(
                        type: FieldType.text, // Changed from Type.text to FieldType.text
                        controller: _title,
                        label: "Title",
                        hintText: "Enter title here",
                      ),
                    ),
                    PTextField(
                      type: FieldType.text, // Changed from Type.text to FieldType.text
                      controller: _description,
                      label: "Description",
                      hintText: "Enter here",
                      maxLines: 10,
                      height: 70, // Provide a non-null value
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        _titleText(context, "Subject"),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 4, top: 10),
                          child: PChip(
                            label: widget.subject,
                            backgroundColor: PColors.yellow,
                            borderColor: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              _titleText(context, "Add Link").vP16,
              PTextField(
                type: FieldType.text, // Changed from Type.text to FieldType.text
                controller: _link,
                hintText: "Paste link here",
                onSubmit: (val) {},
              ).hP16,
              Center(child: _titleText(context, "OR")),
              const SizedBox(height: 10),
              Center(child: _titleText(context, "Upload File")),
              const SizedBox(height: 10),
              Container(
                width: AppTheme.fullWidth(context) - 32,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: AppTheme.outline(context),
                child: Column(
                  children: <Widget>[
                    Text(
                      "Browse file",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Image.asset(Images.uploadVideo, height: 25).vP16,
                    Text(
                      "File should be PDF, DOCX, Sheet, Image",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12, color: PColors.gray),
                    ),
                  ],
                ),
              ).ripple(pickFile),
              Consumer<BatchMaterialState>(
                builder: (context, state, child) {
                  return SizedBox(
                    height: 65,
                    width: AppTheme.fullWidth(context),
                    child: Column(
                      children: <Widget>[
                        Row(children: <Widget>[
                          SizedBox(
                            width: 50,
                            child: Image.asset(
                              Images.getFileTypeIcon(state.file.path.split(".").last),
                              height: 30,
                            ),
                          ),
                          Text(state.file.path.split("/").last),
                          const Spacer(),
                          IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.cancel),
                            onPressed: () {
                              state.removeFile();
                            },
                          ),
                        ]),
                        Container(
                          height: 5,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          width: AppTheme.fullWidth(context),
                          decoration: BoxDecoration(
                            color: const Color(0xff0CC476),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ],
                    ),
                  ).vP8;
                                  return const SizedBox();
                },
              ),
              Consumer<BatchMaterialState>(
                builder: (context, state, child) {
                  return PFlatButton(
                    label: state.isEditMode ? "Update" : "Create",
                    isLoading: isLoading,
                    onPressed: saveMaterial,
                  ).p16;
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}