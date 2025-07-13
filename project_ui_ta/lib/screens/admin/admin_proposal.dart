import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/env.dart'; // baseUrl

class AdminProposalPage extends StatefulWidget {
  const AdminProposalPage({super.key});

  @override
  State<AdminProposalPage> createState() => _AdminProposalPageState();
}

class _AdminProposalPageState extends State<AdminProposalPage> {
  List<dynamic> proposalList = [];
  bool loading = true;
  String errorMsg = '';
  int? selectedId;
  String tglUjian = '';
  String jamUjian = '';
  int currentPage = 1;
  final int itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    fetchProposal();
  }

  Future<void> fetchProposal() async {
    setState(() {
      loading = true;
      errorMsg = '';
    });

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/proposal'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          proposalList = data;
        });
      } else {
        setState(() {
          errorMsg = 'Gagal memuat data proposal.';
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = 'Gagal memuat data proposal.';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void handleApprove(int id) {
    selectedId = id;
    tglUjian = '';
    jamUjian = '';
    _showTanggalDialog();
  }

  Future<void> submitApproval() async {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(tglUjian)) {
      _showDialog('Format tanggal salah. Gunakan format YYYY-MM-DD.');
      return;
    }

    final tanggalUjianLengkap =
        '$tglUjian ${jamUjian.isNotEmpty ? jamUjian : '00:00'}:00';

    try {
      await http.put(
        Uri.parse('$baseUrl/api/proposal/status/$selectedId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'status_persetujuan': 'Y',
          'tgl_persetujuan': DateTime.now().toIso8601String().split('T')[0],
          'tgl_ujian': tanggalUjianLengkap,
        }),
      );
      fetchProposal();
    } catch (e) {
      _showDialog('❌ Gagal menyetujui proposal.');
    }
  }

  Future<void> setStatusReject(int id) async {
    try {
      await http.put(
        Uri.parse('$baseUrl/api/proposal/status/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'status_persetujuan': 'T',
          'tgl_persetujuan': DateTime.now().toIso8601String().split('T')[0],
        }),
      );
      fetchProposal();
    } catch (e) {
      _showDialog('❌ Gagal menolak proposal.');
    }
  }

  Future<void> handleDelete(int id) async {
    final confirmed = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Yakin ingin menghapus proposal ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await http.delete(Uri.parse('$baseUrl/api/proposal/$id'));
        fetchProposal();
      } catch (e) {
        _showDialog("Gagal menghapus proposal.");
      }
    }
  }

  String statusText(String? status) {
    if (status == 'Y') return '✅ Disetujui';
    if (status == 'T') return '❌ Ditolak';
    return '⌛ Belum Diproses';
  }

  String formatTanggal(String? tgl) {
    if (tgl == null || tgl.isEmpty) return '-';
    final dtUtc = DateTime.tryParse(tgl)?.toUtc();
    if (dtUtc == null) return '-';

    // Konversi ke WIB (UTC+7)
    final dtWib = dtUtc.add(const Duration(hours: 7));

    return '${dtWib.day.toString().padLeft(2, '0')} ${_bulan(dtWib.month)} ${dtWib.year} ${dtWib.hour.toString().padLeft(2, '0')}:${dtWib.minute.toString().padLeft(2, '0')}';
  }

  String _bulan(int month) {
    const bulan = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return bulan[month];
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Peringatan'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showTanggalDialog() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🗓 Setel Tanggal dan Jam Ujian'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: tglUjian),
              decoration: const InputDecoration(
                labelText: 'Tanggal (YYYY-MM-DD)',
              ),
              onChanged: (val) => tglUjian = val,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              child: const Text('Pilih dari Kalender'),
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() {
                    tglUjian = date.toIso8601String().split('T')[0];
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Text(jamUjian.isEmpty ? 'Jam belum dipilih' : 'Jam: $jamUjian'),
            ElevatedButton(
              child: const Text('Pilih Jam'),
              onPressed: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() {
                    final hour = time.hour.toString().padLeft(2, '0');
                    final minute = time.minute.toString().padLeft(2, '0');
                    jamUjian = '$hour:$minute';
                  });
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (tglUjian.isEmpty || jamUjian.isEmpty) {
                _showDialog('Tanggal dan jam wajib diisi!');
                return;
              }
              submitApproval();
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (proposalList.length / itemsPerPage).ceil();
    final start = (currentPage - 1) * itemsPerPage;
    final end = (start + itemsPerPage > proposalList.length)
        ? proposalList.length
        : start + itemsPerPage;
    final currentData = proposalList.sublist(start, end);

    return Scaffold(
      appBar: AppBar(title: const Text("📑 Proposal Mahasiswa")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : errorMsg.isNotEmpty
            ? Text(errorMsg, style: const TextStyle(color: Colors.red))
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('#')),
                          DataColumn(label: Text('NIM')),
                          DataColumn(label: Text('Judul')),
                          DataColumn(label: Text('Tahun')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Tgl Ujian')),
                          DataColumn(label: Text('Aksi')),
                        ],
                        rows: currentData.asMap().entries.map((entry) {
                          final i = entry.key;
                          final p = entry.value;
                          return DataRow(
                            cells: [
                              DataCell(Text('${start + i + 1}')),
                              DataCell(Text(p['nim'] ?? '-')),
                              DataCell(Text(p['judul_ta'] ?? '-')),
                              DataCell(Text(p['tahun'].toString())),
                              DataCell(
                                Text(statusText(p['status_persetujuan'])),
                              ),
                              DataCell(Text(formatTanggal(p['tgl_ujian']))),
                              DataCell(
                                Row(
                                  children: [
                                    TextButton(
                                      onPressed: () => handleApprove(p['id']),
                                      child: const Text("Setujui"),
                                    ),
                                    TextButton(
                                      onPressed: () => setStatusReject(p['id']),
                                      child: const Text("Tolak"),
                                    ),
                                    TextButton(
                                      onPressed: () => handleDelete(p['id']),
                                      child: const Text("Hapus"),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Halaman $currentPage dari $totalPages"),
                      Row(
                        children: [
                          TextButton(
                            onPressed: currentPage > 1
                                ? () => setState(() => currentPage -= 1)
                                : null,
                            child: const Text("⬅ Sebelumnya"),
                          ),
                          TextButton(
                            onPressed: currentPage < totalPages
                                ? () => setState(() => currentPage += 1)
                                : null,
                            child: const Text("Berikutnya ➡"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
