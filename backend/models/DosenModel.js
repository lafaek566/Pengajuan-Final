const db = require("../config/db");

// Ambil semua dosen + nama prodi
exports.getAll = (result) => {
  const query = `
    SELECT d.*, p.nama_prodi 
    FROM dosen d
    LEFT JOIN prodi p ON d.id_prodi = p.id_prodi
  `;
  db.query(query, (err, res) => {
    if (err) return result(err);
    result(null, res);
  });
};

exports.create = (data, result) => {
  db.query("INSERT INTO dosen SET ?", data, (err, res) => {
    if (err) return result(err);
    result(null, res);
  });
};

exports.getByPeran = (peran, result) => {
  db.query("SELECT * FROM dosen WHERE peran = ?", [peran], (err, res) => {
    if (err) return result(err);
    result(null, res);
  });
};

exports.update = (id, data, result) => {
  db.query("UPDATE dosen SET ? WHERE id_dosen = ?", [data, id], (err, res) => {
    if (err) return result(err);
    result(null, res);
  });
};

// Hapus dosen
exports.remove = (id, result) => {
  db.query("DELETE FROM dosen WHERE id_dosen = ?", [id], (err, res) => {
    if (err) return result(err);
    result(null, res);
  });
};
