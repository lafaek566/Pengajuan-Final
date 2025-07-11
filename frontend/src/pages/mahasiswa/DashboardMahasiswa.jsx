import { useEffect } from "react";
import { getUser, logout } from "../../utils/auth";
import { useNavigate, Link } from "react-router-dom";
import { LogOut, FilePlus, Search, CalendarCheck } from "lucide-react";
import Navbar from "./Navbar";

export default function DashboardMahasiswa() {
  const navigate = useNavigate();
  const user = getUser();

  useEffect(() => {
    if (!user || user.level !== "mahasiswa") {
      navigate("/");
    }
  }, []);

  if (!user) return null;

  const menu = [
    {
      label: "Ajukan Judul TA",
      icon: <FilePlus className="w-5 h-5 mr-2 text-blue-600" />,
      to: "/mahasiswa/ajukan",
    },
    {
      label: "Cek Kemiripan Judul",
      icon: <Search className="w-5 h-5 mr-2 text-purple-600" />,
      to: "/mahasiswa/cek-kemiripan",
    },
    {
      label: "Lihat Status & Jadwal Ujian",
      icon: <CalendarCheck className="w-5 h-5 mr-2 text-green-600" />,
      to: "/mahasiswa/status",
    },
  ];

  return (
    <>
      <Navbar />
      <div className="max-w-3xl mx-auto p-6">
        <div className="bg-white shadow-lg rounded-xl p-6 mb-6">
          <h1 className="text-3xl font-bold text-gray-800 mb-2">
            Halo, {user.nama} 👋
          </h1>
          <p className="text-gray-600 text-sm mb-4">
            Selamat datang di Dashboard Mahasiswa
          </p>
          <button
            onClick={logout}
            className="flex items-center gap-2 bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600"
          >
            <LogOut className="w-4 h-4" />
            Logout
          </button>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          {menu.map((item, i) => (
            <Link
              to={item.to}
              key={i}
              className="flex items-center p-4 bg-white border rounded-lg shadow-sm hover:shadow-md transition duration-200 hover:border-blue-400"
            >
              {item.icon}
              <span className="font-medium text-gray-800">{item.label}</span>
            </Link>
          ))}
        </div>
      </div>
    </>
  );
}
