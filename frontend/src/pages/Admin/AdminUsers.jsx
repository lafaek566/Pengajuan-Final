import { useEffect, useState } from "react";
import api from "../../utils/axiosInstance";

export default function AdminUsers() {
  const [users, setUsers] = useState([]);
  const [form, setForm] = useState({
    nama: "",
    email: "",
    password: "",
    level: "mahasiswa",
  });
  const [editMode, setEditMode] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [filterLevel, setFilterLevel] = useState("all");

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    const res = await api.get("/api/users");
    setUsers(res.data);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (editMode) {
        await api.put(`/api/users/${editingId}`, form);
      } else {
        await api.post("/api/users", form);
      }
      resetForm();
      fetchUsers();
    } catch (error) {
      console.error("Error submitting form:", error);
    }
  };

  const handleEdit = (user) => {
    setForm({
      nama: user.nama,
      email: user.email,
      password: "",
      level: user.level,
    });
    setEditMode(true);
    setEditingId(user.id_users);
  };

  const handleDelete = async (id) => {
    if (confirm("Yakin ingin menghapus user ini?")) {
      await api.delete(`/api/users/${id}`);
      fetchUsers();
    }
  };

  const resetForm = () => {
    setForm({ nama: "", email: "", password: "", level: "mahasiswa" });
    setEditMode(false);
    setEditingId(null);
  };

  const getLevelBadge = (level) => {
    const base = "text-xs font-semibold px-2 py-1 rounded";
    switch (level) {
      case "admin":
        return `${base} bg-red-500 text-white`;
      case "dosen":
        return `${base} bg-green-500 text-white`;
      case "mahasiswa":
      default:
        return `${base} bg-blue-500 text-white`;
    }
  };

  return (
    <div className="max-w-3xl mx-auto p-6">
      <h2 className="text-2xl font-bold mb-6 text-center text-blue-800">
        Kelola Dosen & Mhs
      </h2>

      {/* FORM INPUT */}
      <form
        onSubmit={handleSubmit}
        className="bg-white shadow-md rounded-lg p-4 mb-6 space-y-4"
      >
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <input
            type="text"
            placeholder="Nama Lengkap"
            className="border px-3 py-2 rounded focus:outline-none focus:ring focus:border-blue-400"
            value={form.nama}
            onChange={(e) => setForm({ ...form, nama: e.target.value })}
            required
          />
          <input
            type="email"
            placeholder="Email"
            className="border px-3 py-2 rounded focus:outline-none focus:ring focus:border-blue-400"
            value={form.email}
            onChange={(e) => setForm({ ...form, email: e.target.value })}
            required
          />
          <input
            type="password"
            placeholder="Password"
            className="border px-3 py-2 rounded focus:outline-none focus:ring focus:border-blue-400"
            value={form.password}
            onChange={(e) => setForm({ ...form, password: e.target.value })}
            required={!editMode}
          />
          <select
            className="border px-3 py-2 rounded focus:outline-none focus:ring focus:border-blue-400"
            value={form.level}
            onChange={(e) => setForm({ ...form, level: e.target.value })}
          >
            <option value="mahasiswa">Mahasiswa</option>
            <option value="dosen">Dosen</option>
            <option value="admin">Admin</option>
          </select>
        </div>
        <div className="text-right">
          <button
            type="submit"
            className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded shadow"
          >
            {editMode ? "✏️ Update User" : "➕ Tambah User"}
          </button>
          {editMode && (
            <button
              type="button"
              onClick={resetForm}
              className="ml-2 bg-gray-500 hover:bg-gray-600 text-white px-6 py-2 rounded shadow"
            >
              Batal
            </button>
          )}
        </div>
      </form>

      {/* FILTER BUTTON */}
      <div className="mb-4 flex gap-2 flex-wrap">
        {["all", "mahasiswa", "dosen", "admin"].map((role) => (
          <button
            key={role}
            onClick={() => setFilterLevel(role)}
            className={`px-4 py-2 rounded ${
              filterLevel === role
                ? "bg-blue-600 text-white"
                : "bg-gray-200 hover:bg-gray-300"
            }`}
          >
            {role === "all"
              ? "Semua"
              : role.charAt(0).toUpperCase() + role.slice(1)}
          </button>
        ))}
      </div>

      {/* LIST USER */}
      <div className="bg-white shadow-md rounded-lg p-4">
        <h3 className="text-lg font-semibold mb-4">📄 Daftar User</h3>
        {users.length === 0 ? (
          <p className="text-gray-500">Belum ada user terdaftar.</p>
        ) : (
          <ul className="divide-y">
            {users
              .filter((u) => filterLevel === "all" || u.level === filterLevel)
              .map((u) => (
                <li
                  key={u.id_users}
                  className="py-3 flex justify-between items-center"
                >
                  <div>
                    <p className="font-medium">{u.nama}</p>
                    <p className="text-sm text-gray-600">{u.email}</p>
                    <span className={getLevelBadge(u.level)}>{u.level}</span>
                  </div>
                  <div className="flex gap-2">
                    <button
                      onClick={() => handleEdit(u)}
                      className="bg-yellow-500 hover:bg-yellow-600 text-white px-4 py-1 rounded"
                    >
                      ✏️ Edit
                    </button>
                    <button
                      onClick={() => handleDelete(u.id_users)}
                      className="bg-red-500 hover:bg-red-600 text-white px-4 py-1 rounded"
                    >
                      🗑 Hapus
                    </button>
                  </div>
                </li>
              ))}
          </ul>
        )}
      </div>
    </div>
  );
}
