import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { Bell, LogOut } from "lucide-react";
import { logout, getUser } from "../../utils/auth";
import { toast } from "react-toastify";

export default function NavbarMahasiswa() {
  const [notif, setNotif] = useState(false);
  const user = getUser();

  // Fungsi polling status proposal
  useEffect(() => {
    const fetchProposalStatus = async () => {
      const token = localStorage.getItem("token");
      if (!token) return;

      try {
        const res = await fetch(
          "http://localhost:5009/api/proposal/by-mahasiswa",
          {
            headers: {
              Authorization: `Bearer ${token}`,
            },
          }
        );
        const proposals = await res.json();
        if (!Array.isArray(proposals)) return;

        const latest = proposals[proposals.length - 1];
        const prevStatus = localStorage.getItem("last_status");

        if (
          latest?.status_persetujuan &&
          latest.status_persetujuan !== prevStatus
        ) {
          localStorage.setItem("notif", "1");
          localStorage.setItem("last_status", latest.status_persetujuan);
          setNotif(true);
          window.dispatchEvent(new Event("newProposalStatus"));

          if (latest.status_persetujuan === "Y") {
            toast.success("🎉 Proposal kamu telah disetujui!");
          } else if (latest.status_persetujuan === "T") {
            toast.error("❌ Proposal kamu ditolak!");
          }
        }
      } catch (err) {
        console.error("Gagal polling status proposal:", err);
      }
    };

    const interval = setInterval(fetchProposalStatus, 15000); // polling tiap 15 detik
    fetchProposalStatus();

    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    const handleNotif = () => {
      const updatedNotif = localStorage.getItem("notif") === "1";
      setNotif(updatedNotif);
    };

    window.addEventListener("newProposalStatus", handleNotif);
    handleNotif();

    return () => {
      window.removeEventListener("newProposalStatus", handleNotif);
    };
  }, []);

  const clearNotif = () => {
    localStorage.setItem("notif", "0");
    setNotif(false);
  };

  if (!user || user.level !== "mahasiswa") return null;

  return (
    <nav className="bg-white shadow px-4 py-3 flex justify-between items-center sticky top-0 z-50">
      <div className="text-xl font-bold text-blue-700">Sistem TA</div>

      <div className="flex items-center gap-4">
        <Link
          to="/mahasiswa/status"
          onClick={clearNotif}
          className="relative group"
          title="Notifikasi Proposal"
        >
          <Bell className="w-6 h-6 text-gray-700" />
          {notif && (
            <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full w-4 h-4 flex items-center justify-center animate-ping-short">
              1
            </span>
          )}
        </Link>

        <button
          onClick={logout}
          className="flex items-center gap-1 bg-red-500 text-white px-3 py-1.5 rounded hover:bg-red-600 text-sm"
          title="Logout"
        >
          <LogOut className="w-4 h-4" />
          Logout
        </button>
      </div>
    </nav>
  );
}
