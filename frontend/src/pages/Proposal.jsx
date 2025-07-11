import { useEffect } from "react";
import { getUser, logout } from "../utils/auth";
import { useNavigate, Link } from "react-router-dom";

export default function DashboardMahasiswa() {
  const navigate = useNavigate();
  const user = getUser();

  useEffect(() => {
    if (!user || user.level !== "mahasiswa") {
      navigate("/");
    }
  }, []);

  if (!user) return null;

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Halo, {user.nama} (Mahasiswa)</h1>
      <button
        onClick={logout}
        className="bg-red-500 text-white px-4 py-2 rounded mb-6"
      >
        Logout
      </button>
      <ul className="list-disc pl-6 space-y-2 text-blue-600">
        <li>
          <Link to="/mahasiswa/ajukan">✅ Ajukan Judul TA</Link>
        </li>
        <li>
          <Link to="/mahasiswa/cek-kemiripan">🔍 Cek Kemiripan Judul</Link>
        </li>
        <li>
          <Link to="/mahasiswa/status">📊 Lihat Status & Jadwal Ujian</Link>
        </li>
        <li>
          <Link to="/mahasiswa/cetak">🖨️ Cetak Bukti Pengajuan</Link>
        </li>
      </ul>
    </div>
  );
}
