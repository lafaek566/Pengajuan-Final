import { useEffect, useState } from "react";
import api from "../../utils/axiosInstance";

export default function AdminJudul() {
  const [data, setData] = useState([]);
  const [form, setForm] = useState({
    id_judul: "",
    judul_ta: "",
    nim: "",
    prodi_id: "",
    nama_topik: "",
    dosen_pembimbing: "",
    dosen_penguji: "",
    dosen_penguji2: "",
    tahun: new Date().getFullYear(),
  });
  const [editMode, setEditMode] = useState(false);
  const [prodiOptions, setProdiOptions] = useState([]);
  const [dosenOptions, setDosenOptions] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [filterProdi, setFilterProdi] = useState("");
  const rowsPerPage = 5;

  const fetchAll = async () => {
    const res = await api.get("/api/judul");
    setData(res.data);
  };

  const fetchDosen = async () => {
    const res = await api.get("/api/admin/dosen");
    setDosenOptions(res.data);
  };

  const fetchProdi = async () => {
    const res = await api.get("/api/prodi");
    setProdiOptions(res.data);
  };

  useEffect(() => {
    fetchAll();
    fetchDosen();
    fetchProdi();
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (editMode) {
      await api.put(`/api/judul/${form.id_judul}`, form);
    } else {
      await api.post("/api/judul", form);
    }
    resetForm();
    fetchAll();
  };

  const handleDelete = async (id) => {
    if (confirm("Yakin ingin menghapus judul ini?")) {
      await api.delete(`/api/judul/${id}`);
      fetchAll();
    }
  };

  const handleEdit = (item) => {
    setForm(item);
    setEditMode(true);
  };

  const resetForm = () => {
    setForm({
      id_judul: "",
      judul_ta: "",
      nim: "",
      prodi_id: "",
      nama_topik: "",
      dosen_pembimbing: "",
      dosen_penguji: "",
      dosen_penguji2: "",
      tahun: new Date().getFullYear(),
    });
    setEditMode(false);
  };

  const getDosenName = (id) =>
    dosenOptions.find((d) => d.id_dosen === id)?.nama_dosen || id;

  const getProdiName = (id) =>
    prodiOptions.find((p) => p.id_prodi === id)?.nama_prodi || id;

  const filteredData = Array.isArray(data)
    ? data.filter((d) => (filterProdi ? d.prodi_id === filterProdi : true))
    : [];

  const totalPages = Math.ceil(filteredData.length / rowsPerPage);
  const paginatedData = filteredData.slice(
    (currentPage - 1) * rowsPerPage,
    currentPage * rowsPerPage
  );

  return (
    <div className="p-6">
      <h2 className="text-xl font-bold mb-4 text-blue-700">
        {editMode ? "✏️ Edit Judul TA" : "➕ Tambah Judul TA"}
      </h2>

      <form onSubmit={handleSubmit} className="grid grid-cols-2 gap-4 mb-6">
        <input
          className="border p-2 rounded"
          placeholder="Judul TA"
          value={form.judul_ta}
          onChange={(e) => setForm({ ...form, judul_ta: e.target.value })}
          required
        />
        <input
          className="border p-2 rounded"
          placeholder="NIM"
          value={form.nim}
          onChange={(e) => setForm({ ...form, nim: e.target.value })}
        />
        <input
          className="border p-2 rounded"
          placeholder="Topik"
          value={form.nama_topik}
          onChange={(e) => setForm({ ...form, nama_topik: e.target.value })}
        />
        <select
          className="border p-2 rounded"
          value={form.prodi_id}
          onChange={(e) => setForm({ ...form, prodi_id: e.target.value })}
        >
          <option value="">Pilih Prodi</option>
          {prodiOptions.map((p) => (
            <option key={p.id_prodi} value={p.id_prodi}>
              {p.nama_prodi}
            </option>
          ))}
        </select>
        <select
          className="border p-2 rounded"
          value={form.dosen_pembimbing}
          onChange={(e) =>
            setForm({ ...form, dosen_pembimbing: e.target.value })
          }
        >
          <option value="">Pilih Pembimbing</option>
          {dosenOptions.map((d) => (
            <option key={d.id_dosen} value={d.id_dosen}>
              {d.nama_dosen}
            </option>
          ))}
        </select>
        <select
          className="border p-2 rounded"
          value={form.dosen_penguji}
          onChange={(e) => setForm({ ...form, dosen_penguji: e.target.value })}
        >
          <option value="">Pilih Penguji 1</option>
          {dosenOptions.map((d) => (
            <option key={d.id_dosen} value={d.id_dosen}>
              {d.nama_dosen}
            </option>
          ))}
        </select>
        <select
          className="border p-2 rounded"
          value={form.dosen_penguji2}
          onChange={(e) => setForm({ ...form, dosen_penguji2: e.target.value })}
        >
          <option value="">Pilih Penguji 2</option>
          {dosenOptions.map((d) => (
            <option key={d.id_dosen} value={d.id_dosen}>
              {d.nama_dosen}
            </option>
          ))}
        </select>
        <input
          className="border p-2 rounded"
          type="number"
          placeholder="Tahun"
          value={form.tahun}
          onChange={(e) => setForm({ ...form, tahun: e.target.value })}
        />

        <div className="col-span-2 flex gap-2">
          <button
            type="submit"
            className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded"
          >
            {editMode ? "Update" : "Simpan"}
          </button>
          {editMode && (
            <button
              type="button"
              className="bg-gray-500 hover:bg-gray-600 text-white px-4 py-2 rounded"
              onClick={resetForm}
            >
              Batal
            </button>
          )}
        </div>
      </form>

      <div className="mb-4">
        <label className="text-sm font-medium">Filter Prodi:</label>
        <select
          className="border p-2 rounded ml-2"
          value={filterProdi}
          onChange={(e) => {
            setFilterProdi(e.target.value);
            setCurrentPage(1);
          }}
        >
          <option value="">Semua</option>
          {prodiOptions.map((p) => (
            <option key={p.id_prodi} value={p.id_prodi}>
              {p.nama_prodi}
            </option>
          ))}
        </select>
      </div>

      <h3 className="text-lg font-semibold mb-2">Daftar Judul</h3>
      <table className="w-full text-sm border bg-white rounded shadow">
        <thead>
          <tr className="bg-blue-100 text-blue-800">
            <th className="border px-3 py-2">Judul</th>
            <th className="border px-3 py-2">NIM</th>
            <th className="border px-3 py-2">Nama</th>
            <th className="border px-3 py-2">Topik</th>
            <th className="border px-3 py-2">Prodi</th>
            <th className="border px-3 py-2">Pembimbing</th>
            <th className="border px-3 py-2">Penguji 1</th>
            <th className="border px-3 py-2">Penguji 2</th>
            <th className="border px-3 py-2">Tahun</th>
            <th className="border px-3 py-2">Aksi</th>
          </tr>
        </thead>
        <tbody>
          {paginatedData.map((d) => (
            <tr key={d.id_judul} className="hover:bg-gray-50">
              <td className="border px-3 py-2">{d.judul_ta}</td>
              <td className="border px-3 py-2">{d.nim}</td>
              <td className="border px-3 py-2">{d.nama_mahasiswa}</td>
              <td className="border px-3 py-2">{d.nama_topik}</td>
              <td className="border px-3 py-2">{getProdiName(d.prodi_id)}</td>
              <td className="border px-3 py-2">
                {getDosenName(d.dosen_pembimbing)}
              </td>
              <td className="border px-3 py-2">
                {getDosenName(d.dosen_penguji)}
              </td>
              <td className="border px-3 py-2">
                {getDosenName(d.dosen_penguji2)}
              </td>
              <td className="border px-3 py-2">{d.tahun}</td>
              <td className="border px-3 py-2 flex gap-2 justify-center">
                <button
                  onClick={() => handleEdit(d)}
                  className="text-blue-600 hover:underline"
                >
                  Edit
                </button>
                <button
                  onClick={() => handleDelete(d.id_judul)}
                  className="text-red-600 hover:underline"
                >
                  Hapus
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      <div className="mt-4 flex justify-between items-center">
        <div className="text-sm text-gray-600">
          Halaman {currentPage} dari {totalPages}
        </div>
        <div className="flex gap-2">
          <button
            onClick={() => setCurrentPage((prev) => Math.max(prev - 1, 1))}
            disabled={currentPage === 1}
            className="px-3 py-1 border rounded disabled:opacity-50"
          >
            ⬅️ Prev
          </button>
          <button
            onClick={() =>
              setCurrentPage((prev) => Math.min(prev + 1, totalPages))
            }
            disabled={currentPage === totalPages}
            className="px-3 py-1 border rounded disabled:opacity-50"
          >
            Next ➡️
          </button>
        </div>
      </div>
    </div>
  );
}
