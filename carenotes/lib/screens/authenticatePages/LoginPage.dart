import 'package:carenotes/services/AuthServices.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  final AuthManager _authManager = AuthManager();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double availableHeight = heightScreen - statusBarHeight;

    return Scaffold(
      body: _isLoading
          ? Container(
              color: const Color(0xFF00295A),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LoadingAnimationWidget.threeArchedCircle(
                        color: Colors.white, size: 100),
                    Container(
                      height: 50,
                    ),
                    Text(
                      'Loading...',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: EdgeInsets.only(top: statusBarHeight),
              child: SingleChildScrollView(
                child: Container(
                    width: widthScreen,
                    height: availableHeight,
                    color: const Color(0xFF00295A),
                    child: Center(
                      child: Stack(
                        children: [
                          Positioned(
                            top: availableHeight * 0.15,
                            left: 50,
                            right: 50,
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
                                color: Color.fromARGB(188, 51, 96, 130),
                              ),
                              height: heightScreen * 0.85,
                              width: widthScreen * 0.85,
                              child: Center(
                                  child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      'assets/images/carenotes-logo.png',
                                      scale: 7,
                                    ),
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Text(
                                      'SELAMAT DATANG KEMBALI',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontSize: 30,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20,
                                        bottom: 20,
                                        left: 30,
                                        right: 30),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'email',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 1,
                                                blurRadius: 5,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: TextField(
                                            controller: _emailController,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 20, left: 30, right: 30),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Password',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 1,
                                                blurRadius: 5,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Stack(
                                            alignment: Alignment.centerRight,
                                            children: [
                                              TextField(
                                                obscureText: _obscureText,
                                                controller: _passwordController,
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  _obscureText
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                  color: Colors.grey,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _obscureText =
                                                        !_obscureText;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  ElevatedButton(
                                    onPressed: () async {
                                      String _password =
                                          _passwordController.text.trim();
                                      String _email =
                                          _emailController.text.trim();

                                      if (_password != '' && _email != '') {
                                        setState(() {
                                          _isLoading = true;
                                        });

                                        bool signInResult = await _authManager
                                            .signIn(context, _email, _password);

                                        if (signInResult == false) {
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        }
                                      } else {
                                        PanaraInfoDialog.showAnimatedFromBottom(
                                            context,
                                            message:
                                                'isi kolom email dan password',
                                            buttonText: 'Oke',
                                            onTapDismiss: () {
                                          Navigator.pop(context);
                                        },
                                            panaraDialogType:
                                                PanaraDialogType.warning);
                                      }
                                    },
                                    child: Text(
                                      'Masuk',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        fixedSize: const Size(200, 10),
                                        backgroundColor: Color(0xFF021E3F),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50))),
                                  ),
                                  Spacer()
                                ],
                              )),
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
    );
  }
}
