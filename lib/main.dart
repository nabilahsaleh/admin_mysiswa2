import 'package:admin_mysiswa2/webpages/login_webpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:html' as html;
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAXt_eN21I3MsIkl3ADT-iLm3oR3q623BY",
      authDomain: "kad-mysiswa.firebaseapp.com",
      projectId: "kad-mysiswa",
      storageBucket: "kad-mysiswa.appspot.com",
      messagingSenderId: "512530633780",
      appId: "1:512530633780:web:6ffb7cf6005ad91353a661",
    ),
  );

  // Call notification-related methods
  checkNotificationPermission();
  listenForNewAppointments();

  runApp(MyApp());
}


// Request notification permissions in your main.dart
FirebaseMessaging messaging = FirebaseMessaging.instance;

void requestNotificationPermission() async {
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }
}

void setupFirebaseMessaging() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message while in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });
}


void checkNotificationPermission() {
  if (html.Notification.permission == "granted") {
    print("Notifications are already permitted.");
  } else if (html.Notification.permission == "default") {
    // Request permission from the user
    html.Notification.requestPermission().then((permission) {
      if (permission == "granted") {
        print("Notifications have been permitted.");
      } else {
        print("Notifications denied.");
      }
    });
  } else {
    print("Notifications are blocked.");
  }
}

void showNotification(String title, String body) {
  if (html.Notification.permission == "granted") {
    html.Notification(title, body: body, icon: 'assets/notification.png');
  } else {
    print("Notifications are not permitted.");
  }
}

void listenForNewAppointments() {
  FirebaseFirestore.instance
      .collection('bookings')
      .orderBy('created_at', descending: true)
      .snapshots()
      .listen((snapshot) {
    // Check the latest document
    if (snapshot.docs.isNotEmpty) {
      var latestAppointment = snapshot.docs.first.data();

      // Ensure the status is 'scheduled' and notification is 'no'
      if (latestAppointment['status'] == 'scheduled' &&
          latestAppointment['notification'] == 'no') {
        var studentName = latestAppointment['name'] ?? 'Unknown';

        // Trigger notification
        showNotification("New Appointment",
            "A new appointment from $studentName has been created.");

        // Update the notification field to 'yes' after sending notification
        FirebaseFirestore.instance
            .collection('bookings')
            .doc(snapshot.docs.first.id)
            .update({
          'notification': 'yes',
        }).then((_) {
          print(
              "Notification sent and updated for appointment ${snapshot.docs.first.id}");
        }).catchError((error) {
          print("Failed to update notification field: $error");
        });
      }
    }
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MySiswa Admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginWebPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
