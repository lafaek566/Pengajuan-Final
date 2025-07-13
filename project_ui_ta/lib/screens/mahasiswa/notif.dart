import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class NotifikasiLonceng extends StatefulWidget {
  final bool show;
  final VoidCallback onReset;
  final Map<String, dynamic> proposalData;

  const NotifikasiLonceng({
    super.key,
    required this.show,
    required this.onReset,
    required this.proposalData,
  });

  @override
  State<NotifikasiLonceng> createState() => _NotifikasiLoncengState();
}

class _NotifikasiLoncengState extends State<NotifikasiLonceng>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    Fluttertoast.showToast(
      msg: "📢 Proposal kamu sudah diproses!",
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );

    // Tampilkan dialog status lengkap
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("📄 Status Proposal"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            info("Judul", widget.proposalData['judul_ta']),
            info(
              "Status",
              statusText(widget.proposalData['status_persetujuan']),
            ),
            info(
              "Tanggal Persetujuan",
              formatTanggal(widget.proposalData['tgl_persetujuan']),
            ),
            info(
              "Tanggal Ujian",
              formatTanggal(widget.proposalData['tgl_ujian']),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onReset(); // Reset notifikasi setelah dilihat
            },
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
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
    if (!widget.show) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          RotationTransition(
            turns: Tween(begin: -0.05, end: 0.05).animate(_controller),
            child: IconButton(
              icon: const Icon(Icons.notifications_active, color: Colors.amber),
              tooltip: 'Proposal diproses',
              onPressed: _handleTap,
            ),
          ),
          // Badge merah dengan angka
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
