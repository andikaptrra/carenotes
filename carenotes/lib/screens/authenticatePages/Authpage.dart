import 'package:carenotes/screens/authenticatePages/LoginPage.dart';
import 'package:carenotes/screens/authenticatePages/RegisterPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;

    double availableHeight = heightScreen - statusBarHeight;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: statusBarHeight),
        child: Container(
            width: widthScreen,
            height: availableHeight,
            color: const Color(0xFF00295A),
            child: Center(
              child: Stack(
                children: [
                  Positioned(
                    top: availableHeight * 0.05,
                    left: 40,
                    right: 40,
                    child: Container(
                        child: Image.asset(
                      'assets/images/patient-card.png',
                      fit: BoxFit.fitWidth,
                    )),
                  ),
                  Positioned(
                    bottom: availableHeight * 0.05,
                    left: 30,
                    right: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: const Color(0xFF336082),
                      ),
                      height: heightScreen * 0.4,
                      width: widthScreen * 0.7,
                      child: Center(
                          child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              'assets/images/carenotes-logo.png',
                              scale: 5,
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Text(
                              'simpan dan ingat konsultasi kamu untuk perawatan yang lebih baik',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white, fontSize: 18),
                            ),
                          ),
                          Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration:
                                      Duration(milliseconds: 150),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                  pageBuilder:
                                      (context, animation, secondaryAnimation) {
                                    return LoginPage();
                                  },
                                ),
                              );
                            },
                            child: Text(
                              'Masuk',
                              style: TextStyle(
                                  color: Color(0xFF00295A),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18),
                            ),
                            style: ElevatedButton.styleFrom(
                                fixedSize: const Size(200, 10),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50))),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration:
                                      Duration(milliseconds: 150),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                  pageBuilder:
                                      (context, animation, secondaryAnimation) {
                                    return RegisterPage();
                                  },
                                ),
                              );
                            },
                            child: Text(
                              'Daftar',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18),
                            ),
                            style: ElevatedButton.styleFrom(
                                fixedSize: const Size(200, 10),
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50))),
                          ),
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, bottom: 15),
                            child: Text(
                              'dengan menekan Daftar di CareNotes, kamu setuju dengan syarat dan kebijakan privasi kami.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                  color: Color(0xFF6C8EAA), fontSize: 14),
                            ),
                          ),
                        ],
                      )),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
