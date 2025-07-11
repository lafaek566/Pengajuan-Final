import { useEffect, useState } from "react";
import api from "../../utils/axiosInstance";

export default function AdminProposal() {
  const [proposalList, setProposalList] = useState([]);
  const [loading, setLoading] = useState(true);
  const [errorMsg, setErrorMsg] = useState("");

  const [showModal, setShowModal] = useState(false);
  const [selectedId, setSelectedId] = useState(null);
  const [tglUjian, setTglUjian] = useState("");
  const [jamUjian, setJamUjian] = useState("");

  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 5;

  useEffect(() => {
    fetchProposal();
  }, []);

  const fetchProposal = async () => {
    try {
      setLoading(true);
      const res = await api.get("/api/proposal");
      setProposalList(res.data);
      setErrorMsg("");
    } catch (err) {
      console.error("❌ Gagal ambil data proposal:", err);
      setErrorMsg("Gagal memuat data proposal.");
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = (id) => {
    setSelectedId(id);
    setTglUjian("");
    setJamUjian("");
    setShowModal(true);
  };

  const submitApproval = async () => {
    if (!tglUjian || !/^\d{4}-\d{2}-\d{2}$/.test(tglUjian)) {
      alert("❌ Format tanggal salah. Gunakan format YYYY-MM-DD.");
      return;
    }

    const tanggalUjianLengkap = `${tglUjian}T${jamUjian || "00:00"}:00`;

    try {
      await api.put(`/api/proposal/status/${selectedId}`, {
        status_persetujuan: "Y",
        tgl_persetujuan: new Date().toISOString().split("T")[0],
        tgl_ujian: tanggalUjianLengkap,
      });

      setShowModal(false);
      fetchProposal();
    } catch (err) {
      alert("❌ Gagal menyetujui proposal.");
    }
  };

  const setStatusReject = async (id) => {
    try {
      await api.put(`/api/proposal/status/${id}`, {
        status_persetujuan: "T",
        tgl_persetujuan: new Date().toISOString().split("T")[0],
      });
      fetchProposal();
    } catch (err) {
      alert("❌ Gagal menolak proposal.");
    }
  };

  const handleDelete = async (id) => {
    const confirmDelete = confirm("🗑 Yakin ingin menghapus proposal ini?");
    if (!confirmDelete) return;

    try {
      await api.delete(`/api/proposal/${id}`);
      fetchProposal();
    } catch (err) {
      alert("❌ Gagal menghapus proposal.");
    }
  };

  const statusText = (s) => {
    if (s === "Y") return "✅ Disetujui";
    if (s === "T") return "❌ Ditolak";
    return "⌛ Belum Diproses";
  };

  const formatTanggal = (str) => {
    if (!str) return "-";
    return new Date(str).toLocaleString("id-ID", {
      day: "2-digit",
      month: "long",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
      timeZone: "Asia/Jakarta",
    });
  };

  const totalPages = Math.ceil(proposalList.length / itemsPerPage);
  const currentData = proposalList.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

  return (
    <div className="p-6">
      <h2 className="text-2xl font-bold mb-4">📑 Proposal Mahasiswa</h2>

      {loading ? (
        <p className="text-gray-500">Memuat data...</p>
      ) : errorMsg ? (
        <p className="text-red-500">{errorMsg}</p>
      ) : proposalList.length === 0 ? (
        <p className="text-gray-600">Belum ada proposal yang diajukan.</p>
      ) : (
        <>
          <table className="w-full table-auto border text-sm bg-white rounded shadow">
            <thead className="bg-gray-100">
              <tr>
                <th className="border px-2 py-1">#</th>
                <th className="border px-2 py-1">NIM</th>
                <th className="border px-2 py-1">Judul</th>
                <th className="border px-2 py-1">Tahun</th>
                <th className="border px-2 py-1">Status</th>
                <th className="border px-2 py-1">Tgl Ujian</th>
                <th className="border px-2 py-1">Aksi</th>
              </tr>
            </thead>
            <tbody>
              {currentData.map((p, idx) => (
                <tr key={p.id}>
                  <td className="border px-2 py-1 text-center">
                    {(currentPage - 1) * itemsPerPage + idx + 1}
                  </td>
                  <td className="border px-2 py-1">{p.nim}</td>
                  <td className="border px-2 py-1">{p.judul_ta || "—"}</td>
                  <td className="border px-2 py-1">{p.tahun}</td>
                  <td className="border px-2 py-1">
                    {statusText(p.status_persetujuan)}
                  </td>
                  <td className="border px-2 py-1">
                    {formatTanggal(p.tgl_ujian)}
                  </td>
                  <td className="border px-2 py-1 text-center space-y-1">
                    <button
                      onClick={() => handleApprove(p.id)}
                      className="bg-green-600 text-white px-2 py-1 rounded hover:bg-green-700 block w-full"
                    >
                      Setujui
                    </button>
                    <button
                      onClick={() => setStatusReject(p.id)}
                      className="bg-yellow-600 text-white px-2 py-1 rounded hover:bg-yellow-700 block w-full"
                    >
                      Tolak
                    </button>
                    <button
                      onClick={() => handleDelete(p.id)}
                      className="bg-red-600 text-white px-2 py-1 rounded hover:bg-red-700 block w-full"
                    >
                      Hapus
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>

          {/* Pagination */}
          <div className="flex justify-between items-center mt-4">
            <p className="text-sm text-gray-600">
              Halaman {currentPage} dari {totalPages}
            </p>
            <div className="space-x-2">
              <button
                onClick={() => setCurrentPage((p) => Math.max(p - 1, 1))}
                disabled={currentPage === 1}
                className="px-3 py-1 bg-gray-200 rounded hover:bg-gray-300 disabled:opacity-50"
              >
                ⬅ Sebelumnya
              </button>
              <button
                onClick={() =>
                  setCurrentPage((p) => Math.min(p + 1, totalPages))
                }
                disabled={currentPage === totalPages}
                className="px-3 py-1 bg-gray-200 rounded hover:bg-gray-300 disabled:opacity-50"
              >
                Berikutnya ➡
              </button>
            </div>
          </div>
        </>
      )}

      {/* Modal */}
      {showModal && (
        <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-40 z-50">
          <div className="bg-white p-6 rounded-lg w-80 shadow">
            <h3 className="text-lg font-bold mb-4">🗓 Setel Tanggal Ujian</h3>
            <input
              type="date"
              value={tglUjian}
              onChange={(e) => setTglUjian(e.target.value)}
              className="border px-3 py-2 w-full rounded mb-2"
            />
            <input
              type="time"
              value={jamUjian}
              onChange={(e) => setJamUjian(e.target.value)}
              className="border px-3 py-2 w-full rounded mb-4"
            />
            <div className="flex justify-end space-x-2">
              <button
                onClick={() => setShowModal(false)}
                className="px-4 py-2 bg-gray-300 rounded hover:bg-gray-400"
              >
                Batal
              </button>
              <button
                onClick={submitApproval}
                className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
              >
                Simpan
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
