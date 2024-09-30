import 'package:admin_mysiswa2/webpages/login_webpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyAXt_eN21I3MsIkl3ADT-iLm3oR3q623BY",
        authDomain: "kad-mysiswa.firebaseapp.com",
        projectId: "kad-mysiswa",
        storageBucket: "kad-mysiswa.appspot.com",
        messagingSenderId: "512530633780",
        appId: "1:512530633780:web:6ffb7cf6005ad91353a661"),
  );
  runApp(MyApp());
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