const db = require("../config/db");

// Cari user berdasarkan email (fungsi yang dipakai di login)
exports.getByEmail = (email, callback) => {
  db.query("SELECT * FROM users WHERE email = ?", [email], callback);
};

// Ambil ID user terakhir
exports.getLastId = (callback) => {
  db.query(
    "SELECT id_users FROM users ORDER BY id_users DESC LIMIT 1",
    callback
  );
};

exports.getProfileById = (id_users, callback) => {
  db.query(
    "SELECT nim, nama, email, level FROM users WHERE id_users = ?",
    [id_users],
    callback
  );
};

// Ambil semua user
exports.getAll = (callback) => {
  db.query("SELECT * FROM users", callback);
};

// Ambil user berdasarkan id
exports.getById = (id, callback) => {
  db.query("SELECT * FROM users WHERE id_users = ?", [id], callback);
};

// Insert user baru
exports.create = (data, callback) => {
  db.query("INSERT INTO users SET ?", data, callback);
};

// Update user
exports.update = (id, data, callback) => {
  db.query("UPDATE users SET ? WHERE id_users = ?", [data, id], callback);
};

// Delete user
exports.remove = (id, callback) => {
  db.query("DELETE FROM users WHERE id_users = ?", [id], callback);
};
