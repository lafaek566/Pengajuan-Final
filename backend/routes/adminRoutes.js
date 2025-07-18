const express = require("express");
const router = express.Router();

const DosenController = require("../controllers/DosenController");
const TopikController = require("../controllers/TopikController");
const ProdiController = require("../controllers/ProdiController");
const MahasiswaController = require("../controllers/mahasiswaController");

// Dosen
router.get("/dosen", DosenController.getAll);
router.post("/dosen", DosenController.create);
router.put("/dosen/:id", DosenController.update);
router.delete("/dosen/:id", DosenController.remove);

// Topik
router.get("/topik", TopikController.getAll);
router.post("/topik", TopikController.create);
router.put("/topik/:id", TopikController.update);
router.delete("/topik/:id", TopikController.remove);

// Prodi
router.get("/prodi", ProdiController.getAll);
router.post("/prodi", ProdiController.create);
router.put("/prodi/:id", ProdiController.update);
router.delete("/prodi/:id", ProdiController.remove);

router.get("/dosen/peran/:peran", DosenController.getByPeran);

// Mahasiswa
router.get("/mahasiswa", MahasiswaController.getAllMahasiswa);

module.exports = router;
