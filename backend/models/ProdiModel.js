const db = require("../config/db");

exports.getAll = (cb) => {
  db.query("SELECT * FROM prodi", cb);
};

exports.create = (data, cb) => {
  db.query("INSERT INTO prodi SET ?", data, cb);
};

exports.update = (id, data, cb) => {
  db.query("UPDATE prodi SET ? WHERE id_prodi = ?", [data, id], cb);
};

exports.remove = (id, cb) => {
  db.query("DELETE FROM prodi WHERE id_prodi = ?", [id], cb);
};
