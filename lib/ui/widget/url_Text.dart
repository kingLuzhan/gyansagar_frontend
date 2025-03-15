import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/helper/utility.dart';

class UrlText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextStyle urlStyle;
  final Function(String) onHashTagPressed;

  const UrlText({
    super.key,
    required this.text,
    required this.style,
    required this.urlStyle,
    required this.onHashTagPressed,
  });

  List<InlineSpan> getTextSpans() {
    List<InlineSpan> widgets = [];
    RegExp reg = RegExp(
        r"([#])\w+| [@]\w+|(https?|ftp|file|#)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]*");
    Iterable<Match> matches = reg.allMatches(text);
    List<_ResultMatch> resultMatches = [];
    int start = 0;
    for (Match match in matches) {
      if (match.group(0)!.isNotEmpty) {
        if (start != match.start) {
          _ResultMatch result1 = _ResultMatch();
          result1.isUrl = false;
          result1.text = text.substring(start, match.start);
          resultMatches.add(result1);
        }

        _ResultMatch result2 = _ResultMatch();
        result2.isUrl = true;
        result2.text = match.group(0)!;
        resultMatches.add(result2);
        start = match.end;
      }
    }
    if (start < text.length) {
      _ResultMatch result1 = _ResultMatch();
      result1.isUrl = false;
      result1.text = text.substring(start);
      resultMatches.add(result1);
    }
    for (var result in resultMatches) {
      if (result.isUrl) {
        widgets.add(_LinkTextSpan(
            onHashTagPressed: onHashTagPressed,
            text: result.text,
            style: urlStyle));
      } else {
        widgets.add(TextSpan(
            text: result.text,
            style: style));
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(children: getTextSpans()),
    );
  }
}

class _LinkTextSpan extends TextSpan {
  final Function(String) onHashTagPressed;
  _LinkTextSpan({super.style, required String super.text, required this.onHashTagPressed})
      : super(
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          if ((text.substring(0, 1).contains("#") ||
              text.substring(0, 1).contains("@"))) {
            onHashTagPressed(text);
          } else {
            Utility.launchOnWeb(text);
          }
        });
}

class _ResultMatch {
  late bool isUrl;
  late String text;
}