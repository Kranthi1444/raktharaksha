
import 'package:flutter/material.dart';
import 'package:raktharaksha/pages/Authentication/auth_page.dart';
import 'package:raktharaksha/pages/onboarding/onboard1.dart';
import 'package:raktharaksha/pages/onboarding/onboard2.dart';
import 'package:raktharaksha/pages/onboarding/onboard3.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool onLastpage = false;
  PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastpage = (index == 2);
              });
            },
            children: const [
              Onboard1(),
              Onboard2(),
              Onboard3(),
            ],
          ),
          Container(
            alignment: Alignment(0, 0.75),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return AuthPage();
                            })
                            );
                    
                    _controller.jumpToPage(2);
                  },
                  child: Text('skip'),
                ),
                SmoothPageIndicator(controller: _controller, count: 3),
                onLastpage
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return AuthPage();
                            }),
                          );
                        },
                        child: Text('done'),
                      )
                    : GestureDetector(
                        onTap: () {
                          _controller.nextPage(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeIn);
                        },
                        child: Text('next'),
                      )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
