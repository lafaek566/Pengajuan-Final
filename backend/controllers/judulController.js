const Judul = require("../models/judulModel");
const Proposal = require("../models/ProposalModel");
const db = require("../config/db");
const levenshtein = require("../utils/levenshtein");

// 🔍 Cek kemiripan judul
exports.checkSimilarity = (req, res) => {
  const input = req.query.q?.toLowerCase() || "";
  Judul.getAllJudul((err, results) => {
    if (err) return res.status(500).json(err);
    const similar = results
      .map((r) => ({
        judul: r.judul_ta,
        distance: levenshtein(input, r.judul_ta.toLowerCase()),
      }))
      .sort((a, b) => a.distance - b.distance);
    res.json(similar.slice(0, 5));
  });
};

// ✅ Ambil semua judul
exports.getAll = (req, res) => {
  Judul.getAllJudul((err, results) => {
    if (err) return res.status(500).json(err);
    res.json(results);
  });
};

// ✅ Ambil judul berdasarkan ID
exports.getById = (req, res) => {
  Judul.getById(req.params.id, (err, result) => {
    if (err) return res.status(500).json(err);
    if (result.length === 0) return res.status(404).json({ msg: "Not found" });
    res.json(result[0]);
  });
};

// ✅ Buat judul baru
exports.create = (req, res) => {
  const data = req.body;
  const { id_users: userId, level, nim: nimUser, nama: namaUser } = req.user;
  const nim = level === "mahasiswa" ? nimUser : data.nim || null;

  const {
    judul_ta,
    prodi_id,
    nama_topik,
    dosen_pembimbing,
    dosen_penguji,
    dosen_penguji2,
    tahun,
    angkatan,
  } = data;

  console.log("📥 Payload diterima:", data);
  console.log("👤 User Login:", { userId, nimUser, namaUser });

  // ✅ Validasi field wajib
  if (
    !judul_ta ||
    !prodi_id ||
    !nama_topik ||
    !dosen_pembimbing ||
    !dosen_penguji ||
    !dosen_penguji2 ||
    !tahun ||
    (level === "mahasiswa" && !nimUser) ||
    (level !== "mahasiswa" && !nim)
  ) {
    return res
      .status(400)
      .json({ msg: "❌ Gagal: Ada field kosong (cek NIM atau field lain)" });
  }

  // ✅ Validasi khusus admin harus isi angkatan
  if (level !== "mahasiswa" && !angkatan) {
    return res
      .status(400)
      .json({ msg: "❌ Admin harus mengisi angkatan jika input NIM baru" });
  }

  // 📌 Fungsi insert Judul
  const insertJudul = () => {
    Judul.getLastId((err, result) => {
      if (err)
        return res.status(500).json({ msg: "Gagal ambil ID terakhir", err });

      const lastId = result[0]?.id_judul || "J-00";
      const nextId = `J-${String(parseInt(lastId.split("-")[1]) + 1).padStart(
        2,
        "0"
      )}`;

      const newJudulData = {
        id_judul: nextId,
        judul_ta,
        nama_topik,
        nim,
        prodi_id,
        dosen_pembimbing,
        dosen_penguji,
        dosen_penguji2,
        tahun,
      };

      console.log("📌 Data akan dimasukkan ke tabel `judul`:", newJudulData);

      Judul.create(newJudulData, (err2) => {
        if (err2) {
          console.log("❌ Gagal simpan judul:", err2);
          return res.status(500).json({ msg: "Gagal simpan judul", err: err2 });
        }

        const proposalData = {
          nim,
          dosen: dosen_pembimbing,
          tahun,
          tgl_pengajuan: new Date(),
          id_judul: nextId,
        };

        Proposal.insertProposal(proposalData, (err3) => {
          if (err3) {
            console.log("⚠️ Proposal gagal:", err3);
            return res
              .status(500)
              .json({ msg: "Judul OK, proposal gagal", err: err3 });
          }

          res
            .status(201)
            .json({ msg: "✅ Judul & Proposal berhasil dibuat", id: nextId });
        });
      });
    });
  };

  // 🔍 Cek apakah mahasiswa sudah ada
  db.query("SELECT * FROM mahasiswa WHERE nim = ?", [nim], (err, rows) => {
    if (err) {
      console.error("❌ DB error saat cek mahasiswa:", err);
      return res.status(500).json({ msg: "Gagal cek mahasiswa", err });
    }

    if (rows.length === 0) {
      // 👤 Mahasiswa baru
      const idMahasiswa = `M-${Date.now()}`;
      db.query(
        "INSERT INTO mahasiswa (id_mahasiswa, nim, nama_mahasiswa, angkatan, id_users) VALUES (?, ?, ?, ?, ?)",
        [idMahasiswa, nim, namaUser, angkatan, userId || null],
        (err2) => {
          if (err2) {
            console.error("❌ Gagal insert mahasiswa:", err2);
            return res
              .status(500)
              .json({ msg: "Gagal insert mahasiswa", err: err2 });
          }

          if (userId) {
            db.query(
              "UPDATE users SET nim = ? WHERE id_users = ?",
              [nim, userId],
              (err3) => {
                if (err3) {
                  console.error("❌ Gagal update users:", err3);
                  return res
                    .status(500)
                    .json({ msg: "Gagal update users", err: err3 });
                }
                insertJudul();
              }
            );
          } else {
            insertJudul();
          }
        }
      );
    } else {
      // 🧾 Mahasiswa sudah ada
      if (userId) {
        db.query(
          "UPDATE mahasiswa SET id_users = ? WHERE nim = ? AND (id_users IS NULL OR id_users = '')",
          [userId, nim],
          (err3) => {
            if (err3) {
              console.error("❌ Gagal update mahasiswa:", err3);
              return res
                .status(500)
                .json({ msg: "Gagal update mahasiswa", err: err3 });
            }

            db.query(
              "UPDATE users SET nim = ? WHERE id_users = ?",
              [nim, userId],
              (err4) => {
                if (err4) {
                  console.error("❌ Gagal update users:", err4);
                  return res
                    .status(500)
                    .json({ msg: "Gagal update users", err: err4 });
                }
                insertJudul();
              }
            );
          }
        );
      } else {
        insertJudul();
      }
    }
  });
};

// ✅ Update judul
exports.update = (req, res) => {
  const allowedFields = [
    "nama_topik",
    "judul_ta",
    "nim",
    "prodi_id",
    "dosen_pembimbing",
    "dosen_penguji",
    "dosen_penguji2",
    "tahun",
  ];

  const dataToUpdate = {};
  allowedFields.forEach((key) => {
    if (req.body[key] !== undefined) {
      dataToUpdate[key] = req.body[key];
    }
  });

  Judul.update(req.params.id, dataToUpdate, (err) => {
    if (err) {
      console.error("❌ Update error:", err);
      return res.status(500).json({ error: err.message || err });
    }
    res.json({ msg: "Judul berhasil diupdate" });
  });
};

// ✅ Hapus judul
exports.remove = (req, res) => {
  Judul.remove(req.params.id, (err) => {
    if (err) {
      console.error("❌ Remove error:", err);
      return res.status(500).json({ error: err.message || err });
    }
    res.json({ msg: "Judul berhasil dihapus" });
  });
};

// ✅ Ambil judul berdasarkan NIM
exports.getByNIM = (req, res) => {
  const nim = req.params.nim;

  const sql = `
    SELECT 
      jt.*,
      p.nama_prodi,
      m.nama_mahasiswa,
      dp.nama_dosen AS nama_pembimbing,
      d1.nama_dosen AS nama_penguji,
      d2.nama_dosen AS nama_penguji2,
      COALESCE(t.nama_topik, jt.nama_topik) AS nama_topik,
      pr.status_persetujuan,
      pr.tgl_persetujuan,
      ju.tgl_ujian
    FROM judul_ta jt
    LEFT JOIN mahasiswa m ON jt.nim = m.nim
    LEFT JOIN prodi p ON jt.prodi_id = p.id_prodi
    LEFT JOIN dosen dp ON jt.dosen_pembimbing = dp.id_dosen
    LEFT JOIN dosen d1 ON jt.dosen_penguji = d1.id_dosen
    LEFT JOIN dosen d2 ON jt.dosen_penguji2 = d2.id_dosen
    LEFT JOIN topik_ta t ON jt.topik_id = t.id_topik
    LEFT JOIN proposal pr ON jt.id_judul = pr.id_judul
    LEFT JOIN jadwal_ujian ju ON pr.id = ju.id_proposal
    WHERE jt.nim = ?
    ORDER BY jt.tahun DESC LIMIT 1
  `;

  db.query(sql, [nim], (err, result) => {
    if (err) return res.status(500).json({ msg: "DB error", error: err });
    if (result.length === 0)
      return res.status(404).json({ msg: "Data tidak ditemukan" });
    res.json(result[0]);
  });
};

// ✅ Ambil semua judul + status lengkap
exports.getAllWithStatus = (req, res) => {
  const sql = `
    SELECT 
      jt.*,
      m.nama_mahasiswa,
      p.nama_prodi,
      dp.nama_dosen AS nama_pembimbing,
      du.nama_dosen AS nama_penguji,
      du2.nama_dosen AS nama_penguji2,
      COALESCE(jt.nama_topik, t.nama_topik) AS nama_topik,
      pr.status_persetujuan,
      ju.tgl_ujian
    FROM judul_ta jt
    LEFT JOIN mahasiswa m ON jt.nim = m.nim
    LEFT JOIN prodi p ON jt.prodi_id = p.id_prodi
    LEFT JOIN dosen dp ON jt.dosen_pembimbing = dp.id_dosen
    LEFT JOIN dosen du ON jt.dosen_penguji = du.id_dosen
    LEFT JOIN dosen du2 ON jt.dosen_penguji2 = du2.id_dosen
    LEFT JOIN topik_ta t ON jt.topik_id = t.id_topik
    LEFT JOIN proposal pr ON jt.id_judul = pr.id_judul
    LEFT JOIN jadwal_ujian ju ON ju.id_proposal = pr.id
  `;

  db.query(sql, (err, result) => {
    if (err) return res.status(500).json({ message: "DB error", error: err });
    res.json(result);
  });
};
