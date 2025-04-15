import 'package:gyansagar_frontend/config/config.dart';
import 'package:gyansagar_frontend/helper/constants.dart';
import 'package:gyansagar_frontend/helper/images.dart';

class Configs {
  static devConfig() => Config(
        appName: 'Gyansagar [DEV]',
        appIcon: Images.logo,
        apiBaseUrl: Constants.developmentBaseUrl,
        appToken: '',
        apiLogging: true,
        diagnostic: true,
      );


}
