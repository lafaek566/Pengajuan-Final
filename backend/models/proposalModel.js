// models/proposal.js
const db = require("../config/db");

// INSERT proposal
const insertProposal = (data, callback) => {
  const sql = `
    INSERT INTO proposal 
    (nim, dosen, tahun, tgl_pengajuan, id_judul)
    VALUES (?, ?, ?, ?, ?)
  `;
  const values = [
    data.nim,
    data.dosen,
    data.tahun,
    data.tgl_pengajuan,
    data.id_judul,
  ];
  db.query(sql, values, callback);
};

// GET semua proposal (digunakan oleh admin atau dosen)
const getAllProposals = (callback) => {
  const sql = `
    SELECT 
      pr.*,
      jt.judul_ta,
      jt.nim,
      jt.tahun,
      COALESCE(jt.nama_topik, t.nama_topik) AS nama_topik,
      m.nama_mahasiswa,
      ju.tgl_ujian
    FROM proposal pr
    LEFT JOIN judul_ta jt ON pr.id_judul = jt.id_judul
    LEFT JOIN topik_ta t ON jt.topik_id = t.id_topik
    LEFT JOIN mahasiswa m ON jt.nim = m.nim
    LEFT JOIN jadwal_ujian ju ON pr.id = ju.id_proposal
  `;
  db.query(sql, callback);
};

// GET proposal by ID
const getById = (id, callback) => {
  db.query("SELECT * FROM proposal WHERE id = ?", [id], callback);
};

// UPDATE proposal
const update = (id, data, callback) => {
  db.query("UPDATE proposal SET ? WHERE id = ?", [data, id], callback);
};

// DELETE proposal dan jadwal ujian terkait
const remove = (id, callback) => {
  const deleteJadwal = "DELETE FROM jadwal_ujian WHERE id_proposal = ?";
  const deleteProposal = "DELETE FROM proposal WHERE id = ?";

  db.query(deleteJadwal, [id], (err) => {
    if (err) return callback(err);
    db.query(deleteProposal, [id], callback);
  });
};

// GET semua proposal berdasarkan NIM
const getAllByNim = (nim, cb) => {
  const sql = `
    SELECT 
      p.*, 
      jt.judul_ta, 
      jt.tahun, 
      jt.nama_topik,
      m.nama_mahasiswa,
      pr.nama_prodi AS prodi,
      pembimbing.nama_dosen AS nama_pembimbing,
      penguji1.nama_dosen AS nama_penguji1,
      penguji2.nama_dosen AS nama_penguji2,
      ju.tgl_ujian
    FROM proposal p
    LEFT JOIN judul_ta jt ON p.id_judul = jt.id_judul
    LEFT JOIN mahasiswa m ON jt.nim = m.nim
    LEFT JOIN prodi pr ON jt.prodi_id = pr.id_prodi
    LEFT JOIN dosen pembimbing ON jt.dosen_pembimbing = pembimbing.id_dosen
    LEFT JOIN dosen penguji1 ON jt.dosen_penguji = penguji1.id_dosen
    LEFT JOIN dosen penguji2 ON jt.dosen_penguji2 = penguji2.id_dosen
    LEFT JOIN jadwal_ujian ju ON p.id = ju.id_proposal
    WHERE jt.nim = ?
  `;
  db.query(sql, [nim], cb);
};

// EXPORT semua fungsi
module.exports = {
  insertProposal,
  getAllProposals,
  getById,
  update,
  remove,
  getAllByNim,
};
