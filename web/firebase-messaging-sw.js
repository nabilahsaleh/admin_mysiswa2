// Import and configure Firebase
importScripts('https://www.gstatic.com/firebasejs/9.1.3/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.1.3/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyAXt_eN21I3MsIkl3ADT-iLm3oR3q623BY",
  authDomain: "kad-mysiswa.firebaseapp.com",
  projectId: "kad-mysiswa",
  storageBucket: "kad-mysiswa.appspot.com",
  messagingSenderId: "512530633780",
  appId: "1:512530633780:web:6ffb7cf6005ad91353a661"
});

// Retrieve Firebase Messaging object
const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage(function(payload) {
  console.log('Received background message ', payload);

  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: 'assets/notification.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
