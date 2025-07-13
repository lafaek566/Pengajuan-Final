import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CetakPdf extends StatelessWidget {
  final Map<String, dynamic> data;

  const CetakPdf({super.key, required this.data});

  String formatTanggal(String? tgl) {
    if (tgl == null || tgl.isEmpty) return '-';
    try {
      final date = DateTime.parse(tgl);
      final formatter = DateFormat('EEEE, dd MMMM yyyy HH:mm', 'id_ID');
      return '${formatter.format(date)} WIB';
    } catch (_) {
      return '-';
    }
  }

  String statusText(String? s) {
    if (s == 'Y') return '✅ Disetujui';
    if (s == 'T') return '❌ Ditolak';
    return '⌛ Belum Diproses';
  }

  String getWatermarkText(String? s) {
    if (s == 'Y') return 'IKUT SIDANG';
    if (s == 'T') return 'DITOLAK';
    return '';
  }

  PdfColor getWatermarkColor(String? s) {
    if (s == 'Y') return PdfColors.green300;
    if (s == 'T') return PdfColors.red300;
    return PdfColors.grey300;
  }

  Future<pw.Document> _generatePdf() async {
    final pdf = pw.Document();

    final watermark = getWatermarkText(data['status_persetujuan']);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Stack(
            children: [
              if (watermark.isNotEmpty)
                pw.Center(
                  child: pw.Transform.rotate(
                    angle: -0.5, // sekitar -30 derajat
                    child: pw.Opacity(
                      opacity: 0.3,
                      child: pw.Text(
                        watermark,
                        style: pw.TextStyle(
                          fontSize: 80,
                          fontWeight: pw.FontWeight.bold,
                          color: getWatermarkColor(data['status_persetujuan']),
                        ),
                      ),
                    ),
                  ),
                ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(32),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Bukti Pendaftaran Proposal Tugas Akhir',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text('Nama: ${data['nama_mahasiswa'] ?? "-"}'),
                    pw.Text('NIM: ${data['nim'] ?? "-"}'),
                    pw.Text('Prodi: ${data['nama_prodi'] ?? "-"}'),
                    pw.Text('Judul: ${data['judul_ta'] ?? "-"}'),
                    pw.Text('Topik: ${data['nama_topik'] ?? "-"}'),
                    pw.Text(
                      'Dosen Pembimbing: ${data['nama_pembimbing'] ?? "-"}',
                    ),
                    pw.Text('Penguji 1: ${data['nama_penguji'] ?? "-"}'),
                    pw.Text('Penguji 2: ${data['nama_penguji2'] ?? "-"}'),
                    pw.Text(
                      'Status Proposal: ${statusText(data['status_persetujuan'])}',
                    ),
                    pw.Text(
                      'Tanggal Ujian: ${formatTanggal(data['tgl_ujian'])}',
                    ),
                  ],
                  mainAxisSize: pw.MainAxisSize.min,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  void _printPdf(BuildContext context) async {
    final pdf = await _generatePdf();
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('Tidak ada data untuk ditampilkan'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Cetak Bukti Proposal',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  if (['Y', 'T'].contains(data['status_persetujuan']))
                    Positioned.fill(
                      child: Center(
                        child: Transform.rotate(
                          angle: -0.5,
                          child: Opacity(
                            opacity: 0.15,
                            child: Text(
                              getWatermarkText(data['status_persetujuan']),
                              style: TextStyle(
                                fontSize: 80,
                                fontWeight: FontWeight.bold,
                                color: data['status_persetujuan'] == 'Y'
                                    ? Colors.green[200]
                                    : Colors.red[200],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Bukti Pendaftaran Proposal Tugas Akhir',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Nama: ${data['nama_mahasiswa'] ?? "-"}'),
                      Text('NIM: ${data['nim'] ?? "-"}'),
                      Text('Prodi: ${data['nama_prodi'] ?? "-"}'),
                      Text('Judul: ${data['judul_ta'] ?? "-"}'),
                      Text('Topik: ${data['nama_topik'] ?? "-"}'),
                      Text(
                        'Dosen Pembimbing: ${data['nama_pembimbing'] ?? "-"}',
                      ),
                      Text('Penguji 1: ${data['nama_penguji'] ?? "-"}'),
                      Text('Penguji 2: ${data['nama_penguji2'] ?? "-"}'),
                      Text(
                        'Status Proposal: ${statusText(data['status_persetujuan'])}',
                      ),
                      Text(
                        'Tanggal Ujian: ${formatTanggal(data['tgl_ujian'])}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _printPdf(context),
            icon: const Icon(Icons.download),
            label: const Text('Download PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
