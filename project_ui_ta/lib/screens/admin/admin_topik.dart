import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../dosen/topik_card.dart'; // ✅ gunakan TopikCard yang sudah ada
import '../../constants/env.dart'; // pastikan baseUrl di sini

class AdminTopikPage extends StatefulWidget {
  const AdminTopikPage({super.key});

  @override
  State<AdminTopikPage> createState() => _AdminTopikPageState();
}

class _AdminTopikPageState extends State<AdminTopikPage> {
  List<dynamic> topikList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchTopik();
  }

  Future<void> fetchTopik() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/topik'));
      if (res.statusCode == 200) {
        setState(() {
          topikList = jsonDecode(res.body);
          loading = false;
        });
      } else {
        setState(() => loading = false);
        debugPrint("Gagal ambil topik, code: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint('Error fetchTopik: $e');
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (topikList.isEmpty) {
      return const Center(child: Text("Belum ada data topik."));
    }

    return ListView(
      children: topikList.map((topik) {
        return TopikCard(
          idTopik: topik['id_topik'].toString(),
          namaTopik: topik['nama_topik'],
        );
      }).toList(),
    );
  }
}
