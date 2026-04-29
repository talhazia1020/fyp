import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { getStorage } from "firebase/storage";
import { getMessaging } from "firebase/messaging";

// Initialize Firebase
const app = initializeApp({
  apiKey: "AIzaSyAX_2YhxrkkqcAjH_18D1Bwi08-JRjNRBg",
  authDomain: "saafpakistan-c22b3.firebaseapp.com",
  projectId: "saafpakistan-c22b3",
  storageBucket: "saafpakistan-c22b3.firebasestorage.app",
  messagingSenderId: "1048990693052",
  appId: "1:1048990693052:web:6e7038b72b104f4d4842b9",
  measurementId: "G-31C4BLJQJW"
});

export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);
export const messaging = getMessaging(app);
