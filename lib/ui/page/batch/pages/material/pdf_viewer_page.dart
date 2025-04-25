import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PDFViewerPage extends StatefulWidget {
  final String fileUrl;

  const PDFViewerPage({Key? key, required this.fileUrl}) : super(key: key);

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  String? localPath;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPDF();
  }

  Future<void> _loadPDF() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(widget.fileUrl));
      
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/temp_pdf.pdf');
        await file.writeAsBytes(response.bodyBytes);
        
        setState(() {
          localPath = file.path;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load PDF: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading PDF: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : PDFView(
              filePath: localPath,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: false,
              pageFling: false,
              onError: (error) {
                setState(() {
                  errorMessage = 'Error: $error';
                });
              },
              onPageError: (page, error) {
                print('Error on page $page: $error');
              },
            ),
    );
  }
}