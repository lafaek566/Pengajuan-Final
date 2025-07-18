import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/env.dart';
import 'dart:developer' as developer;

class AdminJudulPage extends StatefulWidget {
  const AdminJudulPage({super.key});

  @override
  State<AdminJudulPage> createState() => _AdminJudulPageState();
}

class _AdminJudulPageState extends State<AdminJudulPage> {
  List<dynamic> data = [];
  List<dynamic> prodiOptions = [];
  List<dynamic> dosenOptions = [];
  List<dynamic> mahasiswaOptions = [];
  Map<String, dynamic> form = {};
  int currentPage = 1;
  final int rowsPerPage = 5;
  bool editMode = false;
  String filterProdi = "";

  @override
  void initState() {
    super.initState();
    fetchAll();
    fetchDosen();
    fetchProdi();
    fetchMahasiswa();
    resetForm();
  }

  void resetForm() {
    setState(() {
      form = {
        "id_judul": "",
        "judul_ta": "",
        "nim": "",
        "prodi_id": "",
        "nama_topik": "",
        "dosen_pembimbing": "",
        "dosen_penguji": "",
        "dosen_penguji2": "",
        "tahun": DateTime.now().year.toString(),
        "angkatan": "", // Tambahan field angkatan
      };
      editMode = false;
    });
  }

  Future<void> fetchAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        developer.log('Token tidak tersedia, fetchAll dibatalkan');
        return;
      }
      final res = await http.get(
        Uri.parse('$baseUrl/api/judul'),
        headers: {"Authorization": "Bearer $token"},
      );
      if (!mounted) return;

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        setState(() => data = decoded);
      } else {
        developer.log("Gagal fetchAll: ${res.statusCode} ${res.body}");
      }
    } catch (e) {
      developer.log("Error fetchAll: $e");
    }
  }

  Future<void> fetchProdi() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/admin/prodi'));
      if (!mounted) return;

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        setState(() => prodiOptions = decoded);
      } else {
        developer.log("Gagal fetchProdi: ${res.statusCode} ${res.body}");
      }
    } catch (e) {
      developer.log("Error fetchProdi: $e");
    }
  }

  Future<void> fetchDosen() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/admin/dosen'));
      if (!mounted) return;

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        setState(() => dosenOptions = decoded);
      } else {
        developer.log("Gagal fetchDosen: ${res.statusCode} ${res.body}");
      }
    } catch (e) {
      developer.log("Error fetchDosen: $e");
    }
  }

  Future<void> fetchMahasiswa() async {
    if (!mounted) return;
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/admin/mahasiswa'),
        headers: {'Accept': 'application/json'},
      );

      developer.log('fetchMahasiswa status: ${res.statusCode}');
      developer.log('fetchMahasiswa body: ${res.body}');

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);

        if (body is List) {
          final filtered = body
              .where(
                (user) =>
                    user is Map &&
                    user['nim'] != null &&
                    user['nama_mahasiswa'] != null,
              )
              .map(
                (user) => {
                  'nim': user['nim'],
                  'nama': user['nama_mahasiswa'], // ← disesuaikan
                  'username': user['username'] ?? '',
                  'angkatan': user['angkatan'] ?? '-',
                  'label': '${user['nama_mahasiswa']} (${user['nim']})',
                },
              )
              .toList();

          developer.log('Filtered mahasiswa: $filtered');
          setState(() => mahasiswaOptions = filtered);
        } else {
          developer.log("Unexpected response format: not a List");
        }
      } else {
        developer.log("Gagal fetchMahasiswa: ${res.statusCode} ${res.body}");
      }
    } catch (e, stackTrace) {
      developer.log("Error fetchMahasiswa: $e", stackTrace: stackTrace);
    }
  }

  Future<void> handleSubmit() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (!mounted) return;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token tidak tersedia. Harap login ulang.'),
        ),
      );
      return;
    }

    // Validasi form, tambah angkatan
    final requiredFields = {
      "judul_ta": "Judul TA",
      "nim": "Mahasiswa",
      "prodi_id": "Prodi",
      "nama_topik": "Topik",
      "dosen_pembimbing": "Dosen Pembimbing",
      "dosen_penguji": "Dosen Penguji 1",
      "dosen_penguji2": "Dosen Penguji 2",
      "tahun": "Tahun",
      "angkatan": "Angkatan", // Validasi tambahan
    };

    for (final entry in requiredFields.entries) {
      final key = entry.key;
      final label = entry.value;
      final value = form[key];

      developer.log("Cek field $key ($label): ${value?.toString() ?? 'null'}");

      if (value == null || value.toString().trim().isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Field '$label' wajib diisi")));
        return;
      }
    }

    final url = editMode
        ? '$baseUrl/api/judul/${form['id_judul']}'
        : '$baseUrl/api/judul';
    final method = editMode ? 'PUT' : 'POST';

    try {
      final res = await (method == 'POST'
          ? http.post(
              Uri.parse(url),
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer $token",
              },
              body: jsonEncode(form),
            )
          : http.put(
              Uri.parse(url),
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer $token",
              },
              body: jsonEncode(form),
            ));

      if (!mounted) return;

      if (res.statusCode == 200 || res.statusCode == 201) {
        resetForm();
        await fetchAll();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              editMode ? "Data berhasil diupdate" : "Data berhasil disimpan",
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: ${res.body}')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saat menyimpan: $e')));
    }
  }

  Future<void> handleDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Yakin ingin menghapus judul ini?"),
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

    if (confirmed != true) return;

    if (!mounted) return;

    try {
      final res = await http.delete(Uri.parse('$baseUrl/api/judul/$id'));

      if (!mounted) return;

      if (res.statusCode == 200) {
        await fetchAll();

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Data berhasil dihapus")));
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal hapus: ${res.body}')));
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saat menghapus: $e')));
    }
  }

  void handleEdit(Map<String, dynamic> item) {
    setState(() {
      form = {
        "id_judul": item['id_judul'] ?? '',
        "judul_ta": item['judul_ta'] ?? '',
        "nim": item['nim'] ?? '',
        "prodi_id": item['prodi_id'] ?? '',
        "nama_topik": item['nama_topik'] ?? '',
        "dosen_pembimbing": item['dosen_pembimbing'] ?? '',
        "dosen_penguji": item['dosen_penguji'] ?? '',
        "dosen_penguji2": item['dosen_penguji2'] ?? '',
        "tahun": item['tahun'].toString(),
        "angkatan":
            item['angkatan']?.toString() ?? '', // isi angkatan saat edit
      };
      editMode = true;
    });
  }

  String getNamaFromNim(String nim) {
    final m = mahasiswaOptions.firstWhere(
      (mhs) => mhs['nim'] == nim,
      orElse: () => {'nama': '-'},
    );
    return m['nama'];
  }

  String getUsernameFromNim(String nim) {
    final m = mahasiswaOptions.firstWhere(
      (mhs) => mhs['nim'] == nim,
      orElse: () => {'username': '-'},
    );
    return m['username'];
  }

  String getAngkatanFromNim(String nim) {
    final m = mahasiswaOptions.firstWhere(
      (mhs) => mhs['nim'] == nim,
      orElse: () => {'angkatan': '-'},
    );
    return m['angkatan'].toString();
  }

  String getDosenName(String id) => dosenOptions.firstWhere(
    (d) => d['id_dosen'] == id,
    orElse: () => {'nama_dosen': id},
  )['nama_dosen'];

  String getProdiName(String id) => prodiOptions.firstWhere(
    (p) => p['id_prodi'] == id,
    orElse: () => {'nama_prodi': id},
  )['nama_prodi'];

  Widget _input(String label, String field, {TextInputType? keyboard}) {
    return SizedBox(
      width: 180,
      child: TextFormField(
        keyboardType: keyboard,
        initialValue: form[field],
        onChanged: (val) => setState(() => form[field] = val),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    String field,
    List list,
    String idField,
    String labelField,
  ) {
    String? selectedValue = form[field]?.toString();
    bool isValidValue = list.any((item) => item[idField] == selectedValue);
    if (!isValidValue) selectedValue = null;

    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        items: list.map<DropdownMenuItem<String>>((item) {
          return DropdownMenuItem(
            value: item[idField],
            child: Text(item[labelField]),
          );
        }).toList(),
        onChanged: (val) => setState(() => form[field] = val),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = filterProdi.isEmpty
        ? data
        : data.where((d) => d['prodi_id'] == filterProdi).toList();
    final totalPages = (filteredData.length / rowsPerPage).ceil();
    final start = (currentPage - 1) * rowsPerPage;
    final paginated = filteredData.sublist(
      start,
      start + rowsPerPage > filteredData.length
          ? filteredData.length
          : start + rowsPerPage,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            editMode ? "\u270F\uFE0F Edit Judul TA" : "\u2795 Tambah Judul TA",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _input("ID Judul", "id_judul"),
              _input("Judul TA", "judul_ta"),
              _dropdown(
                "Mahasiswa (NIM)",
                "nim",
                mahasiswaOptions,
                "nim",
                "label",
              ),
              _input("Topik", "nama_topik"),
              _dropdown(
                "Prodi",
                "prodi_id",
                prodiOptions,
                "id_prodi",
                "nama_prodi",
              ),
              _dropdown(
                "Pembimbing",
                "dosen_pembimbing",
                dosenOptions,
                "id_dosen",
                "nama_dosen",
              ),
              _dropdown(
                "Penguji 1",
                "dosen_penguji",
                dosenOptions,
                "id_dosen",
                "nama_dosen",
              ),
              _dropdown(
                "Penguji 2",
                "dosen_penguji2",
                dosenOptions,
                "id_dosen",
                "nama_dosen",
              ),
              _input("Tahun", "tahun", keyboard: TextInputType.number),
              _input(
                "Angkatan",
                "angkatan",
                keyboard: TextInputType.number,
              ), // input angkatan
              Row(
                children: [
                  ElevatedButton(
                    onPressed: handleSubmit,
                    child: Text(editMode ? "Update" : "Simpan"),
                  ),
                  const SizedBox(width: 8),
                  if (editMode)
                    ElevatedButton(
                      onPressed: resetForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: const Text("Batal"),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text("Filter Prodi:"),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: filterProdi.isEmpty ? null : filterProdi,
                hint: const Text("Semua"),
                items: [
                  const DropdownMenuItem(value: "", child: Text("Semua")),
                  ...prodiOptions.map(
                    (p) => DropdownMenuItem(
                      value: p['id_prodi'],
                      child: Text(p['nama_prodi']),
                    ),
                  ),
                ],
                onChanged: (val) => setState(() {
                  filterProdi = val ?? "";
                  currentPage = 1;
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 700) {
                // Tampilan mobile (card)
                return Column(
                  children: paginated.map((d) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Judul: ${d['judul_ta'] ?? '-'}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text("NIM: ${d['nim'] ?? '-'}"),
                            Text("Nama: ${getNamaFromNim(d['nim'] ?? '')}"),
                            Text(
                              "Username: ${getUsernameFromNim(d['nim'] ?? '')}",
                            ),
                            Text(
                              "Angkatan: ${getAngkatanFromNim(d['nim'] ?? '')}",
                            ),
                            Text("Topik: ${d['nama_topik'] ?? '-'}"),
                            Text("Prodi: ${getProdiName(d['prodi_id'] ?? '')}"),
                            Text(
                              "Pembimbing: ${getDosenName(d['dosen_pembimbing'] ?? '')}",
                            ),
                            Text(
                              "Penguji 1: ${getDosenName(d['dosen_penguji'] ?? '')}",
                            ),
                            Text(
                              "Penguji 2: ${getDosenName(d['dosen_penguji2'] ?? '')}",
                            ),
                            Text("Tahun: ${d['tahun']}"),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () => handleEdit(d),
                                  child: const Text("Edit"),
                                ),
                                TextButton(
                                  onPressed: () => handleDelete(d['id_judul']),
                                  child: const Text(
                                    "Hapus",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              } else {
                // Tampilan desktop (datatable)
                return DataTable(
                  columns: const [
                    DataColumn(label: Text('Judul')),
                    DataColumn(label: Text('NIM')),
                    DataColumn(label: Text('Nama')),
                    DataColumn(label: Text('Angkatan')),
                    DataColumn(label: Text('Username')),
                    DataColumn(label: Text('Topik')),
                    DataColumn(label: Text('Prodi')),
                    DataColumn(label: Text('Pembimbing')),
                    DataColumn(label: Text('Penguji 1')),
                    DataColumn(label: Text('Penguji 2')),
                    DataColumn(label: Text('Tahun')),
                    DataColumn(label: Text('Aksi')),
                  ],
                  rows: paginated.map((d) {
                    return DataRow(
                      cells: [
                        DataCell(Text(d['judul_ta'] ?? '-')),
                        DataCell(Text(d['nim'] ?? '-')),
                        DataCell(Text(getNamaFromNim(d['nim'] ?? ''))),
                        DataCell(
                          Text(getAngkatanFromNim(d['nim'] ?? '')),
                        ), // angkatan di sini
                        DataCell(Text(getUsernameFromNim(d['nim'] ?? ''))),
                        DataCell(Text(d['nama_topik'] ?? '-')),
                        DataCell(Text(getProdiName(d['prodi_id'] ?? ''))),
                        DataCell(
                          Text(getDosenName(d['dosen_pembimbing'] ?? '')),
                        ),
                        DataCell(Text(getDosenName(d['dosen_penguji'] ?? ''))),
                        DataCell(Text(getDosenName(d['dosen_penguji2'] ?? ''))),
                        DataCell(Text(d['tahun'].toString())),
                        DataCell(
                          Wrap(
                            spacing: 4,
                            children: [
                              TextButton(
                                onPressed: () => handleEdit(d),
                                child: const Text("Edit"),
                              ),
                              TextButton(
                                onPressed: () => handleDelete(d['id_judul']),
                                child: const Text(
                                  "Hapus",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text("Halaman $currentPage dari $totalPages"),
              Row(
                children: [
                  TextButton(
                    onPressed: currentPage > 1
                        ? () => setState(() => currentPage--)
                        : null,
                    child: const Text("\u2B05\uFE0F Prev"),
                  ),
                  TextButton(
                    onPressed: currentPage < totalPages
                        ? () => setState(() => currentPage++)
                        : null,
                    child: const Text("Next \u27A1\uFE0F"),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
