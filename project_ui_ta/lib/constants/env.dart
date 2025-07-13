import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

final String baseUrl = kIsWeb
    ? 'http://localhost:5009'
    : Platform.isAndroid
    ? 'http://10.0.2.2:5009'
    : 'http://localhost:5009';
