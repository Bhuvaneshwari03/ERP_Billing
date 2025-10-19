import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart'; // placeholder

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyAD8iOWsEQxz-kGwmIzu8mk8MnBiDPvSsc",
          authDomain: "erp-billing-app.firebaseapp.com",
          projectId: "erp-billing-app",
          storageBucket: "erp-billing-app.appspot.com",
          messagingSenderId: "1074364057068",
          appId: "1:1074364057068:android:441b59e4d560366a306cc9",
        ),
      );
    } else {
      await Firebase.initializeApp(); // Android/iOS auto-detect
    }
    runApp(const MyApp());
  } catch (e) {
    print("Firebase Init Error: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ERP App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          print("🔄 Connection State: ${snapshot.connectionState}");
          print("📦 Auth Data: ${snapshot.data}");

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: Text("Loading...")),
            );
          } else if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}

