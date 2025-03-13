import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/ui/widget/p_loader.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String link;
  final String title;

  const WebViewPage({Key? key, required this.link, required this.title}) : super(key: key);

  static MaterialPageRoute getRoute(String link, {String title = ""}) {
    return MaterialPageRoute(builder: (_) => WebViewPage(link: link, title: title));
  }

  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => loading = true);
          },
          onPageFinished: (String url) {
            setState(() => loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.link));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: <Widget>[
          WebViewWidget(controller: _controller),
          if (loading) Center(child: Ploader()),
        ],
      ),
    );
  }
}