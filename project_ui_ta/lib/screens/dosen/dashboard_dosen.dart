import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

import '../mahasiswa/cek_kemiripan.dart';

import '../../routes/app_routes.dart';
import 'dosen_judul.dart';
import 'dosen_proposal.dart';

class DashboardDosen extends StatefulWidget {
  const DashboardDosen({super.key});

  @override
  State<DashboardDosen> createState() => _DashboardDosenState();
}

class _DashboardDosenState extends State<DashboardDosen> {
  String tab = 'judul';
  bool loading = true;
  String? namaUser;

  @override
  void initState() {
    super.initState();
    checkUser();
  }

  Future<void> checkUser() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('user');
    if (user != null) {
      final userData = jsonDecode(user);
      if (userData['level'] != 'dosen') {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      } else {
        setState(() {
          namaUser = userData['nama'];
          loading = false;
        });
      }
    } else {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Dosen"),
        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(namaUser ?? "-"),
              accountEmail: const Text("Dosen Panel"),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text("Judul TA"),
              onTap: () {
                setState(() => tab = 'judul');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text("Proposal"),
              onTap: () {
                setState(() => tab = 'proposal');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text("Cek Kemiripan Judul"),
              onTap: () {
                setState(() => tab = 'kemiripan');
                Navigator.pop(context);
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: logout,
            ),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Builder(
              builder: (context) {
                if (tab == 'judul') {
                  return const DosenJudul();
                } else if (tab == 'proposal') {
                  return const DosenProposal();
                } else if (tab == 'kemiripan') {
                  return const CekKemiripan();
                } else {
                  return const Center(child: Text("Halaman tidak ditemukan."));
                }
              },
            ),
    );
  }
}
