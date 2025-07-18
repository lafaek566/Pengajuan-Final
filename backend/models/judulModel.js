const db = require("../config/db");

exports.getAllJudul = (callback) => {
  const sql = `
    SELECT 
      j.*,
      m.nama_mahasiswa,
      m.angkatan,
      p.nama_prodi
    FROM judul_ta j
    LEFT JOIN mahasiswa m ON j.nim = m.nim
    LEFT JOIN prodi p ON j.prodi_id = p.id_prodi
  `;
  db.query(sql, callback);
};

exports.getById = (id, callback) => {
  db.query("SELECT * FROM judul_ta WHERE id_judul = ?", [id], callback);
};

exports.getLastId = (callback) => {
  db.query(
    "SELECT id_judul FROM judul_ta ORDER BY id_judul DESC LIMIT 1",
    callback
  );
};

exports.create = (data, callback) => {
  const {
    id_judul,
    nama_topik,
    judul_ta,
    nim,
    prodi_id,
    dosen_pembimbing,
    dosen_penguji,
    dosen_penguji2,
    tahun,
  } = data;

  const sql = `
    INSERT INTO judul_ta 
    (id_judul, nama_topik, judul_ta, nim, prodi_id, dosen_pembimbing, dosen_penguji, dosen_penguji2, tahun)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
  `;

  db.query(
    sql,
    [
      id_judul,
      nama_topik,
      judul_ta,
      nim,
      prodi_id,
      dosen_pembimbing,
      dosen_penguji,
      dosen_penguji2,
      tahun,
    ],
    callback
  );
};

exports.update = (id, data, callback) => {
  // Pastikan data berupa objek yang valid, dan id sesuai dengan id_judul
  db.query("UPDATE judul_ta SET ? WHERE id_judul = ?", [data, id], callback);
};

exports.remove = (id, callback) => {
  db.query("DELETE FROM judul_ta WHERE id_judul = ?", [id], callback);
};
