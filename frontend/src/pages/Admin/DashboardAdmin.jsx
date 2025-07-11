import { useEffect, useState } from "react";
import { getUser, logout } from "../../utils/auth";
import { useNavigate } from "react-router-dom";
import AdminUsers from "./AdminUsers";
import AdminJudul from "./AdminJudul";
import AdminProposal from "./AdminProposal";
import AdminDosen from "./AdmnDosen";
import {
  Users,
  BookOpen,
  ClipboardList,
  GraduationCap,
  LogOut,
  Menu,
  X,
} from "lucide-react";

export default function DashboardAdmin() {
  const navigate = useNavigate();
  const user = getUser();
  const [tab, setTab] = useState("users");
  const [showSidebar, setShowSidebar] = useState(false);

  useEffect(() => {
    if (!user || user.level !== "admin") {
      navigate("/");
    }
  }, []);

  if (!user) return null;

  const menus = [
    { key: "users", label: "User", icon: <Users size={18} /> },
    { key: "judul", label: "Judul TA", icon: <BookOpen size={18} /> },
    { key: "proposal", label: "Proposal", icon: <ClipboardList size={18} /> },
    { key: "dosen", label: "Dosen", icon: <GraduationCap size={18} /> },
  ];

  return (
    <div className="min-h-screen bg-gray-100 md:flex">
      {/* Sidebar */}
      <aside
        className={`fixed top-0 left-0 z-40 h-full w-64 bg-white shadow-md transform transition-transform duration-300
        ${showSidebar ? "translate-x-0" : "-translate-x-full"}
        md:translate-x-0 md:relative md:flex md:flex-col p-4 space-y-6`}
      >
        <div className="flex items-center justify-between md:block">
          <div>
            <h2 className="text-xl font-bold text-blue-600">Admin Panel</h2>
            <p className="text-sm text-gray-500">Halo, {user.nama}</p>
          </div>
          <button
            onClick={() => setShowSidebar(false)}
            className="md:hidden text-gray-700"
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
      </aside>

      {/* Overlay untuk mobile */}
      {showSidebar && (
        <div
          className="fixed inset-0 bg-black bg-opacity-30 z-30 md:hidden"
          onClick={() => setShowSidebar(false)}
        ></div>
      )}

      {/* Konten Utama */}
      <div className="flex-1">
        {/* Header di mobile */}
        <div className="md:hidden flex items-center justify-between bg-white px-4 py-3 shadow">
          <button onClick={() => setShowSidebar(true)}>
            <Menu size={24} />
          </button>
          <h2 className="text-lg font-semibold text-blue-600">
            Dashboard Admin
          </h2>
          <div className="w-6" />
        </div>

        {/* Konten */}
        <main className="p-4 md:p-6">
          <div className="bg-white rounded-lg shadow p-4">
            {tab === "users" && <AdminUsers />}
            {tab === "judul" && <AdminJudul />}
            {tab === "proposal" && <AdminProposal />}
            {tab === "dosen" && <AdminDosen />}
          </div>
        </main>
      </div>
    </div>
  );
}
