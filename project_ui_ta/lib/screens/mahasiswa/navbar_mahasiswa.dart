import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/env.dart'; // import baseUrl

class NavbarMahasiswa extends StatefulWidget implements PreferredSizeWidget {
  const NavbarMahasiswa({super.key});

  @override
  State<NavbarMahasiswa> createState() => _NavbarMahasiswaState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _NavbarMahasiswaState extends State<NavbarMahasiswa> {
  bool notif = false;
  Timer? pollingTimer;

  @override
  void initState() {
    super.initState();
    _initNotifStatus();
    _startPolling();
  }

  Future<void> _initNotifStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('notif') ?? '0';
    setState(() {
      notif = stored == '1';
    });
  }

  void _startPolling() {
    pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _fetchProposalStatus();
    });
    _fetchProposalStatus(); // call once at start
  }

  Future<void> _fetchProposalStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/proposal/by-mahasiswa'),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final List<dynamic> proposals = jsonDecode(res.body);
        if (proposals.isEmpty) return;

        final latest = proposals.last;
        final latestStatus = latest["status_persetujuan"];
        final prevStatus = prefs.getString("last_status");

        if (latestStatus != null && latestStatus != prevStatus) {
          await prefs.setString("notif", "1");
          await prefs.setString("last_status", latestStatus);
          setState(() => notif = true);

          if (latestStatus == "Y") {
            Fluttertoast.showToast(msg: "🎉 Proposal kamu telah disetujui!");
          } else if (latestStatus == "T") {
            Fluttertoast.showToast(msg: "❌ Proposal kamu ditolak!");
          }
        }
      }
    } catch (e) {
      debugPrint("Gagal polling status proposal: $e");
    }
  }

  Future<void> _clearNotif() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notif', '0');
    setState(() => notif = false);
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("Sistem TA"),
      backgroundColor: Colors.white,
      elevation: 2,
      foregroundColor: Colors.blue.shade700,
      actions: [
        IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications),
              if (notif)
                const Positioned(
                  top: -4,
                  right: -4,
                  child: CircleAvatar(
                    radius: 6,
                    backgroundColor: Colors.red,
                    child: Text(
                      "1",
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          tooltip: "Notifikasi Proposal",
          onPressed: () {
            _clearNotif();
            Navigator.pushNamed(context, "/mahasiswa/status");
          },
        ),
        TextButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout, size: 16, color: Colors.white),
          label: const Text("Logout"),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
