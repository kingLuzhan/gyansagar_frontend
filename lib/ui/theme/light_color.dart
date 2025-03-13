part of 'theme.dart';

class PColors {
  PColors._();

  static const Color disableButtonColor = Color(0XFF848d95);
  static const Color primaryDarkColor = Color(0XFFfefefe);
  static const Color primaryExtraDarkColor = Color(0XFFfefefe);
  static const Color onPrimary = Color(0XFFffffff);
  static const Color appBarColor = Color(0XFFfafafa);
  static const Color secondary = Color(0XFF0545FF);

  static const Color primary = Color(0XFF0084ff);
  static const Color primaryLight = Color(0xFFfBCDFFF);
  static const Color background = Color(0XFFffffff);
  static const Color cardColor = Color(0XFFededed);
  static const Color surfaceColor = Color(0XFFf8f8f8);
  static const Color onSurfaceLightColor = Color(0XFFfbfbfc);
  static const Color onSurfaceDarkColor = Color(0XFF94959e);

  static const Color black = Color(0XFF24292e);
  static const Color gray = Color(0XFF6a737d);
  static const Color blue = Color(0XFF0366d6);
  static const Color green = Color(0XFf009688);
  static const Color purple = Color(0XFF6f42c1);
  static const Color yellow = Color(0XFFffd33d);
  static const Color orange = Color(0XFFd15704);
  static const Color red = Color(0XFFd73a49);
  static const Color pink = Color(0XFFea4aaa);
  static const Color white = Color(0XFFffffff);

  static Color randomColor(String text) {
    final colors = <Color>[
      Color(0xffFF7878),
      Color(0xffFFA959),
      Color(0xff83DA2D),
      Color(0xff1FE2D7),
      Color(0xffC13E6B),
      Color(0xffFF7878),
      Color(0xff07B7A6),
      Color(0xff1F7ACD),
      Color(0xffBB78FF),
      Color(0xffF14CD7),
      Color(0xffFF5757),
    ];
    return colors[text.length %11];
      Random ran = Random.secure();
    return colors[ran.nextInt(10)];
  }
}
