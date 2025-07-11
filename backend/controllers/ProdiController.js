const Prodi = require("../models/ProdiModel");

exports.getAll = (req, res) => {
  Prodi.getAll((err, results) => {
    if (err) return res.status(500).json(err);
    res.json(results);
  });
};

exports.create = (req, res) => {
  const data = req.body;
  Prodi.create(data, (err) => {
    if (err) return res.status(500).json(err);
    res.status(201).json({ msg: "Prodi created" });
  });
};

exports.update = (req, res) => {
  const id = req.params.id;
  const data = req.body;
  Prodi.update(id, data, (err) => {
    if (err) return res.status(500).json(err);
    res.json({ msg: "Prodi updated" });
  });
};

exports.remove = (req, res) => {
  const id = req.params.id;
  Prodi.remove(id, (err) => {
    if (err) return res.status(500).json(err);
    res.json({ msg: "Prodi deleted" });
  });
};
