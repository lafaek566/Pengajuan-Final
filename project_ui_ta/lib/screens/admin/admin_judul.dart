import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../constants/env.dart';

class AdminJudulPage extends StatefulWidget {
  const AdminJudulPage({super.key});

  @override
  State<AdminJudulPage> createState() => _AdminJudulPageState();
}

class _AdminJudulPageState extends State<AdminJudulPage> {
  List<dynamic> data = [];
  List<dynamic> prodiOptions = [];
  List<dynamic> dosenOptions = [];
  Map<String, dynamic> form = {
    "id_judul": "",
    "judul_ta": "",
    "nim": "",
    "prodi_id": "",
    "nama_topik": "",
    "dosen_pembimbing": "",
    "dosen_penguji": "",
    "dosen_penguji2": "",
    "tahun": DateTime.now().year,
  };
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
  }

  Future<void> fetchAll() async {
    final res = await http.get(Uri.parse('$baseUrl/api/judul'));
    if (res.statusCode == 200) {
      setState(() => data = jsonDecode(res.body));
    }
  }

  Future<void> fetchProdi() async {
    final res = await http.get(Uri.parse('$baseUrl/api/prodi'));
    if (res.statusCode == 200) {
      setState(() => prodiOptions = jsonDecode(res.body));
    }
  }

  Future<void> fetchDosen() async {
    final res = await http.get(Uri.parse('$baseUrl/api/admin/dosen'));
    if (res.statusCode == 200) {
      setState(() => dosenOptions = jsonDecode(res.body));
    }
  }

  Future<void> handleSubmit() async {
    final url = editMode
        ? '$baseUrl/api/judul/${form['id_judul']}'
        : '$baseUrl/api/judul';
    final method = editMode ? 'PUT' : 'POST';

    final res = await (method == 'POST'
        ? http.post(
            Uri.parse(url),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(form),
          )
        : http.put(
            Uri.parse(url),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(form),
          ));

    if (res.statusCode == 200 || res.statusCode == 201) {
      resetForm();
      fetchAll();
    }
  }

  Future<void> handleDelete(String id) async {
    final confirmed = await showDialog(
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

    if (confirmed == true) {
      final res = await http.delete(Uri.parse('$baseUrl/api/judul/$id'));
      if (res.statusCode == 200) fetchAll();
    }
  }

  void handleEdit(Map<String, dynamic> item) {
    setState(() {
      form = Map<String, dynamic>.from(item);
      editMode = true;
    });
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
        "tahun": DateTime.now().year,
      };
      editMode = false;
    });
  }

  String getDosenName(String id) => dosenOptions.firstWhere(
    (d) => d['id_dosen'] == id,
    orElse: () => {'nama_dosen': id},
  )['nama_dosen'];

  String getProdiName(String id) => prodiOptions.firstWhere(
    (p) => p['id_prodi'] == id,
    orElse: () => {'nama_prodi': id},
  )['nama_prodi'];

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
              _input("Judul TA", "judul_ta"),
              _input("NIM", "nim"),
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
                // ✅ MOBILE MODE: Use Card
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
                            Text("Nama: ${d['nama_mahasiswa'] ?? '-'}"),
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
                // ✅ DESKTOP MODE: Use DataTable
                return SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 900),
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Judul')),
                          DataColumn(label: Text('NIM')),
                          DataColumn(label: Text('Nama')),
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
                              DataCell(Text(d['nama_mahasiswa'] ?? '-')),
                              DataCell(Text(d['nama_topik'] ?? '-')),
                              DataCell(Text(getProdiName(d['prodi_id'] ?? ''))),
                              DataCell(
                                Text(getDosenName(d['dosen_pembimbing'] ?? '')),
                              ),
                              DataCell(
                                Text(getDosenName(d['dosen_penguji'] ?? '')),
                              ),
                              DataCell(
                                Text(getDosenName(d['dosen_penguji2'] ?? '')),
                              ),
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
                                      onPressed: () =>
                                          handleDelete(d['id_judul']),
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
                      ),
                    ),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 8,
            children: [
              Text("Halaman $currentPage dari $totalPages"),
              Row(
                mainAxisSize: MainAxisSize.min,
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

  Widget _input(String label, String field, {TextInputType? keyboard}) {
    return SizedBox(
      width: 180,
      child: TextFormField(
        keyboardType: keyboard,
        initialValue: form[field]?.toString(),
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
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String>(
        value: form[field]?.toString().isEmpty ?? true
            ? null
            : form[field]?.toString(),
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
}
