const User = require("../models/userModel");
const bcrypt = require("bcryptjs");
const db = require("../config/db");

// Fungsi generate id_users otomatis
const generateUserId = (callback) => {
  User.getLastId((err, results) => {
    if (err) return callback(err);
    let lastId = results[0]?.id_users || "U-00";
    let num = parseInt(lastId.split("-")[1]) + 1;
    let newId = `U-${String(num).padStart(2, "0")}`;
    callback(null, newId);
  });
};

// Fungsi buat user mahasiswa baru lengkap dengan insert ke mahasiswa dan update nim di users
function createUserMahasiswa(data, callback) {
  generateUserId((err, newId) => {
    if (err) return callback(err);

    data.id_users = newId;
    data.password = bcrypt.hashSync(data.password, 10);

    // Insert user ke tabel users
    db.query("INSERT INTO users SET ?", data, (err, result) => {
      if (err) return callback(err);

      // Insert ke tabel mahasiswa
      const mahasiswaData = {
        id_mahasiswa: `M-${Date.now()}`,
        nim: data.nim,
        nama_mahasiswa: data.nama,
        angkatan: data.angkatan || null,
        id_users: newId,
      };

      db.query("INSERT INTO mahasiswa SET ?", mahasiswaData, (err2) => {
        if (err2) return callback(err2);

        // Update nim di users agar sinkron
        db.query(
          "UPDATE users SET nim = ? WHERE id_users = ?",
          [data.nim, newId],
          (err3) => {
            if (err3) return callback(err3);
            callback(null, { id_users: newId, nim: data.nim });
          }
        );
      });
    });
  });
}

exports.getAllUsers = (req, res) => {
  User.getAll((err, results) => {
    if (err) return res.status(500).json(err);
    res.json(results);
  });
};

exports.getProfile = (req, res) => {
  const userId = req.user.id_users;

  User.getProfileById(userId, (err, results) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ msg: "Server error" });
    }

    if (results.length === 0) {
      return res.status(404).json({ msg: "User tidak ditemukan" });
    }

    res.json(results[0]);
  });
};

exports.getUserById = (req, res) => {
  User.getById(req.params.id, (err, result) => {
    if (err) return res.status(500).json(err);
    if (result.length === 0) return res.status(404).json({ msg: "Not found" });
    res.json(result[0]);
  });
};

exports.createUser = (req, res) => {
  const data = req.body;
  console.log("Create user data:", data);

  if (!["admin", "mahasiswa", "dosen"].includes(data.level)) {
    return res.status(400).json({ msg: "Invalid role level" });
  }

  if (data.level === "mahasiswa") {
    if (!data.nim || !data.nama) {
      return res
        .status(400)
        .json({ msg: "NIM dan nama wajib untuk mahasiswa" });
    }
    createUserMahasiswa(data, (err, result) => {
      if (err)
        return res.status(500).json({ msg: "Gagal buat user mahasiswa", err });
      res
        .status(201)
        .json({ msg: "User mahasiswa berhasil dibuat", ...result });
    });
  } else {
    // untuk level admin/dosen tanpa mahasiswa
    generateUserId((err, newId) => {
      if (err) {
        return res
          .status(500)
          .json({ msg: "Failed to generate user ID", error: err });
      }

      data.id_users = newId;
      data.password = bcrypt.hashSync(data.password, 10);

      User.create(data, (err, result) => {
        if (err) return res.status(500).json(err);
        res.status(201).json({ msg: "User created", id: data.id_users });
      });
    });
  }
};

exports.updateUser = (req, res) => {
  const id = req.params.id;
  const data = req.body;
  if (data.password) {
    data.password = bcrypt.hashSync(data.password, 10);
  }
  User.update(id, data, (err) => {
    if (err) return res.status(500).json(err);
    res.json({ msg: "User updated" });
  });
};

exports.deleteUser = (req, res) => {
  User.remove(req.params.id, (err) => {
    if (err) return res.status(500).json(err);
    res.json({ msg: "User deleted" });
  });
};
