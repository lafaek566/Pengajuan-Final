import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

final String baseUrl = kIsWeb
    ? 'http://192.168.100.113:5009'
    : Platform.isAndroid
    ? 'http://192.168.100.113:5009'
    : 'http://localhost:5009';
