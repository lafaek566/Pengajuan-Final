import { useEffect, useState } from "react";
import api from "../../utils/axiosInstance";

export default function AdminDosen() {
  const [dosenList, setDosenList] = useState([]);
  const [form, setForm] = useState({
    id_dosen: "",
    nama_dosen: "",
    id_prodi: "",
    username: "",
    password: "",
    peran: "",
  });
  const [editMode, setEditMode] = useState(false);

  const prodiOptions = [
    { id: "P-01", nama: "Sistem Informasi" },
    { id: "P-02", nama: "Teknik Informatika" },
  ];

  const fetchData = async () => {
    try {
      const res = await api.get("/api/admin/dosen");

      const sorted = res.data.sort((a, b) =>
        b.id_dosen.localeCompare(a.id_dosen)
      );
      setDosenList(sorted);
    } catch (err) {
      console.error("❌ Gagal mengambil data dosen:", err);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (editMode) {
        await api.put(`/api/admin/dosen/${form.id_dosen}`, form);
        alert("✅ Dosen berhasil diupdate");
      } else {
        await api.post("/api/admin/dosen", form);
        alert("✅ Dosen berhasil ditambahkan");
      }
      resetForm();
      fetchData();
    } catch (err) {
      console.error("❌ Gagal menyimpan data dosen:", err);
      alert("❌ Gagal menyimpan data dosen");
    }
  };

  const handleDelete = async (id) => {
    if (confirm("Yakin ingin menghapus dosen ini?")) {
      try {
        await api.delete(`/api/admin/dosen/${id}`);
        alert("🗑️ Dosen berhasil dihapus");
        fetchData();
      } catch (err) {
        alert("❌ Gagal menghapus dosen");
      }
    }
  };

  const handleEdit = (dosen) => {
    setForm({ ...dosen, password: "" });
    setEditMode(true);
  };

  const resetForm = () => {
    setForm({
      id_dosen: "",
      nama_dosen: "",
      id_prodi: "",
      username: "",
      password: "",
      peran: "",
    });
    setEditMode(false);
  };

  const getProdiName = (id) =>
    prodiOptions.find((p) => p.id === id)?.nama || id;

  useEffect(() => {
    fetchData();
  }, []);

  return (
    <div className="p-6 max-w-4xl mx-auto">
      <h2 className="text-2xl font-bold mb-4 text-blue-700">
        {editMode ? "✏️ Edit Dosen" : "➕ Tambah Dosen"}
      </h2>

      <form
        onSubmit={handleSubmit}
        className="space-y-3 mb-6 bg-white p-4 rounded shadow-md"
      >
        <input
          className="border p-2 w-full rounded"
          placeholder="ID Dosen"
          value={form.id_dosen}
          onChange={(e) => setForm({ ...form, id_dosen: e.target.value })}
          disabled={editMode}
          required
        />
        <input
          className="border p-2 w-full rounded"
          placeholder="Nama Dosen"
          value={form.nama_dosen}
          onChange={(e) => setForm({ ...form, nama_dosen: e.target.value })}
          required
        />
        <select
          className="border p-2 w-full rounded"
          value={form.id_prodi}
          onChange={(e) => setForm({ ...form, id_prodi: e.target.value })}
          required
        >
          <option value="">Pilih Prodi</option>
          {prodiOptions.map((p) => (
            <option key={p.id} value={p.id}>
              {p.nama}
            </option>
          ))}
        </select>
        <input
          className="border p-2 w-full rounded"
          placeholder="Username"
          value={form.username}
          onChange={(e) => setForm({ ...form, username: e.target.value })}
          required
        />
        <input
          className="border p-2 w-full rounded"
          placeholder="Password"
          type="password"
          value={form.password}
          onChange={(e) => setForm({ ...form, password: e.target.value })}
          required={!editMode}
        />
        <select
          className="border p-2 w-full rounded"
          value={form.peran}
          onChange={(e) => setForm({ ...form, peran: e.target.value })}
          required
        >
          <option value="">Pilih Peran</option>
          <option value="pembimbing">Pembimbing</option>
          <option value="penguji">Penguji</option>
        </select>

        <div className="flex gap-2">
          <button
            className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded"
            type="submit"
          >
            {editMode ? "Update" : "Simpan"}
          </button>
          {editMode && (
            <button
              className="bg-gray-500 hover:bg-gray-600 text-white px-4 py-2 rounded"
              type="button"
              onClick={resetForm}
            >
              Batal
            </button>
          )}
        </div>
      </form>

      <table className="w-full border text-sm bg-white rounded shadow-md overflow-hidden">
        <thead>
          <tr className="bg-blue-100 text-blue-800">
            <th className="border px-3 py-2">ID</th>
            <th className="border px-3 py-2">Nama</th>
            <th className="border px-3 py-2">Prodi</th>
            <th className="border px-3 py-2">Username</th>
            <th className="border px-3 py-2">Peran</th>
            <th className="border px-3 py-2">Aksi</th>
          </tr>
        </thead>
        <tbody>
          {dosenList.map((d) => (
            <tr key={d.id_dosen} className="hover:bg-gray-50">
              <td className="border px-3 py-2">{d.id_dosen}</td>
              <td className="border px-3 py-2">{d.nama_dosen}</td>
              <td className="border px-3 py-2">
                {d.nama_prodi || getProdiName(d.id_prodi)}
              </td>
              <td className="border px-3 py-2">{d.username}</td>
              <td className="border px-3 py-2 capitalize">{d.peran}</td>
              <td className="border px-3 py-2 flex gap-2 justify-center">
                <button
                  className="text-blue-600 hover:underline"
                  onClick={() => handleEdit(d)}
                >
                  Edit
                </button>
                <button
                  className="text-red-600 hover:underline"
                  onClick={() => handleDelete(d.id_dosen)}
                >
                  Hapus
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
