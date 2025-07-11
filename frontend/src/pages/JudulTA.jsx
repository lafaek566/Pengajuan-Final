import { useEffect, useState } from "react";
import axios from "axios";

export default function JudulTA() {
  const [judulList, setJudulList] = useState([]);
  const [search, setSearch] = useState("");
  const [similar, setSimilar] = useState([]);

  useEffect(() => {
    getJudul();
  }, []);

  const getJudul = async () => {
    const res = await axios.get("http://localhost:5009/api/judul");
    setJudulList(res.data);
  };

  const checkSimilarity = async () => {
    const res = await axios.get(
      `http://localhost:5009/api/judul/check?q=${search}`
    );
    setSimilar(res.data);
  };

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Data Judul Tugas Akhir</h1>

      <div className="mb-4">
        <input
          type="text"
          placeholder="Cek kemiripan judul..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="border px-3 py-2 rounded w-1/2"
        />
        <button
          onClick={checkSimilarity}
          className="ml-2 px-4 py-2 bg-green-600 text-white rounded"
        >
          Cek
        </button>
      </div>

      {similar.length > 0 && (
        <div className="mb-4">
          <h2 className="font-medium">Hasil Kemiripan:</h2>
          <ul className="list-disc pl-6">
            {similar.map((item, i) => (
              <li key={i}>
                {item.judul} (jarak: {item.distance})
              </li>
            ))}
          </ul>
        </div>
      )}

      <table className="w-full border text-left text-sm">
        <thead>
          <tr className="bg-gray-100">
            <th className="border px-2 py-2">ID</th>
            <th className="border px-2 py-2">Topik</th>
            <th className="border px-2 py-2">Judul TA</th>
            <th className="border px-2 py-2">NIM</th>
            <th className="border px-2 py-2">Prodi</th>
            <th className="border px-2 py-2">Pembimbing</th>
            <th className="border px-2 py-2">Penguji</th>
            <th className="border px-2 py-2">Tahun</th>
          </tr>
        </thead>
        <tbody>
          {judulList.map((item) => (
            <tr key={item.id_judul}>
              <td className="border px-2 py-1">{item.id_judul}</td>
              <td className="border px-2 py-1">{item.topik_id}</td>
              <td className="border px-2 py-1">{item.judul_ta}</td>
              <td className="border px-2 py-1">{item.nim}</td>
              <td className="border px-2 py-1">{item.prodi_id}</td>
              <td className="border px-2 py-1">{item.dosen_pembimbing}</td>
              <td className="border px-2 py-1">{item.dosen_penguji}</td>
              <td className="border px-2 py-1">{item.tahun}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
