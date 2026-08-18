import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class Environment {
  static String get baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api';
    }
    return 'http://localhost:8080/api';
  }
}
