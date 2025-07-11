import { useEffect, useState } from "react";
import { getUser, logout } from "../../utils/auth";
import { useNavigate } from "react-router-dom";
import DosenJudul from "./DosenJudul";
import DosenProposal from "./DosenProposal";
import api from "../../utils/axiosInstance";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend,
} from "recharts";
import {
  LayoutDashboard,
  FileText,
  ClipboardList,
  LogOut,
  Menu,
  X,
} from "lucide-react";

export default function DashboardDosen() {
  const navigate = useNavigate();
  const user = getUser();
  const [tab, setTab] = useState("dashboard");
  const [showSidebar, setShowSidebar] = useState(false);

  const [stats, setStats] = useState({
    dosen: 0,
    mahasiswa: 0,
    judul: 0,
    topik: 0,
    proposal_disetujui: 0,
    proposal_ditolak: 0,
    proposal_pending: 0,
    daftar_topik: [],
  });

  useEffect(() => {
    if (!user || user.level !== "dosen") {
      navigate("/");
    }
  }, []);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const res = await api.get("/api/dashboard/stats");
        setStats(res.data);
      } catch (err) {
        console.error("❌ Gagal memuat statistik:", err);
      }
    };
    fetchStats();
  }, []);

  if (!user) return null;

  const menus = [
    {
      key: "dashboard",
      label: "Dashboard",
      icon: <LayoutDashboard size={18} />,
    },
    { key: "judul", label: "Judul TA", icon: <FileText size={18} /> },
    { key: "proposal", label: "Proposal", icon: <ClipboardList size={18} /> },
  ];

  return (
    <div className="min-h-screen bg-gray-100 md:flex">
      {/* Sidebar */}
      <div
        className={`fixed top-0 left-0 z-40 h-full w-80 bg-white shadow-md p-4 space-y-6 transition-transform duration-300
        ${showSidebar ? "translate-x-0" : "-translate-x-full"}
        md:translate-x-0 md:relative md:z-0`}
      >
        <div className="flex items-center justify-between md:block">
          <div>
            <h2 className="text-xl font-bold text-blue-600">Dosen Panel</h2>
            <p className="text-sm text-gray-500">👨‍🏫 {user.nama}</p>
          </div>
          <button
            className="md:hidden text-gray-700"
            onClick={() => setShowSidebar(false)}
          >
            <X size={24} />
          </button>
        </div>

        <nav className="flex flex-col space-y-2 mt-4">
          {menus.map((menu) => (
            <button
              key={menu.key}
              onClick={() => {
                setTab(menu.key);
                setShowSidebar(false);
              }}
              className={`flex items-center gap-2 px-4 py-2 rounded text-left hover:bg-blue-100 transition ${
                tab === menu.key ? "bg-blue-500 text-white" : "text-gray-700"
              }`}
            >
              {menu.icon}
              <span>{menu.label}</span>
            </button>
          ))}
        </nav>

        <button
          onClick={() => {
            logout();
            navigate("/");
          }}
          className="mt-auto bg-red-500 hover:bg-red-600 text-white px-4 py-2 rounded flex items-center gap-2"
        >
          <LogOut size={18} /> Logout
        </button>
      </div>

      {/* Overlay mobile */}
      {showSidebar && (
        <div
          className="fixed inset-0 bg-black bg-opacity-30 z-30 md:hidden"
          onClick={() => setShowSidebar(false)}
        ></div>
      )}

      {/* Main Content */}
      <div className="flex-1s">
        {/* Header Mobile */}
        <div className="flex items-center justify-between bg-white px-4 py-3 shadow md:hidden">
          <button onClick={() => setShowSidebar(true)}>
            <Menu size={24} />
          </button>
          <h2 className="text-lg font-semibold text-blue-600">
            Dashboard Dosen
          </h2>
          <div className="w-6" />
        </div>

        <main className="p-4 md:p-6">
          {tab === "dashboard" && (
            <>
              <div className="bg-white p-6 rounded shadow mb-6">
                <h3 className="text-lg font-bold text-blue-700 mb-4">
                  📘 Statistik
                </h3>
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-center mb-6">
                  <Card title="Dosen" count={stats.dosen} color="blue" />
                  <Card
                    title="Mahasiswa"
                    count={stats.mahasiswa}
                    color="green"
                  />
                  <Card title="Judul TA" count={stats.judul} color="yellow" />
                  <Card title="Topik TA" count={stats.topik} color="purple" />
                </div>

                {stats.daftar_topik.length > 0 && (
                  <>
                    <h4 className="text-md font-semibold text-gray-700 mb-2">
                      🎓 Topik TA
                    </h4>
                    <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-2">
                      {stats.daftar_topik.map((topik, i) => (
                        <div
                          key={i}
                          className="bg-gray-100 hover:bg-gray-200 text-gray-800 text-sm px-4 py-2 rounded shadow-sm"
                        >
                          {topik}
                        </div>
                      ))}
                    </div>
                  </>
                )}
              </div>

              <div className="bg-white p-4 rounded shadow mb-6">
                <h3 className="text-lg font-semibold mb-4">
                  📊 Statistik Proposal
                </h3>
                <ResponsiveContainer width="100%" height={300}>
                  <BarChart
                    data={[
                      { name: "Disetujui", jumlah: stats.proposal_disetujui },
                      { name: "Ditolak", jumlah: stats.proposal_ditolak },
                      { name: "Pending", jumlah: stats.proposal_pending },
                    ]}
                  >
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="name" />
                    <YAxis allowDecimals={false} />
                    <Tooltip />
                    <Legend />
                    <Bar dataKey="jumlah" fill="#4299E1" />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </>
          )}

          {tab === "judul" && (
            <div className="bg-white p-4 rounded shadow">
              <DosenJudul />
            </div>
          )}

          {tab === "proposal" && (
            <div className="bg-white p-4 rounded shadow">
              <DosenProposal />
            </div>
          )}
        </main>
      </div>
    </div>
  );
}

// Card Komponen
function Card({ title, count, color }) {
  const colorMap = {
    blue: "bg-blue-100 text-blue-800",
    green: "bg-green-100 text-green-800",
    yellow: "bg-yellow-100 text-yellow-800",
    purple: "bg-purple-100 text-purple-800",
  };

  return (
    <div className={`p-4 rounded shadow ${colorMap[color]}`}>
      <p className="text-sm">{title}</p>
      <p className="text-2xl font-bold">{count}</p>
    </div>
  );
}
