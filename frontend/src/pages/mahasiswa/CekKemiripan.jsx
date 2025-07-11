import React, { useState } from "react";
import api from "../../utils/axiosInstance";
import { Search } from "lucide-react";

export default function CekKemiripan() {
  const [query, setQuery] = useState("");
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const handleCheck = async () => {
    if (!query.trim()) return;

    setLoading(true);
    setError(null);

    try {
      const res = await api.get(
        `/api/judul/check?q=${encodeURIComponent(query)}`
      );
      setResults(res.data);
    } catch (err) {
      setError("❌ Gagal mengambil data kemiripan");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-2xl mx-auto mt-12 p-6 bg-gradient-to-br from-white via-slate-50 to-blue-50 rounded-xl shadow-lg border border-gray-200">
      <h1 className="text-3xl font-bold mb-6 text-center text-blue-700">
        🔍 Cek Kemiripan Judul Tugas Akhir
      </h1>

      <div className="flex items-center gap-3 mb-6">
        <input
          type="text"
          placeholder="Contoh: Sistem Informasi Akademik"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          className="flex-grow border border-gray-300 rounded-lg px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 shadow-sm"
        />
        <button
          onClick={handleCheck}
          className="flex items-center gap-1 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50 transition"
          disabled={loading}
        >
          {loading ? (
            <svg
              className="animate-spin h-5 w-5 text-white"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
            >
              <circle
                className="opacity-25"
                cx="12"
                cy="12"
                r="10"
                stroke="currentColor"
                strokeWidth="4"
              />
              <path
                className="opacity-75"
                fill="currentColor"
                d="M4 12a8 8 0 018-8v8H4z"
              />
            </svg>
          ) : (
            <>
              <Search size={18} /> Cek
            </>
          )}
        </button>
      </div>

      {error && (
        <div className="text-red-600 mb-4 text-center font-medium">{error}</div>
      )}

      {results.length > 0 && (
        <div className="transition-all duration-300">
          <h2 className="text-xl font-semibold mb-4 text-gray-700">
            ✨ Hasil Kemiripan
          </h2>
          <div className="grid gap-4">
            {results.map(({ judul, distance }, idx) => (
              <div
                key={idx}
                className="p-4 bg-white border border-gray-200 rounded-lg shadow-sm hover:shadow-md transition"
              >
                <p className="text-blue-800 font-semibold">{judul}</p>
                <p className="text-gray-500 text-sm">
                  Jarak kemiripan: {distance}
                </p>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
