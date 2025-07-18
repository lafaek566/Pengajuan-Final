const db = require("../config/db");

exports.getAllMahasiswa = (callback) => {
  const sql = `
    SELECT 
      m.id_mahasiswa, 
      m.nim, 
      m.nama_mahasiswa, 
      m.angkatan, 
      m.prodi_id,
      COALESCE(p.nama_prodi, 'Belum Diatur') AS nama_prodi
    FROM mahasiswa m
    LEFT JOIN prodi p ON m.prodi_id = p.id_prodi
  `;

  db.query(sql, (err, results) => {
    if (err) {
      console.error("Error executing query:", err);
      return callback(err, null);
    }
    callback(null, results);
  });
};
