const db = require("../config/db");

exports.getAll = (cb) => {
  db.query("SELECT * FROM topik_ta", cb);
};

exports.create = (data, cb) => {
  db.query("INSERT INTO topik_ta SET ?", data, cb);
};

exports.update = (id, data, cb) => {
  db.query("UPDATE topik_ta SET ? WHERE id_topik = ?", [data, id], cb);
};

exports.remove = (id, cb) => {
  db.query("DELETE FROM topik_ta WHERE id_topik = ?", [id], cb);
};
