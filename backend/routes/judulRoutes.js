const express = require("express");
const router = express.Router();
const JudulController = require("../controllers/judulController");
const authMiddleware = require("../middleware/auth");

router.get("/check", JudulController.checkSimilarity);
router.get("/with-status", JudulController.getAllWithStatus);
router.get("/", JudulController.getAll);
router.get("/:id", JudulController.getById);
router.post("/", authMiddleware, JudulController.create);
router.put("/:id", JudulController.update);
router.get("/status/:nim", JudulController.getByNIM);
router.delete("/:id", JudulController.remove);

module.exports = router;
