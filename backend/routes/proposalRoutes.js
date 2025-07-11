const express = require("express");
const router = express.Router();
const ProposalController = require("../controllers/proposalController");
const authMiddleware = require("../middleware/auth");

router.get("/by-mahasiswa", authMiddleware, ProposalController.getByMahasiswa);

router.post("/", ProposalController.submit);
router.get("/", ProposalController.getAll);
router.get("/:id", ProposalController.getById);
router.put("/:id", ProposalController.update);
router.delete("/:id", ProposalController.remove);
router.put("/status/:id", ProposalController.updateStatus);

module.exports = router;
