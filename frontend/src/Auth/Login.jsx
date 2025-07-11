import { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { LogIn } from "lucide-react";
import api from "../utils/axiosInstance";

export default function Login() {
  const [form, setForm] = useState({ email: "", password: "" });
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      const res = await api.post("/api/auth/login", form);
      localStorage.setItem("token", res.data.token);
      localStorage.setItem("user", JSON.stringify(res.data.user));

      const role = res.data.user.level;
      if (role === "admin") navigate("/dashboard/admin");
      else if (role === "dosen") navigate("/dashboard/dosen");
      else if (role === "mahasiswa") navigate("/dashboard/mahasiswa");
      else alert("Role tidak dikenal");
    } catch (err) {
      alert("Login gagal. Email atau password salah.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-100 to-blue-300">
      <form
        onSubmit={handleSubmit}
        className="bg-white p-8 rounded-xl shadow-lg w-full max-w-sm animate-fadeIn"
      >
        <div className="flex items-center justify-center mb-6">
          <LogIn className="w-6 h-6 text-blue-600 mr-2" />
          <h2 className="text-2xl font-bold text-blue-700">Login</h2>
        </div>

        <input
          type="email"
          placeholder="Email"
          className="w-full mb-4 border border-gray-300 px-4 py-2 rounded focus:ring-2 focus:ring-blue-500 outline-none"
          onChange={(e) => setForm({ ...form, email: e.target.value })}
          required
        />
        <input
          type="password"
          placeholder="Password"
          className="w-full mb-4 border border-gray-300 px-4 py-2 rounded focus:ring-2 focus:ring-blue-500 outline-none"
          onChange={(e) => setForm({ ...form, password: e.target.value })}
          required
        />

        <button
          type="submit"
          disabled={loading}
          className="w-full bg-blue-600 text-white py-2 rounded hover:bg-blue-700 transition duration-200"
        >
          {loading ? "Memproses..." : "Login"}
        </button>

        <p className="text-sm text-center mt-4 text-gray-700">
          Belum punya akun?{" "}
          <Link
            to="/register"
            className="text-blue-600 hover:underline font-semibold"
          >
            Daftar Sekarang
          </Link>
        </p>
      </form>
    </div>
  );
}
