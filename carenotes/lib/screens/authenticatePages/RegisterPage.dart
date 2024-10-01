import 'package:carenotes/services/AuthServices.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;
  bool _obscureTextTwo = true;

  final AuthManager _authManager = AuthManager();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                                      'Isi formulir di bawah',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontSize: 28,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
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
                                          'Nama Lengkap',
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
                                            controller: _nameController,
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
                                          'Email',
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
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 20, left: 30, right: 30),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Konfirmasi Password',
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
                                                obscureText: _obscureTextTwo,
                                                controller:
                                                    _confirmPasswordController,
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  _obscureTextTwo
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                  color: Colors.grey,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _obscureTextTwo =
                                                        !_obscureTextTwo;
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
                                      String _confirmPassword =
                                          _confirmPasswordController.text
                                              .trim();
                                      String _email =
                                          _emailController.text.trim();
                                      String _name =
                                          _nameController.text.trim();

                                      if (_password != '' &&
                                          _confirmPassword != '' &&
                                          _email != '' &&
                                          _name != '') {
                                        if (_password == _confirmPassword) {
                                          setState(() {
                                            _isLoading = true;
                                          });

                                          bool signUpResult =
                                              await _authManager.signUp(
                                                  _password,
                                                  _confirmPassword,
                                                  _email,
                                                  _name);

                                          if (signUpResult) {
                                            print('Sign up berhasil!');
                                            _authManager.signIn(
                                                context, _email, _password);
                                          } else {
                                            setState(() {
                                              _isLoading = false;
                                            });

                                            print('Sign up gagal.');
                                          }
                                        } else {
                                          PanaraInfoDialog
                                              .showAnimatedFromBottom(context,
                                                  message:
                                                      'Password tidak sama.',
                                                  buttonText: 'Oke',
                                                  onTapDismiss: () {
                                            Navigator.pop(context);
                                          },
                                                  panaraDialogType:
                                                      PanaraDialogType.warning);
                                        }
                                      } else {
                                        PanaraInfoDialog.showAnimatedFromBottom(
                                            context,
                                            message: 'Isi semua kolom.',
                                            buttonText: 'Oke',
                                            onTapDismiss: () {
                                          Navigator.pop(context);
                                        },
                                            panaraDialogType:
                                                PanaraDialogType.warning);
                                      }
                                    },
                                    child: Text(
                                      'Daftar Sekarang',
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
