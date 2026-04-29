// Scripts for firebase and firebase messaging
importScripts(
  "https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js"
);
importScripts(
  "https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging-compat.js"
);

// Initialize the Firebase app in the service worker by passing the generated config
var firebaseConfig = {
  apiKey: "AIzaSyAX_2YhxrkkqcAjH_18D1Bwi08-JRjNRBg",
  authDomain: "saafpakistan-c22b3.firebaseapp.com",
  projectId: "saafpakistan-c22b3",
  storageBucket: "saafpakistan-c22b3.firebasestorage.app",
  messagingSenderId: "1048990693052",
  appId: "1:1048990693052:web:6e7038b72b104f4d4842b9",
  measurementId: "G-31C4BLJQJW",
};

firebase.initializeApp(firebaseConfig);

// Retrieve firebase messaging
const messaging = firebase.messaging();

messaging.onBackgroundMessage(function (payload) {
  console.log("Received background message ", payload);

  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
  };
  self.registration.showNotification(notificationTitle, notificationOptions);
});
