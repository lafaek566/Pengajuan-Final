import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

import '../../constants/env.dart'; // pastikan ada baseUrl
import '../../routes/app_routes.dart';

class RegisterMahasiswa extends StatefulWidget {
  const RegisterMahasiswa({super.key});

  @override
  State<RegisterMahasiswa> createState() => _RegisterMahasiswaState();
}

class _RegisterMahasiswaState extends State<RegisterMahasiswa> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nimController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  Future<void> handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    final body = jsonEncode({
      "nama": namaController.text,
      "email": emailController.text,
      "password": passwordController.text,
      "nim": int.tryParse(nimController.text), // kirim sebagai angka
      "level": "mahasiswa",
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users'),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      final resData = jsonDecode(response.body);
      log("Status: ${response.statusCode}");
      log("Response: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Berhasil"),
            content: Text(resData['msg'] ?? "Registrasi berhasil!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        throw Exception(resData['msg'] ?? "Gagal registrasi");
      }
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text("Registrasi gagal! Cek email atau koneksi.\n\n$e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      "Registrasi Mahasiswa",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: namaController,
                      decoration: const InputDecoration(
                        labelText: "Nama Lengkap",
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val == null || val.isEmpty
                          ? 'Nama wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val == null || val.isEmpty
                          ? 'Email wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val == null || val.length < 3
                          ? 'Password minimal 3 karakter'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nimController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "NIM",
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val == null || int.tryParse(val) == null
                          ? 'NIM harus berupa angka'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: loading ? null : handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: Text(loading ? "Memproses..." : "Daftar"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
