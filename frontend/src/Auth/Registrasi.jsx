import { useState } from "react";
import { useNavigate } from "react-router-dom";
import api from "../utils/axiosInstance"; // gunakan instance

export default function RegisterMahasiswa() {
  const [form, setForm] = useState({
    nama: "",
    email: "",
    password: "",
  });
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await api.post("/api/users", {
        ...form,
        level: "mahasiswa",
      });
      alert("Registrasi berhasil! Silakan login.");
      navigate("/");
    } catch (err) {
      alert("Registrasi gagal! Cek email atau koneksi.");
    }
  };

  return (
    <div className="h-screen flex items-center justify-center bg-gray-100">
      <form
        onSubmit={handleSubmit}
        className="bg-white p-6 rounded shadow-md w-96"
      >
        <h2 className="text-xl mb-4 font-semibold text-center">
          Registrasi Mahasiswa
        </h2>
        <input
          type="text"
          placeholder="Nama Lengkap"
          className="w-full mb-3 border px-3 py-2 rounded"
          value={form.nama}
          onChange={(e) => setForm({ ...form, nama: e.target.value })}
          required
        />
        <input
          type="email"
          placeholder="Email"
          className="w-full mb-3 border px-3 py-2 rounded"
          value={form.email}
          onChange={(e) => setForm({ ...form, email: e.target.value })}
          required
        />
        <input
          type="password"
          placeholder="Password"
          className="w-full mb-4 border px-3 py-2 rounded"
          value={form.password}
          onChange={(e) => setForm({ ...form, password: e.target.value })}
          required
        />
        <input
          type="text"
          placeholder="NIM"
          className="w-full mb-3 border px-3 py-2 rounded"
          value={form.nim}
          onChange={(e) => setForm({ ...form, nim: e.target.value })}
          required
        />

        <button className="w-full bg-green-600 text-white py-2 rounded hover:bg-green-700">
          Daftar
        </button>
      </form>
    </div>
  );
}
