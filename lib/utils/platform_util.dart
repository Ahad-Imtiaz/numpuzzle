import 'package:flutter/foundation.dart';

class PlatformUtil {
  static bool get isMobileWeb {
    return kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android);
  }
}
