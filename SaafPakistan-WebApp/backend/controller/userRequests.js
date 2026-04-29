const admin = require("firebase-admin");
const firestore = admin.firestore();

// Get all pickup requests for a specific user
module.exports.getUserRequests = async (req, res, next) => {
  try {
    const userEmail = req.user.email;
    
    // Find user by email to get their ID
    const userQuery = await firestore
      .collection("appUsers")
      .where("email", "==", userEmail)
      .limit(1)
      .get();

    if (userQuery.empty) {
      return res.status(404).json({ error: "User not found" });
    }

    const userDoc = userQuery.docs[0];
    const userId = userDoc.id;

    // Get all orders for this user
    const ordersSnapshot = await firestore
      .collection("orders")
      .where("userId", "==", userId)
      .get();

    const requests = [];
    ordersSnapshot.forEach((docSnap) => {
      const order = docSnap.data();
      requests.push({
        id: docSnap.id,
        userId: order.userId,
        userName: order.userName || "",
        userPhone: order.userPhone || "",
        address: order.address || "",
        wasteType: order.wasteType || "",
        weight: order.weight || "",
        date: order.date || "",
        time: order.time || "",
        status: order.status || "Pending",
        notes: order.notes || "",
        createdAt: order.createdAt || "",
        updatedAt: order.updatedAt || "",
        riderId: order.riderId || null,
        riderName: order.riderName || "",
        amount: order.amount || 0,
        paymentStatus: order.paymentStatus || "Unpaid",
      });
    });

    // Sort by creation date (newest first)
    requests.sort((a, b) => {
      const dateA = new Date(a.createdAt || 0);
      const dateB = new Date(b.createdAt || 0);
      return dateB - dateA;
    });

    res.status(200).json(requests);
  } catch (error) {
    console.error("Error fetching user requests: ", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

// Create a new pickup request
module.exports.createRequest = async (req, res, next) => {
  try {
    const { address, wasteType, date, time, notes, phone, name } = req.body;
    const userEmail = req.user.email;

    // Validate required fields
    if (!address || !wasteType || !date || !time) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    // Find user by email to get their ID
    const userQuery = await firestore
      .collection("appUsers")
      .where("email", "==", userEmail)
      .limit(1)
      .get();

    let userId = null;
    let userName = name || "";
    let userPhone = phone || "";

    if (!userQuery.empty) {
      const userDoc = userQuery.docs[0];
      const userData = userDoc.data();
      userId = userDoc.id;
      userName = userName || userData.name || "";
      userPhone = userPhone || userData.phone || "";
    }

    // Create new order document
    const orderRef = firestore.collection("orders").doc();
    const orderData = {
      id: orderRef.id,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
      address: address,
      wasteType: wasteType,
      date: date,
      time: time,
      notes: notes || "",
      status: "Pending",
      paymentStatus: "Unpaid",
      amount: 0,
      weight: "",
      riderId: null,
      riderName: null,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    await orderRef.set(orderData);

    res.status(201).json({
      message: "Pickup request created successfully",
      request: {
        id: orderRef.id,
        ...orderData,
      },
    });
  } catch (error) {
    console.error("Error creating pickup request: ", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

// Get a specific request by ID
module.exports.getRequestById = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userEmail = req.user.email;

    // Find user by email
    const userQuery = await firestore
      .collection("appUsers")
      .where("email", "==", userEmail)
      .limit(1)
      .get();

    if (userQuery.empty) {
      return res.status(404).json({ error: "User not found" });
    }

    const userDoc = userQuery.docs[0];
    const userId = userDoc.id;

    // Get the order
    const orderDoc = await firestore.collection("orders").doc(id).get();

    if (!orderDoc.exists) {
      return res.status(404).json({ error: "Request not found" });
    }

    const order = orderDoc.data();

    // Verify the order belongs to this user
    if (order.userId !== userId) {
      return res.status(403).json({ error: "Unauthorized access" });
    }

    res.status(200).json({
      id: orderDoc.id,
      ...order,
    });
  } catch (error) {
    console.error("Error fetching request: ", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

// Cancel a pickup request (only if status is Pending)
module.exports.cancelRequest = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userEmail = req.user.email;

    // Find user by email
    const userQuery = await firestore
      .collection("appUsers")
      .where("email", "==", userEmail)
      .limit(1)
      .get();

    if (userQuery.empty) {
      return res.status(404).json({ error: "User not found" });
    }

    const userDoc = userQuery.docs[0];
    const userId = userDoc.id;

    // Get the order
    const orderDoc = await firestore.collection("orders").doc(id).get();

    if (!orderDoc.exists) {
      return res.status(404).json({ error: "Request not found" });
    }

    const order = orderDoc.data();

    // Verify the order belongs to this user
    if (order.userId !== userId) {
      return res.status(403).json({ error: "Unauthorized access" });
    }

    // Only allow cancellation if status is Pending
    if (order.status !== "Pending") {
      return res.status(400).json({ 
        error: "Cannot cancel request with status: " + order.status 
      });
    }

    // Update the order status to Cancelled
    await firestore.collection("orders").doc(id).update({
      status: "Cancelled",
      updatedAt: new Date().toISOString(),
    });

    res.status(200).json({ message: "Request cancelled successfully" });
  } catch (error) {
    console.error("Error cancelling request: ", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

// Get user profile information
module.exports.getUserProfile = async (req, res, next) => {
  try {
    const userEmail = req.user.email;

    // Find user by email
    const userQuery = await firestore
      .collection("appUsers")
      .where("email", "==", userEmail)
      .limit(1)
      .get();

    if (userQuery.empty) {
      return res.status(404).json({ error: "User not found" });
    }

    const userDoc = userQuery.docs[0];
    const userData = userDoc.data();

    // Get request statistics
    const ordersSnapshot = await firestore
      .collection("orders")
      .where("userId", "==", userDoc.id)
      .get();

    let totalRequests = 0;
    let pendingRequests = 0;
    let completedRequests = 0;
    let assignedRequests = 0;
    let cancelledRequests = 0;

    ordersSnapshot.forEach((docSnap) => {
      const order = docSnap.data();
      totalRequests++;
      switch (order.status) {
        case "Pending":
          pendingRequests++;
          break;
        case "Assigned":
          assignedRequests++;
          break;
        case "Completed":
          completedRequests++;
          break;
        case "Cancelled":
          cancelledRequests++;
          break;
        default:
          break;
      }
    });

    res.status(200).json({
      id: userDoc.id,
      name: userData.name || "",
      email: userData.email || "",
      phone: userData.phone || "",
      address: userData.address || "",
      area: userData.area || "",
      accountType: userData.accountType || "",
      createdAt: userData.createdAt || "",
      stats: {
        totalRequests,
        pendingRequests,
        assignedRequests,
        completedRequests,
        cancelledRequests,
      },
    });
  } catch (error) {
    console.error("Error fetching user profile: ", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

// Update user profile
module.exports.updateUserProfile = async (req, res, next) => {
  try {
    const userEmail = req.user.email;
    const { name, phone, address } = req.body;

    // Find user by email
    const userQuery = await firestore
      .collection("appUsers")
      .where("email", "==", userEmail)
      .limit(1)
      .get();

    if (userQuery.empty) {
      return res.status(404).json({ error: "User not found" });
    }

    const userDoc = userQuery.docs[0];

    // Update user data
    const updateData = {};
    if (name) updateData.name = name;
    if (phone) updateData.phone = phone;
    if (address) updateData.address = address;

    if (Object.keys(updateData).length === 0) {
      return res.status(400).json({ error: "No fields to update" });
    }

    await firestore.collection("appUsers").doc(userDoc.id).update(updateData);

    res.status(200).json({ message: "Profile updated successfully" });
  } catch (error) {
    console.error("Error updating user profile: ", error);
    res.status(500).json({ error: "Internal server error" });
  }
};