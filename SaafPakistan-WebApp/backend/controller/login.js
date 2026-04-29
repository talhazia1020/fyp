const admin = require("firebase-admin");
const bcrypt = require("bcrypt");
const firestore = admin.firestore();

module.exports.login = async (req, res, next) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ error: "Email is required" });
    }

    // Check all possible user collections
    const collections = ['users', 'rider', 'warehouseManager', 'admin', 'appUsers'];
    let userData = null;

    for (const collectionName of collections) {
      const userQuery = await firestore
        .collection(collectionName)
        .where("email", "==", email)
        .limit(1)
        .get();

      if (!userQuery.empty) {
        userData = userQuery.docs[0].data();
        break;
      }
    }

    if (!userData) {
      return res.status(401).json({ error: "Invalid email or password" });
    }

    if (!userData.role) {
      // For appUsers collection, set default role as "user"
      if (collectionName === 'appUsers') {
        userData.role = "user";
      } else {
        return res.status(401).json({ error: "Invalid email or password" });
      }
    }

    const response = { role: userData.role };
    if (userData.area && userData.area.id) {
      response.area = userData.area.id;
    }

    return res.status(200).json(response);
  } catch (error) {
    return res.status(500).json({ error: error.message || "Login failed" });
  }
};
