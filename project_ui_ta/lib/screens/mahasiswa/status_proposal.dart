import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/env.dart'; // tambahkan ini

class StatusProposalPage extends StatefulWidget {
  const StatusProposalPage({super.key});

  @override
  State<StatusProposalPage> createState() => _StatusProposalPageState();
}

class _StatusProposalPageState extends State<StatusProposalPage> {
  List<dynamic> proposals = [];
  bool loading = true;
  int? updatingId;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  String formatTanggal(String? tanggalString) {
    if (tanggalString == null || tanggalString.isEmpty) return "-";
    try {
      final tanggal = DateTime.parse(tanggalString);
      return DateFormat('d MMMM yyyy', 'id_ID').format(tanggal);
    } catch (_) {
      return "-";
    }
  }

  String statusText(String? status) {
    if (status == "Y") return "✅ Disetujui";
    if (status == "T") return "❌ Ditolak";
    return "⌛ Menunggu persetujuan";
  }

  Future<void> fetchProposals() async {
    setState(() => loading = true);
    try {
      final token = await _getToken();
      if (token == null) throw Exception("Token tidak ditemukan");

      final res = await http.get(
        Uri.parse('$baseUrl/api/proposal/by-mahasiswa'),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() => proposals = data);

        final prefs = await SharedPreferences.getInstance();
        if (data.isEmpty) {
          await prefs.setString("notif", "0");
          await prefs.remove("last_status");
        } else {
          final latest = data.last;
          final prevStatus = prefs.getString("last_status");
          if (latest['status_persetujuan'] != null &&
              latest['status_persetujuan'] != prevStatus) {
            await prefs.setString("notif", "1");
            await prefs.setString("last_status", latest['status_persetujuan']);
            if (latest['status_persetujuan'] == "Y") {
              Fluttertoast.showToast(msg: "🎉 Proposal kamu telah disetujui!");
            } else if (latest['status_persetujuan'] == "T") {
              Fluttertoast.showToast(msg: "❌ Proposal kamu ditolak!");
            }
          }
        }
      } else {
        throw Exception("Gagal mengambil data proposal");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Gagal mengambil data proposal.");
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> updateStatus(int id, String newStatus) async {
    setState(() => updatingId = id);
    try {
      final token = await _getToken();
      if (token == null) throw Exception("Token tidak ditemukan");

      final res = await http.post(
        Uri.parse('$baseUrl/api/proposal/$id/update-status'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"status": newStatus}),
      );

      if (res.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("notif", "1");
        await prefs.setString("last_status", newStatus);
        Fluttertoast.showToast(
          msg: newStatus == "Y"
              ? "Proposal disetujui!"
              : newStatus == "T"
              ? "Proposal ditolak!"
              : "Status diperbarui!",
        );
        await fetchProposals();
      } else {
        throw Exception("Gagal update status");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Gagal update status proposal.");
    } finally {
      setState(() => updatingId = null);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProposals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Status Proposal Tugas Akhir')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : proposals.isEmpty
            ? const Center(child: Text('Belum ada data proposal.'))
            : ListView.builder(
                itemCount: proposals.length,
                itemBuilder: (context, index) {
                  final item = proposals[index];
                  final id = item['id'] as int;
                  final status = item['status_persetujuan'] as String?;
                  final isUpdating = updatingId == id;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['judul_ta'] ?? '-',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Topik: ${item['nama_topik'] ?? "-"}'),
                          Text(
                            'Mahasiswa: ${item['nama_mahasiswa'] ?? "-"} (${item['nim'] ?? "-"})',
                          ),
                          Text('Prodi: ${item['prodi'] ?? "-"}'),
                          Text('Tahun: ${item['tahun'] ?? "-"}'),
                          const SizedBox(height: 4),
                          Text('Pembimbing: ${item['nama_pembimbing'] ?? "-"}'),
                          Text('Penguji 1: ${item['nama_penguji1'] ?? "-"}'),
                          Text('Penguji 2: ${item['nama_penguji2'] ?? "-"}'),
                          const SizedBox(height: 4),
                          Text(
                            'Tanggal Ujian: ${formatTanggal(item['tgl_ujian'])}',
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (status == "Y")
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 6),
                                    Text("Disetujui"),
                                  ],
                                )
                              else if (status == "T")
                                Row(
                                  children: const [
                                    Icon(Icons.cancel, color: Colors.red),
                                    SizedBox(width: 6),
                                    Text("Ditolak"),
                                  ],
                                )
                              else
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.access_time,
                                      color: Colors.amber,
                                    ),
                                    SizedBox(width: 6),
                                    Text("Menunggu persetujuan"),
                                  ],
                                ),
                            ],
                          ),
                          if (status != "Y" && status != "T") ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: isUpdating
                                      ? null
                                      : () => updateStatus(id, "Y"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isUpdating
                                        ? Colors.green[200]
                                        : Colors.green,
                                  ),
                                  child: isUpdating
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Terima'),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: isUpdating
                                      ? null
                                      : () => updateStatus(id, "T"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isUpdating
                                        ? Colors.red[200]
                                        : Colors.red,
                                  ),
                                  child: isUpdating
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Tolak'),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
