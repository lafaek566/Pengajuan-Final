import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../constants/env.dart';
import 'cetak_pdf.dart';

class StatusTaPage extends StatefulWidget {
  const StatusTaPage({super.key});

  @override
  State<StatusTaPage> createState() => _StatusTaPageState();
}

class _StatusTaPageState extends State<StatusTaPage> {
  final TextEditingController _nimController = TextEditingController();
  Map<String, dynamic>? data;
  bool loading = false;
  String? errorMsg;

  String formatTanggal(String? tgl) {
    if (tgl == null || tgl.isEmpty) return "-";
    try {
      final date = DateTime.parse(tgl).toLocal();
      return "${DateFormat("EEEE, dd MMMM yyyy – HH:mm", "id_ID").format(date)} WIB";
    } catch (_) {
      return "-";
    }
  }

  String statusText(String? s) {
    if (s == "Y") return "✅ Disetujui";
    if (s == "T") return "❌ Ditolak";
    return "⌛ Belum Diproses";
  }

  Future<void> fetchStatus() async {
    final nim = _nimController.text.trim();
    if (nim.isEmpty) {
      Fluttertoast.showToast(
        msg: "❌ Masukkan NIM terlebih dahulu",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      loading = true;
      errorMsg = null;
      data = null;
    });

    try {
      final res = await http.get(Uri.parse("$baseUrl/api/judul/status/$nim"));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        setState(() => data = body);
        Fluttertoast.showToast(
          msg: "✅ Data berhasil ditemukan",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        setState(() => errorMsg = "❌ Data tidak ditemukan");
        Fluttertoast.showToast(
          msg: "❌ NIM tidak ditemukan",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      setState(() => errorMsg = "❌ Gagal mengambil data status");
      Fluttertoast.showToast(
        msg: "⚠️ Terjadi kesalahan koneksi",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() => loading = false);
    }
  }

  Widget buildResult() {
    if (loading) return const Text("🔄 Memuat data...");
    if (errorMsg != null) {
      return Text(errorMsg!, style: const TextStyle(color: Colors.red));
    }
    if (data == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              info("Nama Mahasiswa", data!['nama_mahasiswa']),
              info("NIM", data!['nim']),
              info("Judul", data!['judul_ta']),
              info("Topik", data!['nama_topik']),
              info("Prodi", data!['nama_prodi']),
              info("Pembimbing", data!['nama_pembimbing']),
              info("Penguji 1", data!['nama_penguji']),
              info("Penguji 2", data!['nama_penguji2']),
              info("Status Proposal", statusText(data!['status_persetujuan'])),
              info(
                "Tanggal Persetujuan",
                formatTanggal(data!['tgl_persetujuan']),
              ),
              info("Tanggal Ujian", formatTanggal(data!['tgl_ujian'])),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            if (data != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CetakPdf(data: data!)),
              );
            }
          },
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text("Cetak PDF"),
        ),
      ],
    );
  }

  Widget info(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          text: "$label: ",
          style: const TextStyle(fontWeight: FontWeight.bold),
          children: [
            TextSpan(
              text: (value != null && value.toString().isNotEmpty)
                  ? value.toString()
                  : "-",
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📌 Cek Status Tugas Akhir")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nimController,
                    onSubmitted: (_) => fetchStatus(),
                    decoration: const InputDecoration(
                      hintText: "Masukkan NIM",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: fetchStatus,
                  child: const Text("Cari"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            buildResult(),
          ],
        ),
      ),
    );
  }
}
