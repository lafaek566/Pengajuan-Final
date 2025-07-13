import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../constants/env.dart';

class AdminTopikPage extends StatefulWidget {
  const AdminTopikPage({super.key});

  @override
  State<AdminTopikPage> createState() => _AdminTopikPageState();
}

class _AdminTopikPageState extends State<AdminTopikPage> {
  List<String> daftarTopik = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchTopikFromDashboardStats();
  }

  Future<void> fetchTopikFromDashboardStats() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/dashboard/stats'));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          daftarTopik = List<String>.from(data['daftar_topik'] ?? []);
          loading = false;
        });
      } else {
        debugPrint("Gagal ambil data: ${res.statusCode}");
        setState(() => loading = false);
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => loading = false);
    }
  }

  Widget buildTopikCard(String namaTopik) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.deepPurple.withAlpha(25), // ✅ fix warning deprecated
      child: ListTile(
        leading: const Icon(Icons.topic, color: Colors.deepPurple),
        title: Text(
          namaTopik,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.deepPurple),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (daftarTopik.isEmpty) {
      return const Center(child: Text("Belum ada topik yang tersedia."));
    }

    return ListView(
      children: daftarTopik.map((topik) => buildTopikCard(topik)).toList(),
    );
  }
}
