import 'package:nostr_sdk/utils/platform_util.dart';

class Base {
  static const APP_NAME = "Nowser";

  static String VERSION_NAME = "1.4.1";

  static const double BASE_PADDING = 12;

  static const double BASE_PADDING_HALF = 6;

  static double BASE_FONT_SIZE = 15;

  static String USER_AGENT =
      "${Base.APP_NAME} ${PlatformUtil.getPlatformName()} ${Base.VERSION_NAME}";

  static String WEB_APPS = "https://nowser.nostrmo.com/jsons/webapps.json";
}
