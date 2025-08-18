// platform_utils_web.dart
import 'dart:html' as html;

bool _isMobileWebWeb() {
  final ua = html.window.navigator.userAgent.toLowerCase();
  return ua.contains('iphone') || ua.contains('ipad') || ua.contains('ipod') || ua.contains('android');
}
