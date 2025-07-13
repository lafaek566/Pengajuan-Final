import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // Wajib untuk locale ID

// Routes
import 'routes/app_routes.dart';

// Auth
import 'screens/auth/login.dart';
import 'screens/auth/register.dart';

// Dashboard
import 'screens/mahasiswa/dashboard_mahasiswa.dart';
import 'screens/dosen/dashboard_dosen.dart';
import 'screens/admin/dashboard_admin.dart';

// Mahasiswa pages
import 'screens/mahasiswa/form_ajukan_judul.dart';
import 'screens/mahasiswa/status_proposal.dart';
import 'screens/mahasiswa/status_ta_page.dart';
import 'screens/mahasiswa/cek_kemiripan.dart';

// Admin pages
import 'screens/admin/admin_users.dart';
import 'screens/admin/admin_proposal.dart';
import 'screens/admin/admin_judul.dart';
import 'screens/admin/admin_dosen.dart';

// Dosen pages
import 'screens/dosen/dosen_judul.dart';
import 'screens/dosen/dosen_proposal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null); // <-- Tambahkan baris ini
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pengajuan TA',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.login,
      routes: {
        // Auth
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.register: (_) => const RegisterMahasiswa(),

        // Dashboard
        AppRoutes.dashboardMahasiswa: (_) => const DashboardMahasiswaPage(),
        AppRoutes.dashboardDosen: (_) => const DashboardDosen(),
        AppRoutes.dashboardAdmin: (_) => const AdminDashboard(),

        // Mahasiswa
        AppRoutes.formAjukanJudul: (_) => const FormAjukanJudul(),
        AppRoutes.statusProposal: (_) => const StatusProposalPage(),
        AppRoutes.statusTA: (_) => const StatusTaPage(),
        AppRoutes.cekKemiripan: (_) => const CekKemiripan(),

        // Admin
        AppRoutes.adminUsers: (_) => const AdminUsers(),
        AppRoutes.adminProdi: (_) => const AdminProposalPage(),
        AppRoutes.adminTopik: (_) => const AdminJudulPage(),
        AppRoutes.adminDosen: (_) => const AdminDosenPage(),

        // Dosen
        AppRoutes.judulDosen: (_) => const DosenJudul(),
        AppRoutes.proposalDosen: (_) => const DosenProposal(),
      },
    );
  }
}
