import { useState, useEffect } from "react";
import api from "../../utils/axiosInstance";

export default function FormAjukanJudul() {
  const [nim, setNim] = useState("");
  const [nama, setNama] = useState(""); // Nama user login
  const [angkatan, setAngkatan] = useState("");
  const [judul, setJudul] = useState("");
  const [topik, setTopik] = useState("");
  const [prodiId, setProdiId] = useState("");
  const [pembimbing, setPembimbing] = useState("");
  const [penguji1, setPenguji1] = useState("");
  const [penguji2, setPenguji2] = useState("");
  const [tahun] = useState(new Date().getFullYear());

  const [dosenList, setDosenList] = useState([]);
  const [similarJudul, setSimilarJudul] = useState([]);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    getProfile();
    getDosen();
  }, []);

  const getProfile = async () => {
    try {
      const res = await api.get("/api/users/profile");
      setNim(res.data.nim || "");
      setNama(res.data.nama || "");
      setNamaMahasiswa(res.data.nama || ""); // ← tambahkan ini
    } catch (err) {
      console.error("❌ Gagal ambil data user:", err);
    }
  };

  const getDosen = async () => {
    try {
      const res = await api.get("/api/admin/dosen");
      setDosenList(res.data);
    } catch (err) {
      console.error("❌ Gagal mengambil data dosen:", err);
    }
  };

  const checkSimilarity = async (judulInput) => {
    try {
      const res = await api.get(
        `/api/judul/check?q=${encodeURIComponent(judulInput)}`
      );
      setSimilarJudul(res.data);
    } catch (err) {
      console.error("❌ Gagal mengecek kemiripan judul:", err);
    }
  };

  const handleJudulChange = (e) => {
    const val = e.target.value;
    setJudul(val);
    if (val.length > 5) {
      checkSimilarity(val);
    } else {
      setSimilarJudul([]);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (
      !angkatan ||
      !judul ||
      !topik ||
      !prodiId ||
      !pembimbing ||
      !penguji1 ||
      !penguji2
    ) {
      return alert("❌ Semua field wajib diisi!");
    }

    if (
      pembimbing === penguji1 ||
      pembimbing === penguji2 ||
      penguji1 === penguji2
    ) {
      return alert("❌ Dosen pembimbing dan penguji tidak boleh sama.");
    }

    if (
      similarJudul.length > 0 &&
      !window.confirm(
        "⚠️ Judul mirip dengan yang sudah ada. Yakin ingin melanjutkan?"
      )
    ) {
      return;
    }

    const payload = {
      angkatan,
      judul_ta: judul,
      nama_topik: topik,
      prodi_id: prodiId,
      dosen_pembimbing: pembimbing,
      dosen_penguji1: penguji1,
      dosen_penguji2: penguji2,
      tahun,
    };

    console.log("📦 Payload yang dikirim:", payload);

    setSubmitting(true);
    try {
      await api.post("/api/judul", payload);
      alert("✅ Berhasil mengajukan judul");

      setAngkatan("");
      setJudul("");
      setTopik("");
      setProdiId("");
      setPembimbing("");
      setPenguji1("");
      setPenguji2("");
      setSimilarJudul([]);
    } catch (err) {
      console.error("❌ Gagal mengajukan judul:", err);
      alert("❌ Gagal mengajukan judul");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="p-6 max-w-xl mx-auto">
      <h2 className="text-xl font-bold mb-4">Form Pengajuan Judul TA</h2>
      <form onSubmit={handleSubmit} className="space-y-4">
        <input
          type="text"
          placeholder="NIM (user login)"
          value={nim}
          readOnly
          className="border px-3 py-2 rounded w-full bg-gray-100"
        />

        <input
          type="text"
          placeholder="Nama Pengguna Login"
          value={nama}
          readOnly
          className="border px-3 py-2 rounded w-full bg-gray-100"
        />

        <input
          type="text"
          placeholder="Angkatan"
          value={angkatan}
          onChange={(e) => setAngkatan(e.target.value)}
          className="border px-3 py-2 rounded w-full"
        />

        <select
          value={prodiId}
          onChange={(e) => setProdiId(e.target.value)}
          className="border px-3 py-2 rounded w-full"
        >
          <option value="">Pilih Prodi</option>
          <option value="P-01">Sistem Informasi</option>
          <option value="P-02">Teknik Informatika</option>
        </select>

        <input
          type="text"
          placeholder="Judul Tugas Akhir"
          value={judul}
          onChange={handleJudulChange}
          className="border px-3 py-2 rounded w-full"
        />
        <p className="text-xs">(Harus minimal 10 karakter)</p>

        {similarJudul.length > 0 && (
          <div className="bg-yellow-100 border border-yellow-400 p-3 rounded text-sm">
            <p className="font-semibold mb-1">⚠️ Judul Mirip:</p>
            <ul className="list-disc pl-5">
              {similarJudul.map((item, i) => (
                <li
                  key={i}
                  className={
                    item.distance < 0.3 ? "text-red-600 font-semibold" : ""
                  }
                >
                  {item.judul} (jarak: {item.distance.toFixed(2)})
                </li>
              ))}
            </ul>
          </div>
        )}

        <input
          type="text"
          placeholder="Metode / Topik"
          value={topik}
          onChange={(e) => setTopik(e.target.value)}
          className="border px-3 py-2 rounded w-full"
        />

        <select
          value={pembimbing}
          onChange={(e) => setPembimbing(e.target.value)}
          className="border px-3 py-2 rounded w-full"
        >
          <option value="">Pilih Dosen Pembimbing</option>
          {dosenList.map((d) => (
            <option key={d.id_dosen} value={d.id_dosen}>
              {d.nama_dosen}
            </option>
          ))}
        </select>

        <select
          value={penguji1}
          onChange={(e) => setPenguji1(e.target.value)}
          className="border px-3 py-2 rounded w-full"
        >
          <option value="">Pilih Dosen Penguji 1</option>
          {dosenList.map((d) => (
            <option key={d.id_dosen} value={d.id_dosen}>
              {d.nama_dosen}
            </option>
          ))}
        </select>

        <select
          value={penguji2}
          onChange={(e) => setPenguji2(e.target.value)}
          className="border px-3 py-2 rounded w-full"
        >
          <option value="">Pilih Dosen Penguji 2</option>
          {dosenList.map((d) => (
            <option key={d.id_dosen} value={d.id_dosen}>
              {d.nama_dosen}
            </option>
          ))}
        </select>

        <input
          type="text"
          value={tahun}
          readOnly
          className="border px-3 py-2 rounded w-full bg-gray-100"
        />

        <button
          type="submit"
          className="bg-blue-600 text-white px-4 py-2 rounded w-full disabled:opacity-50"
          disabled={submitting}
        >
          {submitting ? "Mengirim..." : "Ajukan"}
        </button>
      </form>
    </div>
  );
}
