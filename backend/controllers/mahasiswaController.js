const mahasiswaModel = require("../models/mahasiswaModel");

exports.getAllMahasiswa = (req, res) => {
  mahasiswaModel.getAllMahasiswa((err, result) => {
    if (err) {
      return res
        .status(500)
        .json({ msg: "Gagal mengambil data mahasiswa", error: err });
    }
    res.json(result);
  });
};
