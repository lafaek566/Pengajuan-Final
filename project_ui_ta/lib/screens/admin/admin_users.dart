import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../constants/env.dart';

class AdminUsers extends StatefulWidget {
  const AdminUsers({super.key});

  @override
  State<AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends State<AdminUsers> {
  List users = [];
  final _formKey = GlobalKey<FormState>();
  String filterLevel = "all";

  final TextEditingController namaCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController nimCtrl =
      TextEditingController(); // 👈 Tambah NIM
  String selectedLevel = "mahasiswa";
  bool editMode = false;
  String? editingId;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchUsers() async {
    final token = await getToken();
    if (token == null) return;

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List) {
          setState(() => users = data);
        }
      }
    } catch (e) {
      debugPrint('Fetch users error: $e');
    }
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    final token = await getToken();
    if (token == null) return;

    final body = {
      "nama": namaCtrl.text,
      "email": emailCtrl.text,
      "password": passCtrl.text,
      "level": selectedLevel,
      "nim": nimCtrl.text, // 👈 Tambah NIM ke body
    };

    try {
      http.Response res;
      if (editMode && editingId != null) {
        res = await http.put(
          Uri.parse('$baseUrl/api/users/$editingId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        );
      } else {
        res = await http.post(
          Uri.parse('$baseUrl/api/users'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        );
      }

      if (res.statusCode == 200 || res.statusCode == 201) {
        resetForm();
        fetchUsers();
      }
    } catch (e) {
      debugPrint('Submit error: $e');
    }
  }

  Future<void> handleDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin menghapus user ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final token = await getToken();
      if (token == null) return;

      final res = await http.delete(
        Uri.parse('$baseUrl/api/users/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200 || res.statusCode == 204) {
        fetchUsers();
      }
    }
  }

  void handleEdit(Map user) {
    namaCtrl.text = user['nama'] ?? '';
    emailCtrl.text = user['email'] ?? '';
    nimCtrl.text = user['nim'] ?? ''; // 👈 Set NIM
    passCtrl.clear();
    selectedLevel = user['level'];
    editingId = user['id_users'];
    setState(() => editMode = true);
  }

  void resetForm() {
    namaCtrl.clear();
    emailCtrl.clear();
    passCtrl.clear();
    nimCtrl.clear(); // 👈 Reset NIM
    selectedLevel = "mahasiswa";
    editingId = null;
    setState(() => editMode = false);
  }

  Widget getBadge(String level) {
    Color color;
    switch (level) {
      case 'admin':
        color = Colors.red;
        break;
      case 'dosen':
        color = Colors.green;
        break;
      default:
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        level,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = filterLevel == "all"
        ? users
        : users.where((u) => u['level'] == filterLevel).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Kelola User")),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 700;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: namaCtrl,
                            decoration: const InputDecoration(
                              labelText: "Nama",
                            ),
                            validator: (val) => val == null || val.isEmpty
                                ? 'Wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: emailCtrl,
                            decoration: const InputDecoration(
                              labelText: "Email",
                            ),
                            validator: (val) => val == null || val.isEmpty
                                ? 'Wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: nimCtrl,
                            decoration: const InputDecoration(labelText: "NIM"),
                            validator: (val) {
                              if (selectedLevel == 'mahasiswa' &&
                                  (val == null || val.isEmpty)) {
                                return 'NIM wajib diisi untuk mahasiswa';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: passCtrl,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Password",
                            ),
                            validator: (val) {
                              if (!editMode && (val == null || val.isEmpty)) {
                                return 'Password wajib saat tambah';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField(
                            value: selectedLevel,
                            decoration: const InputDecoration(
                              labelText: "Level",
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'mahasiswa',
                                child: Text('Mahasiswa'),
                              ),
                              DropdownMenuItem(
                                value: 'dosen',
                                child: Text('Dosen'),
                              ),
                              DropdownMenuItem(
                                value: 'admin',
                                child: Text('Admin'),
                              ),
                            ],
                            onChanged: (val) =>
                                setState(() => selectedLevel = val!),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: submitForm,
                                child: Text(editMode ? 'Update' : 'Tambah'),
                              ),
                              if (editMode)
                                TextButton(
                                  onPressed: resetForm,
                                  child: const Text('Batal'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: ['all', 'mahasiswa', 'dosen', 'admin'].map((role) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: filterLevel == role
                            ? Colors.blue
                            : Colors.grey[300],
                        foregroundColor: filterLevel == role
                            ? Colors.white
                            : Colors.black,
                      ),
                      onPressed: () => setState(() => filterLevel = role),
                      child: Text(
                        role == 'all'
                            ? 'Semua'
                            : role[0].toUpperCase() + role.substring(1),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                isSmallScreen
                    ? Column(
                        children: filteredUsers.map((u) {
                          return Card(
                            child: ListTile(
                              title: Text(u['nama']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Email: ${u['email']}"),
                                  if (u['level'] == 'mahasiswa')
                                    Text("NIM: ${u['nim'] ?? '-'}"),
                                  getBadge(u['level']),
                                ],
                              ),
                              trailing: Wrap(
                                spacing: 4,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.orange,
                                    ),
                                    onPressed: () => handleEdit(u),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        handleDelete(u['id_users']),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    : Card(
                        elevation: 2,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text("Nama")),
                            DataColumn(label: Text("Email")),
                            DataColumn(label: Text("NIM")),
                            DataColumn(label: Text("Level")),
                            DataColumn(label: Text("Aksi")),
                          ],
                          rows: filteredUsers.map<DataRow>((u) {
                            return DataRow(
                              cells: [
                                DataCell(Text(u['nama'] ?? '-')),
                                DataCell(Text(u['email'] ?? '-')),
                                DataCell(Text(u['nim'] ?? '-')),
                                DataCell(getBadge(u['level'] ?? '-')),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.orange,
                                        ),
                                        onPressed: () => handleEdit(u),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            handleDelete(u['id_users']),
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
