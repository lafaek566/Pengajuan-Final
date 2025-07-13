import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
  int proposalDisetujui = 0;
  int proposalDitolak = 0;
  int proposalPending = 0;
  List<String> daftarTopik = [];

  @override
  void initState() {
    super.initState();
    checkUser();
    fetchStats();
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
    try {
      final res = await http.get(
        Uri.parse('http://localhost:5009/api/dashboard/stats'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          totalDosen = data['dosen'];
          totalMahasiswa = data['mahasiswa'];
          totalJudul = data['judul'];
          totalTopik = data['topik'];
          proposalDisetujui = data['proposal_disetujui'];
          proposalDitolak = data['proposal_ditolak'];
          proposalPending = data['proposal_pending'];
          daftarTopik = List<String>.from(data['daftar_topik'] ?? []);
        });
      } else {
        debugPrint('Gagal ambil statistik: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('fetchStats error: $e');
    }
  }

  Widget buildStatCard(String title, int value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(80)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget buildTopikList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          "Topik Terdaftar:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...daftarTopik.map(
          (t) => Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 4),
            color: Colors.deepPurple.withAlpha(20),
            child: ListTile(
              dense: true,
              leading: const Icon(
                Icons.label,
                size: 20,
                color: Colors.deepPurple,
              ),
              title: Text(t, style: const TextStyle(fontSize: 14)),
            ),
          ),
        ),
      ],
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
                      child: ListView(
                        children: [
                          Text(
                            "Hai, $nama 👋",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.2,
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
                                "Judul",
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
                              buildStatCard(
                                "Disetujui",
                                proposalDisetujui,
                                Icons.check_circle,
                                Colors.green,
                              ),
                              buildStatCard(
                                "Ditolak",
                                proposalDitolak,
                                Icons.cancel,
                                Colors.red,
                              ),
                              buildStatCard(
                                "Pending",
                                proposalPending,
                                Icons.hourglass_empty,
                                Colors.grey,
                              ),
                            ],
                          ),
                          buildTopikList(),
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
