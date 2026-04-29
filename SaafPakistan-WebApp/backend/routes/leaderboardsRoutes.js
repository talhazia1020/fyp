const express = require("express");
const Leaderboard = require("../controller/leaderboard");
const firebaseAuth = require("../middleware/firebase-auth");

const router = express.Router();
router.get(
  "/leaderboard",
  //  firebaseAuth,
  Leaderboard.getLeaderboard
);

router.get(
  "/leaderboard/organization",
  //  firebaseAuth,
  Leaderboard.getLeaderboard
);


router.get("/", (req, res) => {
  res.send("🚀 SaafPakistan Backend is Running Successfully!");
});

module.exports = router;
