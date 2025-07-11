import { useEffect } from "react";
import { getUser, logout } from "../utils/auth";
import { useNavigate } from "react-router-dom";

export default function Dashboard() {
  const navigate = useNavigate();
  const user = getUser();

  useEffect(() => {
    if (!user) {
      navigate("/");
    }
  }, []);

  if (!user) return null;

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">
        Selamat Datang, {user.nama} ({user.level})
      </h1>

      <button
        onClick={logout}
        className="bg-red-500 text-white px-4 py-2 rounded mb-6"
      >
        Logout
      </button>

      {user.level === "mahasiswa" && (
        <div>
          <h2 className="text-lg font-semibold mb-2">Menu Mahasiswa</h2>
          <ul className="list-disc pl-6">
            <li>Ajukan Judul</li>
            <li>Cek Kemiripan Judul</li>
            <li>Status Judul & Jadwal Ujian</li>
          </ul>
        </div>
      )}

      {user.level === "dosen" && (
        <div>
          <h2 className="text-lg font-semibold mb-2">Menu Dosen</h2>
          <ul className="list-disc pl-6">
            <li>Setujui Judul TA</li>
            <li>Lihat Data Bimbingan</li>
          </ul>
        </div>
      )}

      {user.level === "admin" && (
        <div>
          <h2 className="text-lg font-semibold mb-2">Menu Admin Prodi</h2>
          <ul className="list-disc pl-6">
            <li>Input Data Dosen & Mahasiswa</li>
            <li>Kelola Judul</li>
            <li>Kelola Jadwal Ujian</li>
          </ul>
        </div>
      )}
    </div>
  );
}
