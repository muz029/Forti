import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // No need for manual FirebaseOptions
  await _requestPermissions(); // Request permissions before the app starts
  runApp(FortiAiApp());
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
}

Future<void> _requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.storage,
    Permission.notification,
    Permission.manageExternalStorage,
  ].request();

  statuses.forEach((permission, status) {
    if (status.isDenied || status.isPermanentlyDenied) {
      // Handle the case where the user denies the permission.
      // Show a dialog or redirect to settings if necessary.
    }
  });
}

class FortiAiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forti',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: SplashScreen(),
    );
  }
}
