const db = require("../config/db");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

const JWT_SECRET = process.env.JWT_SECRET || "secretkey";

exports.login = (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ msg: "Email dan password wajib diisi" });
  }

  const sql = `
  SELECT u.id_users, u.email, u.password, u.level, u.nama, m.nim
  FROM users u
  LEFT JOIN mahasiswa m ON u.id_users = m.id_users
  WHERE u.email = ?
`;

  db.query(sql, [email], (err, results) => {
    if (err) return res.status(500).json(err);
    if (results.length === 0)
      return res.status(401).json({ msg: "Email atau password salah" });

    const user = results[0];
    const valid = bcrypt.compareSync(password, user.password);
    if (!valid)
      return res.status(401).json({ msg: "Email atau password salah" });

    // ✅ Gunakan nim_mahasiswa dari hasil query alias
    const payload = {
      id_users: user.id_users,
      email: user.email,
      level: user.level,
      nama: user.nama,
      nim: user.nim, // ← JANGAN pakai `nim_mahasiswa` kalau alias-nya sudah dihapus
    };

    const token = jwt.sign(payload, JWT_SECRET, { expiresIn: "12h" });

    res.json({ msg: "Login berhasil", token, user: payload });
  });
};

// controllers/userController.js
exports.getProfile = (req, res) => {
  const id_users = req.user.id_users;
  const sql = `
    SELECT u.id_users, u.email, u.level, u.nama, m.nim
    FROM users u
    LEFT JOIN mahasiswa m ON u.id_users = m.id_users
    WHERE u.id_users = ?
  `;
  db.query(sql, [id_users], (err, results) => {
    if (err) return res.status(500).json(err);
    if (results.length === 0)
      return res.status(404).json({ msg: "User not found" });

    res.json(results[0]);
  });
};
