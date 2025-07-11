const express = require("express");
const router = express.Router();
const UserController = require("../controllers/userController");

// ✅ Tambahkan ini:
const authMiddleware = require("../middleware/auth");

// Routes
router.get("/profile", authMiddleware, UserController.getProfile);
router.get("/", authMiddleware, UserController.getAllUsers);
router.get("/:id", UserController.getUserById);
router.post("/", UserController.createUser);
router.put("/:id", UserController.updateUser);
router.delete("/:id", UserController.deleteUser);

module.exports = router;
