const Dosen = require("../models/DosenModel");

exports.getAll = (req, res) => {
  Dosen.getAll((err, results) => {
    if (err) return res.status(500).json(err);
    res.json(results);
  });
};

exports.create = (req, res) => {
  const { id_dosen, nama_dosen, id_prodi, peran, username, password } =
    req.body;

  if (
    !id_dosen ||
    !nama_dosen ||
    !id_prodi ||
    !peran ||
    !username ||
    !password
  ) {
    return res.status(400).json({ msg: "Semua field wajib diisi" });
  }

  Dosen.create(
    { id_dosen, nama_dosen, id_prodi, peran, username, password },
    (err) => {
      if (err) return res.status(500).json(err);
      res.status(201).json({ msg: "Dosen berhasil ditambahkan" });
    }
  );
};

exports.getByPeran = (req, res) => {
  const peran = req.params.peran;
  Dosen.getByPeran(peran, (err, results) => {
    if (err) return res.status(500).json(err);
    res.json(results);
  });
};

exports.update = (req, res) => {
  const id = req.params.id;
  const { nama_dosen, id_prodi, username, password, peran } = req.body;

  if (!nama_dosen || !id_prodi || !username || !peran) {
    return res.status(400).json({ msg: "Field wajib tidak boleh kosong" });
  }

  const data = { nama_dosen, id_prodi, username, peran };
  if (password && password.trim()) {
    data.password = password;
  }

  Dosen.update(id, data, (err) => {
    if (err) {
      console.error("❌ Update error:", err);
      return res.status(500).json(err);
    }
    res.json({ msg: "Dosen berhasil diupdate" });
  });
};

exports.remove = (req, res) => {
  const id = req.params.id;

  Dosen.remove(id, (err) => {
    if (err) return res.status(500).json(err);
    res.json({ msg: "Dosen berhasil dihapus" });
  });
};
