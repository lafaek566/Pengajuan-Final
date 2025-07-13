import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>?> getUser() async {
  final prefs = await SharedPreferences.getInstance();
  final userJson = prefs.getString("user");
  if (userJson != null) {
    return jsonDecode(userJson);
  }
  return null;
}

Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove("user");
}
