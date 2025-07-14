import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../constants/env.dart';

class NotifikasiLonceng extends StatefulWidget {
  final String nim;
  final VoidCallback? onViewed;

  const NotifikasiLonceng({super.key, required this.nim, this.onViewed});

  @override
  State<NotifikasiLonceng> createState() => _NotifikasiLoncengState();
}

class _NotifikasiLoncengState extends State<NotifikasiLonceng>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _timer;

  Map<String, dynamic>? proposalData;
  bool isSubmitted = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fetchAndCheckStatus();

    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchAndCheckStatus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchAndCheckStatus() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/api/judul/status/${widget.nim}"),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final status = data['status_persetujuan'];

        setState(() {
          isSubmitted = true;
        });

        if (status == "Y" || status == "T") {
          _controller.repeat(reverse: true);
          setState(() {
            proposalData = data;
          });
        } else {
          _controller.stop();
        }
      } else {
        setState(() {
          isSubmitted = false;
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil status proposal: $e");
      setState(() {
        isSubmitted = false;
      });
    }
  }

  void _handleTap() {
    if (!isSubmitted) {
      Fluttertoast.showToast(
        msg: "⚠️ Kamu belum mengajukan Judul TA.",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      return;
    }

    if (proposalData == null) {
      Fluttertoast.showToast(
        msg: "⌛ Proposal sedang diproses.",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.blueGrey,
        textColor: Colors.white,
      );
      return;
    }

    Fluttertoast.showToast(
      msg: "📢 Proposal kamu sudah diproses!",
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("📄 Status Proposal"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            info("Judul", proposalData!['judul_ta']),
            info("Status", statusText(proposalData!['status_persetujuan'])),
            info(
              "Tanggal Persetujuan",
              formatTanggal(proposalData!['tgl_persetujuan']),
            ),
            info("Tanggal Ujian", formatTanggal(proposalData!['tgl_ujian'])),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                proposalData = null;
              });
            },
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  String formatTanggal(String? tgl) {
    if (tgl == null || tgl.isEmpty) return "-";
    try {
      final date = DateTime.parse(tgl).toLocal();
      return "${DateFormat("EEEE, dd MMMM yyyy – HH:mm", "id_ID").format(date)} WIB";
    } catch (_) {
      return "-";
    }
  }

  String statusText(String? s) {
    if (s == "Y") return "✅ Disetujui";
    if (s == "T") return "❌ Ditolak";
    return "⌛ Belum Diproses";
  }

  Widget info(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          text: "$label: ",
          style: const TextStyle(fontWeight: FontWeight.bold),
          children: [
            TextSpan(
              text: (value != null && value.isNotEmpty) ? value : "-",
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isProcessed =
        proposalData?['status_persetujuan'] == "Y" ||
        proposalData?['status_persetujuan'] == "T";

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          RotationTransition(
            turns: Tween(begin: -0.05, end: 0.05).animate(_controller),
            child: IconButton(
              icon: Icon(
                Icons.notifications_active,
                color: isProcessed ? Colors.amber : Colors.grey,
              ),
              tooltip: isProcessed
                  ? 'Proposal diproses'
                  : !isSubmitted
                  ? 'Belum ajukan TA'
                  : 'Proposal sedang diproses',
              onPressed: _handleTap,
            ),
          ),
          if (isProcessed)
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                child: const Center(
                  child: Text(
                    '1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
