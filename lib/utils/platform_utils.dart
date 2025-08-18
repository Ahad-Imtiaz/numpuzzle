// platform_utils.dart
import 'package:flutter/foundation.dart' show kIsWeb;

bool get isMobileWeb {
  if (!kIsWeb) return false;

  // Use conditional import
  return _isMobileWebWeb();
}

// Stub for non-web platforms
bool _isMobileWebWeb() => false;
