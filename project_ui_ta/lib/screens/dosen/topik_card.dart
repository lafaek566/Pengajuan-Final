import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../constants/env.dart'; // baseUrl disimpan di sini

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
    fetchTopikList();
  }

  Future<void> fetchTopikList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/dashboard/stats'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          daftarTopik = List<String>.from(data['daftar_topik']);
          loading = false;
        });
      } else {
        debugPrint("Gagal fetch data, code: ${response.statusCode}");
        setState(() => loading = false);
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => loading = false);
    }
  }

  Widget topikCardBox(String namaTopik) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blueGrey.withAlpha(30),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            namaTopik,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (daftarTopik.isEmpty) {
      return const Center(child: Text("Belum ada topik tersedia."));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        itemCount: daftarTopik.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          return topikCardBox(daftarTopik[index]);
        },
      ),
    );
  }
}
