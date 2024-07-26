import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  Future<void> _onIntroEnd(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white, // match onboarding background
      statusBarIconBrightness: Brightness.dark,
    ));

    return SafeArea(
      child: IntroductionScreen(
        pages: [
          PageViewModel(
            title: "Welcome to Forti",
            body: "AI-based malware detection made simple.",
            image: Center(child: Icon(Icons.security, size: 175, color: Colors.blue)),
            decoration: const PageDecoration(
              pageColor: Colors.white,
            ),
          ),
          PageViewModel(
            title: "How it Works",
            body: "Scan your device for potential threats with a single tap.",
            image: Center(child: Icon(Icons.search, size: 175, color: Colors.blue)),
            decoration: const PageDecoration(
              pageColor: Colors.white,
            ),
          ),
          PageViewModel(
            title: "Stay Protected",
            body: "Receive real-time alerts and keep your device safe.",
            image: Center(child: Icon(Icons.notifications, size: 175, color: Colors.blue)),
            decoration: const PageDecoration(
              pageColor: Colors.white,
            ),
          ),
        ],
        onDone: () => _onIntroEnd(context),
        onSkip: () => _onIntroEnd(context),
        showSkipButton: true,
        skip: const Text("Skip"),
        next: const Icon(Icons.arrow_forward),
        done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
