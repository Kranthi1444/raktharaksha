import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

class Onboard2 extends StatelessWidget {
  const Onboard2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Column(
          children: [
            SizedBox(
              height: 100,
            ),
            Lottie.network(
                "https://lottie.host/a97ff232-ed1a-4f54-aa3c-61033f419076/okTxiQ435q.json"),
            SizedBox(
              height: 20,
            ),
            Text(
              "Embrace kindness, spread joy.",
              style: GoogleFonts.sanchez(
                  fontSize: 15, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      )),
    );
  }
}
