const Proposal = require("../models/ProposalModel");
const db = require("../config/db");

// ✅ Submit proposal baru
exports.submit = (req, res) => {
  const nim = req.user.nim;
  const nama_mahasiswa = req.user.nama;

  if (
    !nim ||
    !req.body.angkatan ||
    !req.body.judul_ta ||
    !req.body.nama_topik ||
    !req.body.prodi_id ||
    !req.body.dosen_pembimbing ||
    !req.body.dosen_penguji1 ||
    !req.body.dosen_penguji2 ||
    !req.body.tahun
  ) {
    return res.status(400).json({ msg: "Ada field kosong" });
  }

  const data = {
    ...req.body,
    nim,
    nama_mahasiswa,
  };

  console.log("📥 Payload FINAL:", data);

  Proposal.insertProposal(data, (err, result) => {
    if (err) return res.status(500).json(err);
    res.json({ msg: "Proposal submitted", id: result.insertId });
  });
};

// ✅ Ambil semua proposal
exports.getAll = (req, res) => {
  Proposal.getAllProposals((err, results) => {
    if (err) return res.status(500).json(err);
    res.json(results);
  });
};

// ✅ Ambil 1 proposal
exports.getById = (req, res) => {
  Proposal.getById(req.params.id, (err, result) => {
    if (err) return res.status(500).json(err);
    if (result.length === 0) return res.status(404).json({ msg: "Not found" });
    res.json(result[0]);
  });
};

// ✅ Update proposal biasa
exports.update = (req, res) => {
  Proposal.update(req.params.id, req.body, (err) => {
    if (err) return res.status(500).json(err);
    res.json({ msg: "Proposal updated" });
  });
};

exports.remove = (req, res) => {
  Proposal.remove(req.params.id, (err) => {
    if (err) {
      console.error("❌ Gagal hapus proposal:", err); // tampilkan error SQL-nya
      return res.status(500).json({ error: err.message });
    }
    res.json({ msg: "Proposal deleted" });
  });
};

// ✅ Update status & simpan tgl ujian
exports.updateStatus = (req, res) => {
  console.log("🔥 UPDATE STATUS:", req.body);
  const id = req.params.id;
  const { status_persetujuan, tgl_persetujuan, tgl_ujian } = req.body;

  if (!["Y", "T"].includes(status_persetujuan)) {
    return res
      .status(400)
      .json({ msg: "Status harus Y (setuju) atau T (tolak)" });
  }

  // Simpan status persetujuan & tanggal persetujuan
  Proposal.update(id, { status_persetujuan, tgl_persetujuan }, (err) => {
    if (err) return res.status(500).json(err);

    // Kalau ditolak atau belum ada tgl ujian, cukup update status saja
    if (status_persetujuan !== "Y" || !tgl_ujian) {
      return res.json({ msg: "Status proposal diperbarui" });
    }

    // ✅ Ambil data proposal terkait
    const sql = `
      SELECT p.id, p.nim, p.dosen, p.id_judul
      FROM proposal p
      WHERE p.id = ?
    `;

    db.query(sql, [id], (err2, results) => {
      if (err2) {
        return res
          .status(500)
          .json({ msg: "Gagal ambil data proposal", err: err2 });
      }

      if (results.length === 0) {
        return res.status(404).json({ msg: "Proposal tidak ditemukan" });
      }

      const proposal = results[0];
      const jenisUjian = "proposal";

      // ✅ Cek apakah sudah ada jadwal untuk proposal ini
      const checkJadwal = `
        SELECT * FROM jadwal_ujian WHERE id_proposal = ?
      `;

      db.query(checkJadwal, [proposal.id], (errCheck, existing) => {
        if (errCheck) {
          return res
            .status(500)
            .json({ msg: "Gagal cek jadwal ujian", err: errCheck });
        }

        if (existing.length > 0) {
          // ✅ Sudah ada, lakukan UPDATE
          const updateJU = `
            UPDATE jadwal_ujian 
            SET tgl_ujian = ?, dosen_penguji = ?, catatan = ?
            WHERE id_proposal = ?
          `;
          db.query(
            updateJU,
            [tgl_ujian, proposal.dosen, "-", proposal.id],
            (errUpdate) => {
              if (errUpdate) {
                return res
                  .status(500)
                  .json({ msg: "Gagal update jadwal ujian", err: errUpdate });
              }

              res.json({ msg: "Status disetujui & Jadwal ujian diperbarui" });
            }
          );
        } else {
          // ✅ Belum ada, lakukan INSERT
          const idJU = `JU-${Date.now()}`;
          const insertJU = `
            INSERT INTO jadwal_ujian 
            (id_ju, jenis_ujian, id_proposal, tgl_ujian, dosen_penguji, catatan) 
            VALUES (?, ?, ?, ?, ?, ?)
          `;
          db.query(
            insertJU,
            [idJU, jenisUjian, proposal.id, tgl_ujian, proposal.dosen, "-"],
            (errInsert) => {
              if (errInsert) {
                return res
                  .status(500)
                  .json({ msg: "Gagal simpan jadwal ujian", err: errInsert });
              }

              res.json({
                msg: "Status disetujui & Jadwal ujian berhasil disimpan",
              });
            }
          );
        }
      });
    });
  });
};

exports.getByMahasiswa = (req, res) => {
  const nim = req.user.nim;
  if (!nim) {
    return res.status(400).json({ msg: "NIM tidak tersedia dari token" });
  }

  Proposal.getAllByNim(nim, (err, results) => {
    if (err) return res.status(500).json({ msg: "DB error", err });
    if (results.length === 0) return res.status(404).json({ msg: "Not found" });

    res.json(results);
  });
};

// helper: ambil nim berdasarkan id_users
function getNimByIdUsers(id_users) {
  return new Promise((resolve, reject) => {
    const sql = "SELECT nim FROM mahasiswa WHERE id_users = ?";
    db.query(sql, [id_users], (err, results) => {
      if (err) return reject(err);
      if (results.length === 0) return resolve(null);
      resolve(results[0].nim);
    });
  });
}

function getNimByIdUsers(id_users) {
  return new Promise((resolve, reject) => {
    const sql = "SELECT nim FROM mahasiswa WHERE id_users = ?";
    db.query(sql, [id_users], (err, results) => {
      if (err) return reject(err);
      if (results.length === 0) return resolve(null);
      resolve(results[0].nim);
    });
  });
}

exports.getByMahasiswa = async (req, res) => {
  try {
    const id_users = req.user?.id_users;
    if (!id_users) {
      return res.status(400).json({ msg: "ID user tidak tersedia di token" });
    }

    const nim = await getNimByIdUsers(id_users);
    if (!nim) {
      return res
        .status(404)
        .json({ msg: "NIM tidak ditemukan untuk user ini" });
    }

    Proposal.getAllByNim(nim, (err, results) => {
      if (err) return res.status(500).json({ msg: "DB error", err });
      if (results.length === 0)
        return res.status(404).json({ msg: "Proposal tidak ditemukan" });

      res.json(results);
    });
  } catch (error) {
    return res
      .status(500)
      .json({ msg: "Internal server error", error: error.message });
  }
};

exports.getProposalByMahasiswa = async (req, res) => {
  try {
    const userId = req.user.id;

    // Ambil nim mahasiswa dari tabel mahasiswa berdasarkan id_users
    const mahasiswa = await db.Mahasiswa.findOne({
      where: { id_users: userId },
    });

    if (!mahasiswa) {
      return res
        .status(404)
        .json({ message: "Data mahasiswa tidak ditemukan." });
    }

    const proposal = await db.Proposal.findOne({
      where: { nim: mahasiswa.nim },
      include: [db.Topik, db.Dosen], // jika kamu punya relasi
    });

    if (!proposal) {
      return res.json([]); // atau return status kosong
    }

    res.json([proposal]); // kembalikan dalam array
  } catch (err) {
    console.error("Error getProposalByMahasiswa:", err);
    res.status(500).json({ message: "Terjadi kesalahan server." });
  }
};
