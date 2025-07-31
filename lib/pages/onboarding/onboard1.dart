import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

class Onboard1 extends StatelessWidget {
  const Onboard1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Column(
          children: [
            SizedBox(
              height: 150,
            ),
            Lottie.network(
              "https://lottie.host/d893e572-b0a2-4654-ae4c-5b836e86fa25/V8A0PrswXB.json",
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Make A Step to Save A Life",
                style: GoogleFonts.sanchez(
                    fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            //   child: Text(
            //     "Make A Step to Save A Life",
            //     style: GoogleFonts.montserrat(
            //         fontSize: 12, fontWeight: FontWeight.w500),
            //   ),
            // ),
            SizedBox(
              height: 150,
            ),
          ],
        ),
      )),
    );
  }
}
