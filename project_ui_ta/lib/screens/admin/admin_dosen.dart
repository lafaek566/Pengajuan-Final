import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/env.dart'; // baseUrl

class AdminDosenPage extends StatefulWidget {
  const AdminDosenPage({super.key});

  @override
  State<AdminDosenPage> createState() => _AdminDosenPageState();
}

class _AdminDosenPageState extends State<AdminDosenPage> {
  List<Map<String, dynamic>> dosenList = [];
  bool editMode = false;

  final TextEditingController idDosenCtrl = TextEditingController();
  final TextEditingController namaDosenCtrl = TextEditingController();
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  String selectedProdi = "";
  String selectedPeran = "";

  final List<Map<String, String>> prodiOptions = [
    {"id": "P-01", "nama": "Sistem Informasi"},
    {"id": "P-02", "nama": "Teknik Informatika"},
  ];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/api/admin/dosen"));
      if (res.statusCode == 200) {
        final raw = jsonDecode(res.body);
        if (raw is List) {
          final data = raw.cast<Map<String, dynamic>>();
          data.sort(
            (a, b) =>
                b['id_dosen'].toString().compareTo(a['id_dosen'].toString()),
          );
          setState(() => dosenList = data);
        }
      }
    } catch (e) {
      showMsg("❌ Gagal ambil data: $e");
    }
  }

  Future<void> handleSubmit() async {
    final body = {
      "id_dosen": idDosenCtrl.text,
      "nama_dosen": namaDosenCtrl.text,
      "id_prodi": selectedProdi,
      "username": usernameCtrl.text,
      "password": passwordCtrl.text,
      "peran": selectedPeran,
    };

    try {
      if (editMode) {
        await http.put(
          Uri.parse("$baseUrl/api/admin/dosen/${idDosenCtrl.text}"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );
        showMsg("✅ Dosen berhasil diupdate");
      } else {
        await http.post(
          Uri.parse("$baseUrl/api/admin/dosen"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );
        showMsg("✅ Dosen berhasil ditambahkan");
      }
      resetForm();
      fetchData();
    } catch (e) {
      showMsg("❌ Gagal menyimpan data: $e");
    }
  }

  Future<void> handleDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Yakin ingin menghapus dosen ini?"),
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

    if (confirm == true) {
      try {
        await http.delete(Uri.parse("$baseUrl/api/admin/dosen/$id"));
        showMsg("✅ Dosen berhasil dihapus");
        fetchData();
      } catch (e) {
        showMsg("❌ Gagal menghapus dosen: $e");
      }
    }
  }

  void handleEdit(Map<String, dynamic> d) {
    idDosenCtrl.text = d['id_dosen'] ?? "";
    namaDosenCtrl.text = d['nama_dosen'] ?? "";
    usernameCtrl.text = d['username'] ?? "";
    passwordCtrl.clear();
    selectedPeran = d['peran'] ?? "";
    selectedProdi = d['id_prodi'] ?? "";
    setState(() => editMode = true);
  }

  void resetForm() {
    idDosenCtrl.clear();
    namaDosenCtrl.clear();
    usernameCtrl.clear();
    passwordCtrl.clear();
    selectedPeran = "";
    selectedProdi = "";
    setState(() => editMode = false);
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String getProdiName(String id) {
    return prodiOptions.firstWhere(
      (p) => p['id'] == id,
      orElse: () => {"nama": id},
    )['nama']!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kelola Dosen")),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 700;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  editMode ? "✏️ Edit Dosen" : "➕ Tambah Dosen",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: idDosenCtrl,
                  decoration: const InputDecoration(labelText: "ID Dosen"),
                  enabled: !editMode,
                ),
                TextField(
                  controller: namaDosenCtrl,
                  decoration: const InputDecoration(labelText: "Nama Dosen"),
                ),
                DropdownButtonFormField(
                  value: selectedProdi.isEmpty ? null : selectedProdi,
                  items: prodiOptions
                      .map(
                        (p) => DropdownMenuItem(
                          value: p['id'],
                          child: Text(p['nama']!),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => selectedProdi = val!),
                  decoration: const InputDecoration(labelText: "Program Studi"),
                ),
                TextField(
                  controller: usernameCtrl,
                  decoration: const InputDecoration(labelText: "Username"),
                ),
                TextField(
                  controller: passwordCtrl,
                  decoration: const InputDecoration(labelText: "Password"),
                  obscureText: true,
                ),
                DropdownButtonFormField(
                  value: selectedPeran.isEmpty ? null : selectedPeran,
                  items: ["pembimbing", "penguji"]
                      .map(
                        (val) => DropdownMenuItem(value: val, child: Text(val)),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => selectedPeran = val!),
                  decoration: const InputDecoration(labelText: "Peran"),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: handleSubmit,
                      child: Text(editMode ? "Update" : "Simpan"),
                    ),
                    const SizedBox(width: 8),
                    if (editMode)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        onPressed: resetForm,
                        child: const Text("Batal"),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  "📋 Daftar Dosen",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (isSmallScreen)
                  ...dosenList.map(
                    (d) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("🆔 ID: ${d['id_dosen'] ?? ''}"),
                            Text("👨‍🏫 Nama: ${d['nama_dosen'] ?? ''}"),
                            Text(
                              "🏫 Prodi: ${d['nama_prodi'] ?? getProdiName(d['id_prodi'] ?? '')}",
                            ),
                            Text("👤 Username: ${d['username'] ?? ''}"),
                            Text("🎓 Peran: ${d['peran'] ?? ''}"),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () => handleEdit(d),
                                  child: const Text("Edit"),
                                ),
                                TextButton(
                                  onPressed: () => handleDelete(d['id_dosen']),
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
                    ),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text("ID")),
                        DataColumn(label: Text("Nama")),
                        DataColumn(label: Text("Prodi")),
                        DataColumn(label: Text("Username")),
                        DataColumn(label: Text("Peran")),
                        DataColumn(label: Text("Aksi")),
                      ],
                      rows: dosenList.map<DataRow>((d) {
                        return DataRow(
                          cells: [
                            DataCell(Text(d['id_dosen'] ?? "")),
                            DataCell(Text(d['nama_dosen'] ?? "")),
                            DataCell(
                              Text(
                                d['nama_prodi'] ??
                                    getProdiName(d['id_prodi'] ?? ""),
                              ),
                            ),
                            DataCell(Text(d['username'] ?? "")),
                            DataCell(Text(d['peran'] ?? "")),
                            DataCell(
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () => handleEdit(d),
                                    child: const Text("Edit"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        handleDelete(d['id_dosen']),
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
              ],
            ),
          );
        },
      ),
    );
  }
}
