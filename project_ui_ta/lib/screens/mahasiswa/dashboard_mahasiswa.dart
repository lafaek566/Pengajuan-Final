import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';
import './notif.dart'; // NotifikasiLonceng

class DashboardMahasiswaPage extends StatefulWidget {
  const DashboardMahasiswaPage({super.key});

  @override
  State<DashboardMahasiswaPage> createState() => _DashboardMahasiswaPageState();
}

class _DashboardMahasiswaPageState extends State<DashboardMahasiswaPage> {
  Map<String, dynamic>? user;
  bool showNotif = false;

  // 👉 Simulasi data proposal (ini bisa kamu ganti pakai API nantinya)
  Map<String, dynamic> dataProposal = {
    'judul_ta': 'Aplikasi TA dengan Flutter',
    'status_persetujuan': 'Y', // bisa 'Y', 'T', atau null
    'tgl_persetujuan': '2025-07-13T10:30:00.000Z',
    'tgl_ujian': '2025-07-20T08:00:00.000Z',
  };

  @override
  void initState() {
    super.initState();
    getUser();
  }

  Future<void> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString("user");

    if (userStr == null) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed("/");
      return;
    }

    final userData = jsonDecode(userStr);
    if (userData['level'] != 'mahasiswa') {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed("/");
      return;
    }

    setState(() {
      user = userData;
    });

    // ✅ Cek status untuk munculkan notifikasi
    if (dataProposal['status_persetujuan'] == 'Y' ||
        dataProposal['status_persetujuan'] == 'T') {
      setState(() => showNotif = true);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed("/");
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Center(child: CircularProgressIndicator());

    final List<Map<String, dynamic>> menu = [
      {
        "label": "Ajukan Judul TA",
        "icon": Icons.assignment,
        "color": Colors.blue,
        "route": AppRoutes.formAjukanJudul,
      },
      {
        "label": "Cek Kemiripan Judul",
        "icon": Icons.search,
        "color": Colors.purple,
        "route": AppRoutes.cekKemiripan,
      },
      {
        "label": "Lihat Status & Jadwal Ujian",
        "icon": Icons.calendar_today,
        "color": Colors.green,
        "route": AppRoutes.statusTA,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Mahasiswa"),
        actions: [
          NotifikasiLonceng(
            nim: user!['nim'],
            onViewed: () => setState(() => showNotif = false),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Halo, ${user!['nama']} 👋",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Selamat datang di Dashboard Mahasiswa",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: logout,
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Menu
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: menu.map((item) {
                  return InkWell(
                    onTap: () => Navigator.pushNamed(context, item['route']),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 2),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(item['icon'], color: item['color'], size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item['label'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
