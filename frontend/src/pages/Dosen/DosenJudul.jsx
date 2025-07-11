import { useEffect, useState } from "react";
import api from "../../utils/axiosInstance";

export default function JudulListDosen() {
  const [listJudul, setListJudul] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 5;

  useEffect(() => {
    fetchJudul();
  }, []);

  const fetchJudul = async () => {
    try {
      const res = await api.get("/api/judul/with-status");
      const sorted = res.data.sort((a, b) => {
        const dateA = new Date(a.tgl_ujian || 0);
        const dateB = new Date(b.tgl_ujian || 0);
        return dateB - dateA;
      });
      setListJudul(sorted);
    } catch (err) {
      console.error("Gagal mengambil data judul:", err);
    }
  };

  const totalPages = Math.ceil(listJudul.length / itemsPerPage);
  const paginatedData = listJudul.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

  const formatTanggal = (tanggal) => {
    return tanggal
      ? new Date(tanggal).toLocaleString("id-ID", {
          day: "2-digit",
          month: "long",
          year: "numeric",
          hour: "2-digit",
          minute: "2-digit",
          timeZone: "Asia/Jakarta",
        })
      : "-";
  };

  const getStatusLabel = (status) => {
    if (status === "Y")
      return <span className="text-green-600 font-semibold">✅ Disetujui</span>;
    if (status === "T")
      return <span className="text-red-600 font-semibold">❌ Ditolak</span>;
    return <span className="text-gray-500 italic">⌛ Belum Diproses</span>;
  };

  return (
    <div className="p-4 md:p-6">
      <h2 className="text-xl font-bold mb-4">
        📄 Daftar Pengajuan Judul Mahasiswa
      </h2>

      <div className="overflow-x-auto">
        <table className="min-w-[1000px] w-full text-sm bg-white rounded shadow border">
          <thead className="bg-gray-200 text-left">
            <tr>
              <th className="border px-2 py-1">#</th>
              <th className="border px-2 py-1">NIM</th>
              <th className="border px-2 py-1">Nama Mahasiswa</th>
              <th className="border px-2 py-1">Judul</th>
              <th className="border px-2 py-1">Topik</th>
              <th className="border px-2 py-1">Prodi</th>
              <th className="border px-2 py-1">Pembimbing</th>
              <th className="border px-2 py-1">Penguji 1</th>
              <th className="border px-2 py-1">Penguji 2</th>
              <th className="border px-2 py-1">Tahun</th>
              <th className="border px-2 py-1">Tanggal Ujian</th>
              <th className="border px-2 py-1">Status</th>
            </tr>
          </thead>
          <tbody>
            {paginatedData.length > 0 ? (
              paginatedData.map((item, idx) => (
                <tr key={item.id_judul || idx} className="hover:bg-gray-50">
                  <td className="border px-2 py-1 text-center">
                    {(currentPage - 1) * itemsPerPage + idx + 1}
                  </td>
                  <td className="border px-2 py-1">{item.nim || "-"}</td>
                  <td className="border px-2 py-1">
                    {item.nama_mahasiswa || "-"}
                  </td>
                  <td className="border px-2 py-1">{item.judul_ta || "-"}</td>
                  <td className="border px-2 py-1">{item.nama_topik || "-"}</td>
                  <td className="border px-2 py-1">{item.nama_prodi || "-"}</td>
                  <td className="border px-2 py-1">
                    {item.nama_pembimbing || "-"}
                  </td>
                  <td className="border px-2 py-1">
                    {item.nama_penguji || "-"}
                  </td>
                  <td className="border px-2 py-1">
                    {item.nama_penguji2 || "-"}
                  </td>
                  <td className="border px-2 py-1">{item.tahun || "-"}</td>
                  <td className="border px-2 py-1">
                    {formatTanggal(item.tgl_ujian)}
                  </td>
                  <td className="border px-2 py-1">
                    {getStatusLabel(item.status_persetujuan)}
                  </td>
                </tr>
              ))
            ) : (
              <tr>
                <td className="text-center py-4" colSpan={12}>
                  Tidak ada data judul TA.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      <div className="flex flex-col sm:flex-row justify-between items-center mt-4 gap-2">
        <p className="text-sm text-gray-600">
          Halaman {currentPage} dari {totalPages}
        </p>
        <div className="space-x-2">
          <button
            onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
            disabled={currentPage === 1}
            className="px-3 py-1 rounded bg-gray-200 hover:bg-gray-300 disabled:opacity-50"
          >
            ⬅ Prev
          </button>
          <button
            onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
            disabled={currentPage === totalPages}
            className="px-3 py-1 rounded bg-gray-200 hover:bg-gray-300 disabled:opacity-50"
          >
            Next ➡
          </button>
        </div>
      </div>
    </div>
  );
}
