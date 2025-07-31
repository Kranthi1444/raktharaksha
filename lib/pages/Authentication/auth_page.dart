import 'package:flutter/material.dart';
import 'package:raktharaksha/pages/Authentication/login_or_register_page.dart';
import 'package:raktharaksha/pages/Main%20pages/Homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final session = Supabase.instance.client.auth.currentSession;
          final user = session?.user;

          if (user != null) {
            return Homepage();
          } else {
            return LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}
