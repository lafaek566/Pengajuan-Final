const db = require("../config/db");

exports.getDashboardStats = (req, res) => {
  const sqlStats = `
    SELECT
      (SELECT COUNT(*) FROM dosen) AS dosen,
      (SELECT COUNT(*) FROM mahasiswa) AS mahasiswa,
      (SELECT COUNT(*) FROM judul_ta) AS judul,
      (SELECT COUNT(*) FROM topik_ta) AS topik,
      (SELECT COUNT(*) FROM proposal WHERE status_persetujuan = 'Y') AS proposal_disetujui,
      (SELECT COUNT(*) FROM proposal WHERE status_persetujuan = 'T') AS proposal_ditolak,
      (SELECT COUNT(*) FROM proposal WHERE status_persetujuan IS NULL) AS proposal_pending
  `;

  const sqlTopik = `
    SELECT DISTINCT nama_topik 
    FROM judul_ta 
    WHERE nama_topik IS NOT NULL AND nama_topik != ''
  `;

  db.query(sqlStats, (err, statsResult) => {
    if (err)
      return res
        .status(500)
        .json({ msg: "Gagal mengambil statistik", error: err });

    db.query(sqlTopik, (err2, topikResult) => {
      if (err2)
        return res
          .status(500)
          .json({ msg: "Gagal mengambil topik", error: err2 });

      res.json({
        ...statsResult[0],
        daftar_topik: topikResult.map((row) => row.nama_topik),
      });
    });
  });
};
