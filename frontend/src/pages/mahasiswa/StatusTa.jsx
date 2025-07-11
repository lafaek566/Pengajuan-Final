import { useState } from "react";
import axios from "axios";
import CetakPdf from "./CetakPdf";

export default function StatusTa() {
  const [nim, setNim] = useState("");
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState("");

  const fetchStatus = async () => {
    if (!nim) {
      setErrorMsg("❌ Masukkan NIM terlebih dahulu");
      return;
    }

    try {
      setLoading(true);
      setErrorMsg("");
      const res = await axios.get(
        `http://localhost:5009/api/judul/status/${nim}`
      );
      setData(res.data);
    } catch (err) {
      console.error("Gagal mengambil data status:", err);
      setErrorMsg("❌ Data tidak ditemukan");
      setData(null);
    } finally {
      setLoading(false);
    }
  };

  const formatTanggal = (tgl) => {
    if (!tgl) return "-";
    const date = new Date(tgl);
    return (
      date.toLocaleString("id-ID", {
        weekday: "long",
        day: "2-digit",
        month: "long",
        year: "numeric",
        hour: "2-digit",
        minute: "2-digit",
      }) + " WIB"
    );
  };

  const statusText = (s) => {
    if (s === "Y") return "✅ Disetujui";
    if (s === "T") return "❌ Ditolak";
    return "⌛ Belum Diproses";
  };

  return (
    <div className="p-6 max-w-xl mx-auto">
      <h2 className="text-2xl font-bold mb-4">📌 Cek Status Tugas Akhir</h2>

      <div className="flex space-x-2 mb-4">
        <input
          type="text"
          placeholder="Masukkan NIM"
          value={nim}
          onChange={(e) => setNim(e.target.value)}
          onKeyDown={(e) => e.key === "Enter" && fetchStatus()}
          className="border px-3 py-2 rounded w-full"
        />
        <button
          onClick={fetchStatus}
          className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
        >
          Cari
        </button>
      </div>

      {loading ? (
        <p>🔄 Memuat data...</p>
      ) : errorMsg ? (
        <p className="text-red-600">{errorMsg}</p>
      ) : data ? (
        <>
          <div className="bg-white rounded-lg shadow p-4 border border-gray-200 space-y-2">
            <p>
              <strong>Nama Mahasiswa:</strong> {data.nama_mahasiswa || "-"}
            </p>
            <p>
              <strong>NIM:</strong> {data.nim}
            </p>
            <p>
              <strong>Judul:</strong> {data.judul_ta}
            </p>
            <p>
              <strong>Topik:</strong> {data.nama_topik || "-"}
            </p>
            <p>
              <strong>Prodi:</strong> {data.nama_prodi}
            </p>
            <p>
              <strong>Pembimbing:</strong> {data.nama_pembimbing}
            </p>
            <p>
              <strong>Penguji 1:</strong> {data.nama_penguji || "-"}
            </p>
            <p>
              <strong>Penguji 2:</strong> {data.nama_penguji2 || "-"}
            </p>
            <p>
              <strong>Status Proposal:</strong>{" "}
              {statusText(data.status_persetujuan)}
            </p>
            <p>
              <strong>Tanggal Persetujuan:</strong>{" "}
              {formatTanggal(data.tgl_persetujuan)}
            </p>
            <p>
              <strong>Tanggal Ujian:</strong> {formatTanggal(data.tgl_ujian)}
            </p>
          </div>

          <CetakPdf data={data} />
        </>
      ) : null}
    </div>
  );
}
