// verifyToken.js
const jwt = require("jsonwebtoken");
const JWT_SECRET = process.env.JWT_SECRET || "secretkey";

const verifyToken = (req, res, next) => {
  const authHeader = req.headers["authorization"];
  if (!authHeader) return res.status(401).json({ msg: "Token tidak ada" });

  const token = authHeader.split(" ")[1];
  if (!token) return res.status(401).json({ msg: "Token tidak valid" });

  try {
    const decoded = jwt.verify(token, JWT_SECRET);

    req.user = {
      id_users: decoded.id_users,
      email: decoded.email,
      level: decoded.level,
      nama: decoded.nama,
      nim: decoded.nim, // pastikan ini ADA
    };

    console.log("✅ Middleware: decoded token:", decoded);
    next();
  } catch (err) {
    return res.status(403).json({ msg: "Token tidak sah" });
  }
};

module.exports = verifyToken;
