import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../routes/app_routes.dart';
import 'admin_users.dart';
import 'admin_judul.dart';
import 'admin_proposal.dart';
import 'admin_dosen.dart';
import 'admin_topik.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String? nama;
  String tab = 'dashboard';
  bool loading = true;

  int totalDosen = 0;
  int totalMahasiswa = 0;
  int totalJudul = 0;
  int totalTopik = 0;

  @override
  void initState() {
    super.initState();
    checkUser();
    fetchStats(); // ambil statistik
  }

  Future<void> checkUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    if (userData == null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    final user = jsonDecode(userData);
    if (user['level'] != 'admin') {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } else {
      setState(() {
        nama = user['nama'];
        loading = false;
      });
    }
  }

  Future<void> handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  Future<void> fetchStats() async {
    // Mock data sementara (ganti dengan API request jika tersedia)
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      totalDosen = 12;
      totalMahasiswa = 87;
      totalJudul = 35;
      totalTopik = 10;
    });
  }

  Widget buildStatCard(String title, int value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: color.withAlpha(230),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Admin"),
        actions: [
          IconButton(onPressed: handleLogout, icon: const Icon(Icons.logout)),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(nama ?? "-"),
              accountEmail: const Text("Admin Panel"),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.admin_panel_settings),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Dashboard"),
              onTap: () {
                setState(() => tab = 'dashboard');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("User"),
              onTap: () {
                setState(() => tab = 'users');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text("Dosen"),
              onTap: () {
                setState(() => tab = 'dosen');
                Navigator.pop(context);
              },
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
              leading: const Icon(Icons.topic),
              title: const Text("Topik"),
              onTap: () {
                setState(() => tab = 'topik');
                Navigator.pop(context);
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: handleLogout,
            ),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Builder(
              builder: (_) {
                switch (tab) {
                  case 'dashboard':
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hai, $nama 👋",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: GridView.count(
                              crossAxisCount:
                                  MediaQuery.of(context).size.width > 600
                                  ? 4
                                  : 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              children: [
                                buildStatCard(
                                  "Dosen",
                                  totalDosen,
                                  Icons.school,
                                  Colors.indigo,
                                ),
                                buildStatCard(
                                  "Mahasiswa",
                                  totalMahasiswa,
                                  Icons.people,
                                  Colors.teal,
                                ),
                                buildStatCard(
                                  "Judul TA",
                                  totalJudul,
                                  Icons.book,
                                  Colors.orange,
                                ),
                                buildStatCard(
                                  "Topik",
                                  totalTopik,
                                  Icons.topic,
                                  Colors.purple,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  case 'users':
                    return const AdminUsers();
                  case 'dosen':
                    return const AdminDosenPage();
                  case 'judul':
                    return const AdminJudulPage();
                  case 'proposal':
                    return const AdminProposalPage();
                  case 'topik':
                    return const AdminTopikPage();
                  default:
                    return const Center(
                      child: Text('Halaman tidak ditemukan.'),
                    );
                }
              },
            ),
    );
  }
}
