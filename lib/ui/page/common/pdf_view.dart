import 'dart:developer';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/helper/utility.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';

class PdfViewPage extends StatefulWidget {
  const PdfViewPage({super.key, required this.path, required this.title});
  final String path;
  final String title;

  static MaterialPageRoute getRoute(String path, {required String title}) {
    return MaterialPageRoute(
        builder: (_) => PdfViewPage(
          path: path,
          title: title,
        ));
  }

  @override
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  bool _isLoading = true;
  final GlobalKey<ScaffoldMessengerState> scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  late PDFDocument document;

  @override
  void initState() {
    super.initState();
    changePDF();
  }

  changePDF() async {
    try {
      document = await PDFDocument.fromURL(widget.path);
      _isLoading = false;
      setState(() {});
    } catch (error) {
      log(error.toString(), name: "PdfViwer");
      Utility.displaySnackbar(context, key: scaffoldKey, msg: "File not found on server");
      Future.delayed(const Duration(seconds: 1)).then((value) => Navigator.pop(context));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Title(
          color: PColors.black,
          child: Text(widget.title),
        ),
      ),
      body: Center(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : PDFViewer(
          document: document,
          zoomSteps: 1,
          lazyLoad: false,
          scrollDirection: Axis.vertical,
          showPicker: true,
          navigationBuilder: (context, page, totalPages, jumpToPage, animateToPage) {
            return Container(
              decoration: AppTheme.decoration(context),
              child: OverflowBar(
                alignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.first_page),
                    onPressed: () {
                      jumpToPage(page: 0);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      if (page != null && page > 1) {
                        animateToPage(page: page - 2);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      if (page != null) {
                        animateToPage(page: page);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.last_page),
                    onPressed: () {
                      if (totalPages != null) {
                        jumpToPage(page: totalPages - 1);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}