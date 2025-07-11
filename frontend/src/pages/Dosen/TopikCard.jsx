import React from "react";

export default function TopikCard({ idTopik, namaTopik }) {
  return (
    <div className="max-w-sm bg-white border-l-4 border-indigo-500 shadow-md rounded-lg p-6 mx-auto">
      <div className="mb-3">
        <h2 className="text-xl font-bold text-indigo-700 flex items-center gap-2">
          🧠 {namaTopik}
        </h2>
        <p className="text-sm text-gray-500">
          <strong>ID Topik:</strong> {idTopik}
        </p>
      </div>
      <p className="text-gray-700 text-sm leading-relaxed">
        Topik ini merupakan bagian dari kategori Tugas Akhir mahasiswa.
        Mahasiswa yang mengajukan judul biasanya memilih salah satu topik untuk
        fokus penelitian mereka.
      </p>
    </div>
  );
}
