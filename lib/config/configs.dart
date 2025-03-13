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

  static proConfig() => Config(
        appName: 'Gyansagar',
        appIcon: Images.logo,
        apiBaseUrl: Constants.productionBaseUrl,
        appToken: '',
        apiLogging: false,
        diagnostic: false,
      );
}
