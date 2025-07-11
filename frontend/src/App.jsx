import { Routes, Route } from "react-router-dom";
import Login from "./Auth/Login";
import RegisterMahasiswa from "./Auth/Registrasi";

import Dashboard from "./pages/Dashboard";
import DashboardAdmin from "./pages/Admin/DashboardAdmin";
import DashboardDosen from "./pages/Dosen/DashboardDosen";

import DashboardMahasiswa from "./pages/mahasiswa/DashboardMahasiswa";
import FormAjukanJudul from "./pages/mahasiswa/FromAjukanJudul";
import CekKemiripan from "./pages/mahasiswa/CekKemiripan";
import StatusTA from "./pages/mahasiswa/StatusTa";
import CetakPDF from "./pages/mahasiswa/CetakPdf";

import JudulTA from "./pages/JudulTA";
import Proposal from "./pages/Proposal";
import Users from "./pages/Users";

import StatusProposal from "./pages/mahasiswa/StatusProposal";

function App() {
  return (
    <Routes>
      <Route path="/" element={<Login />} />
      <Route path="/register" element={<RegisterMahasiswa />} />
      <Route path="/dashboard" element={<Dashboard />} />
      <Route path="/dashboard/mahasiswa" element={<DashboardMahasiswa />} />
      <Route path="/mahasiswa/status" element={<StatusProposal />} />
      <Route path="/mahasiswa/ajukan" element={<FormAjukanJudul />} />
      <Route path="/mahasiswa/cek-kemiripan" element={<CekKemiripan />} />
      <Route path="/mahasiswa/status" element={<StatusTA />} />
      <Route path="/mahasiswa/cetak" element={<CetakPDF />} />
      <Route path="/dashboard/dosen" element={<DashboardDosen />} />
      <Route path="/dashboard/admin" element={<DashboardAdmin />} />
      <Route path="/judul" element={<JudulTA />} />
      <Route path="/proposal" element={<Proposal />} />
      <Route path="/users" element={<Users />} />
    </Routes>
  );
}

export default App;
