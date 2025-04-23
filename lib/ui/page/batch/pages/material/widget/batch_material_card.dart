import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/helper/images.dart';
import 'package:gyansagar_frontend/helper/utility.dart';
import 'package:gyansagar_frontend/model/batch_material_model.dart';
import 'package:gyansagar_frontend/states/home_state.dart';
import 'package:gyansagar_frontend/states/teacher/batch_detail_state.dart';
import 'package:gyansagar_frontend/states/teacher/material/batch_material_state.dart';
import 'package:gyansagar_frontend/ui/kit/alert.dart';
import 'package:gyansagar_frontend/ui/kit/overlay_loader.dart';
import 'package:gyansagar_frontend/ui/page/batch/pages/material/upload_material.dart';
import 'package:gyansagar_frontend/ui/page/batch/widget/tile_action_widget.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:gyansagar_frontend/ui/widget/p_chiip.dart';
import 'package:provider/provider.dart';
import 'package:gyansagar_frontend/ui/page/common/web_view.page.dart';

class BatchMaterialCard extends StatelessWidget {
  const BatchMaterialCard(
      {super.key,
        required this.loader,
        required this.model,
        this.actions = const ["Edit", "Delete"]});
  final CustomLoader loader;
  final List<String> actions;
  final BatchMaterialModel model;

  Widget _picture(context, String type) {
    return // Picture
      Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.decoration(context),
        alignment: Alignment.center,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: <Widget>[
              Container(
                width: 5,
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: PColors.blue, width: 6)),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: type.isEmpty
                      ? const SizedBox()
                      : Image.asset(
                    Images.getFileTypeIcon(type),
                    fit: BoxFit.fitHeight,
                    width: 50,
                  ),
                ),
              )
            ],
          ),
        ),
      );
  }

  void openMaterial(context, BatchMaterialModel model) {
    // Add debug print to see what's being passed
    print("Opening material: ${model.articleUrl ?? model.fileUrl ?? model.filePath}");
    
    String filePath = "";
    
    if (model.articleUrl != null && model.articleUrl!.isNotEmpty) {
      // For article URLs, use launchOnWeb
      Utility.launchOnWeb(model.articleUrl!);
      return;
    } else if (model.fileUrl.isNotEmpty) {
      // For file URLs, use launchOnWeb with the file URL
      filePath = model.fileUrl;
    } else if (model.filePath.isNotEmpty) {
      filePath = model.filePath;
    } else {
      // Show a message if no URL or file is available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No URL or file available to open this material")),
      );
      return;
    }
    
    // If the URL contains localhost, replace it with the actual server address
    if (filePath.contains('localhost')) {
      filePath = filePath.replaceAll('localhost', '10.0.2.2');
    }
    
    // Check if filePath is actually a URL (starts with http)
    if (filePath.startsWith('http')) {
      print("Opening remote file URL: $filePath");
      
      // Determine file type and open with appropriate viewer
      final fileExtension = filePath.split('.').last.toLowerCase();
      
      if (['pdf', 'doc', 'docx', 'xlsx', 'xls'].contains(fileExtension)) {
        // For documents, use a document viewer
        _openDocumentFile(context, filePath);
      } else if (['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension)) {
        // For images, use an image viewer
        _openImageFile(context, filePath);
      } else {
        // For other file types, try to open with default handler
        Utility.launchOnWeb(filePath);
      }
    } else {
      // For local files
      print("Opening local file: $filePath");
      Utility.openFile(filePath);
    }
  }
  
  void _openDocumentFile(BuildContext context, String filePath) {
    // Determine file type
    final fileExtension = filePath.split('.').last.toLowerCase();
    
    if (['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'].contains(fileExtension)) {
      // For document files, use Google Docs Viewer
      final encodedUrl = Uri.encodeComponent(filePath);
      final viewerUrl = 'https://docs.google.com/viewer?url=$encodedUrl&embedded=true';
      
      Navigator.push(
        context,
        WebViewPage.getRoute(viewerUrl, title: "Document Viewer"),
      );
    } else {
      // For other document types, try to open with external app
      Utility.launchOnWeb(filePath);
      
      // Also show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Opening document with external app: $fileExtension")),
      );
    }
  }
  
  void _openImageFile(BuildContext context, String filePath) {
    // Open image in a full-screen viewer
    String imageUrl = filePath;
    
    // If the URL contains localhost, replace it with the actual server address
    if (filePath.contains('localhost')) {
      // Replace localhost with the actual server address (10.0.2.2 for Android emulator)
      imageUrl = filePath.replaceAll('localhost', '10.0.2.2');
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text("Image Viewer"),
            backgroundColor: Colors.black,
          ),
          body: Center(
            child: imageUrl.startsWith('http') 
                ? Image.network(
                    imageUrl,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / 
                                loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Text('Error loading image: $error');
                    },
                  )
                : Image.file(File(imageUrl)),
          ),
          backgroundColor: Colors.black,
        ),
      ),
    );
  }

  void deleteVideo(BuildContext context, String id) async {
    Alert.yesOrNo(context,
        message: "Are you sure, you want to delete this material?",
        title: "Message",
        barrierDismissible: true,
        onCancel: () {}, onYes: () async {
          loader.showLoader(context);
          final isDeleted =
          await context.read<BatchMaterialState>().deleteMaterial(id);
          await context.read<BatchDetailState>().getBatchTimeLine();
          if (isDeleted) {
            Utility.displaySnackbar(context, msg: "Material Deleted");
          }
          loader.hideLoader();
        });
  }

  void editMaterial(context, BatchMaterialModel model) {
    Navigator.push(
      context,
      UploadMaterialPage.getEditRoute(
        model,
        state: Provider.of<BatchMaterialState>(context, listen: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
              aspectRatio: 1,
              child: GestureDetector(
                onTap: () => openMaterial(context, model),
                child: _picture(context, model.fileType ?? ''),
              )),
          Expanded(
            child: InkWell(
              onTap: () => openMaterial(context, model),
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          model.title,
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 3,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            PChip(
                              backgroundColor: PColors.orange,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                color:
                                Theme.of(context).colorScheme.onPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              borderColor: Colors.transparent,
                              label: model.subject,
                            ),
                            Text(
                              Utility.toDMformat(model.createdAt),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Theme.of(context).disabledColor),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (Provider.of<HomeState>(context).isTeacher)
            TileActionWidget(
              list: actions,
              onDelete: () => deleteVideo(context, model.id),
              onEdit: () => editMaterial(context, model),
              onCustomIconPressed: () {
                // Perform some custom action
                print("Custom icon pressed");
              },
            ),
        ],
      ),
    );
  }
}