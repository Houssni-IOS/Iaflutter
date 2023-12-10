import 'package:tpiadev/ListActivity.dart';
import 'package:tpiadev/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:tpiadev/loginecran.dart';
import 'package:tpiadev/addActivity.dart'; // Import the AddActivity page

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseUIAuth.configureProviders([EmailAuthProvider()]);
  runApp(MyApp());}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',
      routes: {
        '/login': (context) => Loginecran(),
        '/addActivity': (context) => AddActivity(),
        '/ListActivity':(context) => ListActivity(),
      },
    );
  }
}
