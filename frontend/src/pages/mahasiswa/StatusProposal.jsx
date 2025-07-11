import { useEffect, useState } from "react";
import axios from "axios";
import { toast, ToastContainer } from "react-toastify";
import { CheckCircle, XCircle, Clock } from "lucide-react";
import "react-toastify/dist/ReactToastify.css";

const formatTanggal = (tanggalString) => {
  if (!tanggalString) return "-";
  const tanggal = new Date(tanggalString);
  return tanggal.toLocaleDateString("id-ID", {
    day: "numeric",
    month: "long",
    year: "numeric",
  });
};

export default function StatusProposal() {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [updatingId, setUpdatingId] = useState(null);
  const token = localStorage.getItem("token");

  const fetchProposals = async () => {
    setLoading(true);
    try {
      const res = await axios.get(
        "http://localhost:5009/api/proposal/by-mahasiswa",
        {
          headers: { Authorization: `Bearer ${token}` },
        }
      );

      const proposals = res.data || [];
      setData(proposals);

      if (proposals.length === 0) {
        localStorage.setItem("notif", "0");
        localStorage.removeItem("last_status");
      } else {
        const latest = proposals[proposals.length - 1];
        const prevStatus = localStorage.getItem("last_status");

        if (
          latest?.status_persetujuan &&
          latest.status_persetujuan !== prevStatus
        ) {
          localStorage.setItem("notif", "1");
          localStorage.setItem("last_status", latest.status_persetujuan);
          window.dispatchEvent(new Event("newProposalStatus"));

          if (latest.status_persetujuan === "Y") {
            toast.success("🎉 Proposal kamu telah disetujui!");
          } else if (latest.status_persetujuan === "T") {
            toast.error("❌ Proposal kamu ditolak!");
          }
        }
      }
    } catch (err) {
      console.error("❌ Gagal ambil proposal:", err);
      toast.error("Gagal mengambil data proposal.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchProposals();
  }, []);

  const renderStatus = (status, tanggal) => {
    if (status === "Y") {
      return (
        <div className="flex items-center gap-2 text-green-600 font-medium">
          <CheckCircle className="w-5 h-5" />
          Disetujui pada {formatTanggal(tanggal)}
        </div>
      );
    } else if (status === "T") {
      return (
        <div className="flex items-center gap-2 text-red-600 font-medium">
          <XCircle className="w-5 h-5" />
          Ditolak pada {formatTanggal(tanggal)}
        </div>
      );
    } else {
      return (
        <div className="flex items-center gap-2 text-yellow-600 font-medium">
          <Clock className="w-5 h-5" />
          Menunggu persetujuan
        </div>
      );
    }
  };

  const handleUpdateStatus = async (id, statusBaru) => {
    setUpdatingId(id);
    try {
      await axios.post(
        `http://localhost:5009/api/proposal/${id}/update-status`,
        { status: statusBaru },
        { headers: { Authorization: `Bearer ${token}` } }
      );

      localStorage.setItem("notif", "1");
      localStorage.setItem("last_status", statusBaru);
      window.dispatchEvent(new Event("newProposalStatus"));

      toast.success(
        statusBaru === "Y"
          ? "Proposal disetujui!"
          : statusBaru === "T"
          ? "Proposal ditolak!"
          : "Status diperbarui!"
      );

      await fetchProposals();
    } catch (error) {
      toast.error("Gagal update status proposal.");
    } finally {
      setUpdatingId(null);
    }
  };

  return (
    <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <ToastContainer position="top-right" />
      <h1 className="text-3xl font-bold text-gray-800 mb-6">
        Status Proposal Tugas Akhir
      </h1>

      {loading ? (
        <p className="text-gray-500">Memuat data proposal...</p>
      ) : data.length === 0 ? (
        <p className="text-gray-500">Belum ada data proposal.</p>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
          {data.map((item) => (
            <div
              key={item.id}
              className="bg-white border rounded-xl shadow hover:shadow-lg transition p-6"
            >
              <h2 className="text-xl font-semibold text-blue-700 mb-1">
                {item.judul_ta}
              </h2>
              <p className="text-sm text-gray-600 mb-1">
                <span className="font-medium">Topik:</span>{" "}
                {item.nama_topik || "-"}
              </p>
              <p className="text-sm text-gray-600 mb-1">
                <span className="font-medium">Mahasiswa:</span>{" "}
                {item.nama_mahasiswa || "-"} ({item.nim})
              </p>
              <p className="text-sm text-gray-600 mb-1">
                <span className="font-medium">Prodi:</span> {item.prodi || "-"}
              </p>
              <p className="text-sm text-gray-600 mb-3">
                <span className="font-medium">Tahun:</span> {item.tahun}
              </p>
              <p className="text-sm text-gray-600 mb-1">
                <span className="font-medium">Pembimbing:</span>{" "}
                {item.nama_pembimbing || "-"}
              </p>
              <p className="text-sm text-gray-600 mb-1">
                <span className="font-medium">Penguji 1:</span>{" "}
                {item.nama_penguji1 || "-"}
              </p>
              <p className="text-sm text-gray-600 mb-3">
                <span className="font-medium">Penguji 2:</span>{" "}
                {item.nama_penguji2 || "-"}
              </p>
              <p className="text-sm text-gray-600 mb-3">
                <span className="font-medium">Tanggal Ujian:</span>{" "}
                {formatTanggal(item.tgl_ujian)}
              </p>
              <div>
                {renderStatus(item.status_persetujuan, item.tgl_persetujuan)}
              </div>

              {item.status_persetujuan !== "Y" &&
                item.status_persetujuan !== "T" && (
                  <div className="mt-4 flex gap-3">
                    <button
                      onClick={() => handleUpdateStatus(item.id, "Y")}
                      disabled={updatingId === item.id}
                      className={`px-3 py-1.5 rounded text-white ${
                        updatingId === item.id
                          ? "bg-green-400 cursor-not-allowed"
                          : "bg-green-600 hover:bg-green-700"
                      }`}
                    >
                      {updatingId === item.id ? "Memproses..." : "Terima"}
                    </button>
                    <button
                      onClick={() => handleUpdateStatus(item.id, "T")}
                      disabled={updatingId === item.id}
                      className={`px-3 py-1.5 rounded text-white ${
                        updatingId === item.id
                          ? "bg-red-400 cursor-not-allowed"
                          : "bg-red-600 hover:bg-red-700"
                      }`}
                    >
                      {updatingId === item.id ? "Memproses..." : "Tolak"}
                    </button>
                  </div>
                )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
