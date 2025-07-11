const Topik = require("../models/TopikModel");

exports.getAll = (req, res) => {
  Topik.getAll((err, results) => {
    if (err) return res.status(500).json(err);
    res.json(results);
  });
};

exports.create = (req, res) => {
  const data = req.body;
  Topik.create(data, (err) => {
    if (err) return res.status(500).json(err);
    res.status(201).json({ msg: "Topik created" });
  });
};

exports.update = (req, res) => {
  const id = req.params.id;
  const data = req.body;
  Topik.update(id, data, (err) => {
    if (err) return res.status(500).json(err);
    res.json({ msg: "Topik updated" });
  });
};

exports.remove = (req, res) => {
  const id = req.params.id;
  Topik.remove(id, (err) => {
    if (err) return res.status(500).json(err);
    res.json({ msg: "Topik deleted" });
  });
};
