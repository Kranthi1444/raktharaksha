import 'package:flutter/material.dart';
import 'package:raktharaksha/pages/Authentication/auth_page.dart';
import 'package:raktharaksha/pages/Main%20pages/Homepage.dart';
import 'package:raktharaksha/pages/onboarding/onboardscreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://kiocjuvqtnvsedgirrss.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtpb2NqdXZxdG52c2VkZ2lycnNzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM2ODkxMzAsImV4cCI6MjA2OTI2NTEzMH0.W-788gUJOwYY4XTR1dsEwxjn1MVd-oS0v2nFmep8Ag0',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // ✅ If user logged in, go Homepage else Onboarding
      home: session == null ? OnboardingScreen() : Homepage(),
    );
  }
}
