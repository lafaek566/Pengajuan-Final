import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';
import '../../constants/env.dart';

class FormAjukanJudul extends StatefulWidget {
  const FormAjukanJudul({super.key});

  @override
  State<FormAjukanJudul> createState() => _FormAjukanJudulState();
}

class _FormAjukanJudulState extends State<FormAjukanJudul> {
  final _formKey = GlobalKey<FormState>();

  String nim = '';
  String nama = '';
  String angkatan = '';
  String judul = '';
  String topik = '';
  String prodiId = '';
  String pembimbing = '';
  String penguji = '';
  String penguji2 = '';
  int tahun = DateTime.now().year;

  bool submitting = false;
  List<dynamic> dosenList = [];
  List<dynamic> similarJudul = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    loadUserProfile();
    fetchDosen();
  }

  Future<void> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    if (userData != null) {
      final user = jsonDecode(userData);
      if (!mounted) return;
      setState(() {
        nim = user['nim'] ?? '';
        nama = user['nama'] ?? '';
      });
    }
  }

  Future<void> fetchDosen() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/admin/dosen'));
      if (res.statusCode == 200 && mounted) {
        setState(() {
          dosenList = jsonDecode(res.body);
        });
      }
    } catch (e) {
      debugPrint('Gagal fetch dosen: $e');
    }
  }

  void onJudulChanged(String val) {
    setState(() => judul = val);
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    if (val.length > 5) {
      _debounce = Timer(const Duration(milliseconds: 500), () {
        checkSimilarity(val);
      });
    } else {
      setState(() => similarJudul = []);
    }
  }

  Future<void> checkSimilarity(String query) async {
    try {
      final res = await http.get(
        Uri.parse(
          '$baseUrl/api/judul/check?q=${Uri.encodeQueryComponent(query)}',
        ),
      );
      if (res.statusCode == 200 && mounted) {
        setState(() {
          similarJudul = jsonDecode(res.body);
        });
      }
    } catch (e) {
      debugPrint('Gagal check similarity: $e');
    }
  }

  Future<void> handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (pembimbing == penguji ||
        pembimbing == penguji2 ||
        penguji == penguji2) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Dosen pembimbing dan penguji tidak boleh sama.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    bool skipConfirmation = true;
    for (var item in similarJudul) {
      if (((item['distance'] as num?)?.toInt() ?? 0) < 5) {
        skipConfirmation = false;
        break;
      }
    }

    if (!skipConfirmation) {
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('⚠️ Judul Mirip Ditemukan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Judul mirip dengan yang sudah ada:'),
              const SizedBox(height: 8),
              ...similarJudul.map((item) {
                final dist = (item['distance'] as num).toInt();
                return Text('• ${item['judul']} (jarak: $dist)');
              }),
              const SizedBox(height: 12),
              const Text('Yakin ingin melanjutkan?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Lanjutkan'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() => submitting = true);

    final payload = {
      'angkatan': angkatan,
      'judul_ta': judul,
      'nama_topik': topik,
      'prodi_id': prodiId,
      'dosen_pembimbing': pembimbing,
      'dosen_penguji': penguji,
      'dosen_penguji2': penguji2,
      'tahun': tahun,
    };

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        log('❌ Token tidak ditemukan. Pastikan login terlebih dahulu.');
        throw Exception('Token tidak tersedia');
      }

      log('🔐 Token digunakan: $token');
      log('📦 Payload: ${jsonEncode(payload)}');

      final res = await http.post(
        Uri.parse('$baseUrl/api/judul'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      log('📡 Status Code: ${res.statusCode}');
      log('📨 Response: ${res.body}');

      if ((res.statusCode == 200 || res.statusCode == 201) && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Berhasil mengajukan judul')),
        );
        _formKey.currentState!.reset();
        setState(() {
          angkatan = '';
          judul = '';
          topik = '';
          prodiId = '';
          pembimbing = '';
          penguji = '';
          penguji2 = '';
          similarJudul = [];
        });
      } else {
        throw Exception('Gagal mengajukan. Status: ${res.statusCode}');
      }
    } catch (e) {
      log('❌ Error saat submit: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('❌ Gagal mengajukan judul')));
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Pengajuan Judul TA')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: nim,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'NIM',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: nama,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: angkatan,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Angkatan',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => setState(() => angkatan = val),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Angkatan wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: prodiId.isEmpty ? null : prodiId,
                items: const [
                  DropdownMenuItem(
                    value: 'P-01',
                    child: Text('Sistem Informasi'),
                  ),
                  DropdownMenuItem(
                    value: 'P-02',
                    child: Text('Teknik Informatika'),
                  ),
                ],
                onChanged: (val) => setState(() => prodiId = val ?? ''),
                decoration: const InputDecoration(
                  labelText: 'Prodi',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Prodi wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: judul,
                decoration: const InputDecoration(
                  labelText: 'Judul TA',
                  border: OutlineInputBorder(),
                ),
                onChanged: onJudulChanged,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Judul wajib diisi';
                  if (val.length < 10) return 'Minimal 10 karakter';
                  return null;
                },
              ),
              if (similarJudul.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade100,
                    border: Border.all(color: Colors.yellow.shade700),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '⚠️ Judul Mirip:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...similarJudul.map((item) {
                        final dist = (item['distance'] as num).toInt();
                        return Text('• ${item['judul']} (jarak: $dist)');
                      }),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                initialValue: topik,
                decoration: const InputDecoration(
                  labelText: 'Topik / Metode',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => setState(() => topik = val),

                validator: (val) =>
                    val == null || val.isEmpty ? 'Topik wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: pembimbing.isEmpty ? null : pembimbing,
                items: dosenList
                    .map(
                      (d) => DropdownMenuItem(
                        value: d['id_dosen'].toString(),
                        child: Text(d['nama_dosen']),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => pembimbing = val ?? ''),
                decoration: const InputDecoration(
                  labelText: 'Dosen Pembimbing',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: penguji.isEmpty ? null : penguji,
                items: dosenList
                    .map(
                      (d) => DropdownMenuItem(
                        value: d['id_dosen'].toString(),
                        child: Text(d['nama_dosen']),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => penguji = val ?? ''),
                decoration: const InputDecoration(
                  labelText: 'Dosen Penguji 1',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: penguji2.isEmpty ? null : penguji2,
                items: dosenList
                    .map(
                      (d) => DropdownMenuItem(
                        value: d['id_dosen'].toString(),
                        child: Text(d['nama_dosen']),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => penguji2 = val ?? ''),
                decoration: const InputDecoration(
                  labelText: 'Dosen Penguji 2',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: tahun.toString(),
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Tahun',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitting ? null : handleSubmit,
                child: submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Ajukan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
