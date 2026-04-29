const express = require("express");
const userRequests = require("../controller/userRequests");
const firebaseAuth = require("../middleware/firebase-auth");

const router = express.Router();

// Get all requests for the logged-in user
router.get("/user/requests", firebaseAuth, userRequests.getUserRequests);

// Create a new pickup request
router.post("/user/requests", firebaseAuth, userRequests.createRequest);

// Get a specific request by ID
router.get("/user/requests/:id", firebaseAuth, userRequests.getRequestById);

// Cancel a pickup request
router.put("/user/requests/:id/cancel", firebaseAuth, userRequests.cancelRequest);

// Get user profile
router.get("/user/profile", firebaseAuth, userRequests.getUserProfile);

// Update user profile
router.put("/user/profile", firebaseAuth, userRequests.updateUserProfile);

module.exports = router;