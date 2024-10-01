import 'package:carenotes/screens/authenticatePages/Authpage.dart';
import 'package:carenotes/screens/mainPages/RecordPage.dart';
import 'package:carenotes/screens/mainPages/TextPage.dart';
import 'package:carenotes/services/AuthServices.dart';
import 'package:carenotes/services/changeLocalHostPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter/widgets.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
// import 'package:path/path.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  // final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Stream<List<Map<String, dynamic>>>? _notesStream;
  final AuthManager _authManager = AuthManager();
  String _swipeDirection = '';
  bool _isSearching = false;
  Map<int, bool> isEditingMap = {};
  Map<int, String> originalTitles = {};

  @override
  void initState() {
    super.initState();
    _authManager.searchNotes('');
    _notesStream = _authManager.getNotesStream();
  }

  @override
  void dispose() {
    // _timer.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    String query = _searchController.text.trim();
    _authManager.searchNotes(query);
    setState(() {
      _notesStream = _authManager.getNotesStream();
    });
  }

  void _checkSecretItem() {
    if (_swipeDirection == '→→→→→→→→') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ChangeLP()));
      _swipeDirection = '';
    }

    if (_swipeDirection.length >= 8) {
      _swipeDirection = '';
    }

    // print(_swipeDirection.length);
    // print('swipedirection : ' + _swipeDirection);
  }

  String extractText(String bodyText) {
    String keluhanTag =
        '<p><strong style=""><font color="#64b5f6">Keluhan :</font>&nbsp;</strong><span style="color: rgb(255, 235, 238);">';
    String rekomendasiTag =
        '<p><strong style=""><font color="#64b5f6">Rekomendasi :</font>&nbsp;</strong><span style="color: rgb(255, 235, 238);">';
    String penggunaanObatTag =
        '<p><strong style=""><font color="#64b5f6">Penggunaan obat:</font>&nbsp;</strong><span style="color: rgb(255, 235, 238);">';

    // Cari keluhan
    int startKeluhanIndex = bodyText.indexOf(keluhanTag);
    if (startKeluhanIndex != -1) {
      startKeluhanIndex += keluhanTag.length;
      int endKeluhanIndex = bodyText.indexOf('</span></p>', startKeluhanIndex);
      if (endKeluhanIndex != -1) {
        String keluhanText =
            bodyText.substring(startKeluhanIndex, endKeluhanIndex).trim();
        if (keluhanText == 'keluhan tidak terdeteksi') {
          // Cari rekomendasi
          int startRekomendasiIndex = bodyText.indexOf(rekomendasiTag);
          if (startRekomendasiIndex != -1) {
            startRekomendasiIndex += rekomendasiTag.length;
            int endRekomendasiIndex =
                bodyText.indexOf('</span></p>', startRekomendasiIndex);
            if (endRekomendasiIndex != -1) {
              String rekomendasiText = bodyText
                  .substring(startRekomendasiIndex, endRekomendasiIndex)
                  .trim();
              if (rekomendasiText == 'rekomendasi dokter tidak terdeteksi') {
                // Ambil penggunaan obat
                int startPenggunaanObatIndex =
                    bodyText.indexOf(penggunaanObatTag);
                if (startPenggunaanObatIndex != -1) {
                  startPenggunaanObatIndex += penggunaanObatTag.length;
                  int endPenggunaanObatIndex =
                      bodyText.indexOf('</span></p>', startPenggunaanObatIndex);
                  if (endPenggunaanObatIndex != -1) {
                    return bodyText
                        .substring(
                            startPenggunaanObatIndex, endPenggunaanObatIndex)
                        .trim();
                  }
                }
              } else {
                return rekomendasiText;
              }
            }
          }
        } else {
          return keluhanText;
        }
      }
    }

    // Jika tidak ada kondisi yang terpenuhi, kembalikan semua teks HTML
    return bodyText;
  }

  String formatTanggal(String dateString) {
    DateTime dateTime = DateFormat("dd-MM-yyyy HH:mm:ss").parse(dateString);
    String formattedDate = DateFormat("dd MMMM yyyy").format(dateTime);
    return formattedDate;
  }

  void updateNoteTitle(String refId, String newTitle) async {
    bool success = await AuthManager().updateNoteTitleByRefId(refId, newTitle);
    if (success) {
      print('Title updated successfully!');
    } else {
      print('Failed to update title.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Future<List<Map<String, dynamic>>> fetchData() async {
    //   await Future.delayed(Duration(seconds: 2));
    //   return dataList;
    // }

    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;

    double availableHeight = heightScreen - statusBarHeight;

    int indexBox = 0;
    bool heightMax = false;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton: ExpandableFab(
            openButtonBuilder: RotateFloatingActionButtonBuilder(
              child: const Icon(
                Icons.add,
                color: Color.fromARGB(255, 214, 217, 219),
              ),
              fabSize: ExpandableFabSize.regular,
              backgroundColor: Color.fromARGB(255, 92, 64, 167),
            ),
            type: ExpandableFabType.up,
            distance: 70,
            children: [
              FloatingActionButton.small(
                heroTag: null,
                child: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 150),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return TextPage(
                          dataNote: {},
                          newData: true,
                          refId: '',
                        );
                      },
                    ),
                  );
                  // Map<String, dynamic> dataInput = {
                  //   'title': 'judul',
                  //   'tanggal': '10-2-2021',
                  //   'text': 'ini text 1'
                  // };

                  // dataList.add(dataInput);
                  // setState(() {});
                  // print(dataList.length);
                },
              ),
              FloatingActionButton.small(
                heroTag: null,
                child: const Icon(Icons.mic),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 150),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return RecordPage();
                      },
                    ),
                  );
                },
              ),
            ]),
        body: Padding(
          padding: EdgeInsets.only(top: statusBarHeight),
          child: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dy < 0) {
                setState(() {
                  _swipeDirection += '↑';
                  print('↑');
                  _checkSecretItem();
                });
              } else {
                setState(() {
                  _swipeDirection += '↓';
                  print('↓');
                });
              }
            },
            onHorizontalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dx > 0) {
                setState(() {
                  _swipeDirection += '→';
                  print('→');
                  _checkSecretItem();
                });
              } else {
                setState(() {
                  _swipeDirection += '←';
                  print('←');
                });
              }
            },
            child: Container(
              width: widthScreen,
              height: availableHeight,
              color: Color(0xFF005D96),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 20, left: 20, right: 20, bottom: 10),
                      child: Container(
                        height: 50,
                        child: Row(
                          children: [
                            _isSearching
                                ? Flexible(
                                    child: TextField(
                                      controller: _searchController,
                                      decoration: InputDecoration(
                                        hintText: 'Search note...',
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 15.0),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Colors.blue.shade900,
                                              width: 2),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Colors.blue.shade900,
                                              width: 2),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Colors.blue.shade900,
                                              width: 2),
                                        ),
                                      ),
                                      onChanged: (_) => _onSearchChanged(),
                                    ),
                                  )
                                : Image.asset(
                                    'assets/images/carenotes-logo.png',
                                    scale: 6,
                                  ),
                            _isSearching
                                ? Container(
                                    width: 10,
                                  )
                                : Spacer(),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isSearching = !_isSearching;
                                  if (_isSearching == false) {
                                    _searchController.text = '';
                                    _authManager.searchNotes('');
                                  }
                                });
                              },
                              child: Icon(
                                _isSearching
                                    ? Icons.close_rounded
                                    : Icons.search_rounded,
                                color: Colors.white,
                                size: 35,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: GestureDetector(
                                onTap: () async {
                                  Map<String, dynamic>? userInfo =
                                      await AuthManager.getUserInfo();

                                  PanaraInfoDialog.showAnimatedFromBottom(
                                      context,
                                      title: 'USER INFO\n',
                                      color: Colors.red,
                                      buttonTextColor: Colors.white,
                                      noImage: true,
                                      padding: EdgeInsets.all(10),
                                      message:
                                          "name : ${userInfo!['name']}\nemail : ${userInfo['email']}",
                                      buttonText: 'Logout', onTapDismiss: () {
                                    FirebaseAuth.instance.signOut();
                                    Navigator.of(context).pop();
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => AuthPage()));
                                  }, panaraDialogType: PanaraDialogType.custom);
                                },
                                child: Icon(
                                  Icons.account_circle_outlined,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _notesStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: _isSearching
                                ? Container()
                                : Container(
                                    width: widthScreen,
                                    height: 150,
                                    child: Column(
                                      children: [
                                        LoadingAnimationWidget.discreteCircle(
                                          color: Colors.white,
                                          size: 70,
                                        ),
                                        Spacer(),
                                        Text(
                                          'Memuat rangkuman...',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.plusJakartaSans(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600),
                                        )
                                      ],
                                    ),
                                  ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Container(
                              height: heightScreen * 0.8,
                              child: Center(
                                child: Text(
                                  _isSearching
                                      ? 'tidak ada catatan "${_searchController.text}" terdeteksi'
                                      : 'belum ada rangkuman',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            );
                          } else {
                            return SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: StaggeredGrid.count(
                                crossAxisCount: 2,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                children: List.generate(snapshot.data!.length,
                                    (index) {
                                  if (!isEditingMap.containsKey(index)) {
                                    isEditingMap[index] = false;
                                    originalTitles[index] =
                                        snapshot.data![index]['title'];
                                  }

                                  if (index != 0) {
                                    indexBox++;
                                    if (indexBox > 2) {
                                      heightMax = !heightMax;
                                      indexBox = 1;
                                    }
                                  }

                                  Map<String, dynamic> data =
                                      snapshot.data![index];

                                  // print('data : ' + snapshot.data.toString());

                                  return Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: GestureDetector(
                                      onTap: () async {
                                        // print('Data : ' +
                                        //     data['note'].toString());
                                        String? idRef = await _authManager.fetchNoteIdByDate(data['date']);

                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            transitionDuration:
                                                Duration(milliseconds: 150),
                                            transitionsBuilder: (context,
                                                animation,
                                                secondaryAnimation,
                                                child) {
                                              return FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              );
                                            },
                                            pageBuilder: (context, animation,
                                                secondaryAnimation) {
                                              return TextPage(
                                                  dataNote:
                                                      snapshot.data![index],
                                                  newData: false,
                                                  refId: idRef!);
                                            },
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: widthScreen * 0.45,
                                        height: index == 0
                                            ? 250
                                            : heightMax
                                                ? 250
                                                : 200,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFFE666),
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 4,
                                              color: Color(0x33000000),
                                              offset: Offset(0, 4),
                                              spreadRadius: 3,
                                            )
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  isEditingMap[index] = true;
                                                });
                                              },
                                              child: Container(
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          -1, 0),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                15, 8, 0, 2),
                                                    child: isEditingMap[
                                                                index] ==
                                                            false
                                                        ? Text(
                                                            data['title'],
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'PT Serif',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                            ),
                                                          )
                                                        : TextField(
                                                            decoration:
                                                                InputDecoration(
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .zero,
                                                            ),
                                                            controller:
                                                                TextEditingController(
                                                                    text: data[
                                                                        'title']),
                                                            onSubmitted:
                                                                (newValue) async {
                                                               setState(() {
                                                                  isEditingMap[index] = false;
                                                                });
                                                                if (newValue != originalTitles[index]) {
                                                                  String? idRef = await _authManager.fetchNoteIdByDate(data['date']);
                                                                  String newTitle = newValue;
                                                                  updateNoteTitle(idRef!, newTitle);
                                                                  print('UPDATED TITLE: $newValue');
                                                                }
                                                            },
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'PT Serif',
                                                              fontSize:
                                                                  12, // Sesuaikan ukuran font
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Divider(
                                              thickness: 1,
                                              indent: 15,
                                              endIndent: 15,
                                              color: Color(0xCC787878),
                                              // style: DividerStyle.dashed,
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(15, 8, 5, 2),
                                                child: Text(
                                                  extractText(
                                                      data['note'].toString()),
                                                  textAlign: TextAlign.start,
                                                  maxLines: index == 0 ? 13 : 9,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily: 'PT Serif',
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment:
                                                  AlignmentDirectional(0, 0),
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 0, 0, 5),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Opacity(
                                                      opacity: 0.6,
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                -1, 0),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(15,
                                                                      15, 0, 8),
                                                          child: Text(
                                                            formatTanggal(data[
                                                                    'date']
                                                                .toString()),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'PT Serif',
                                                              fontSize: 10,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
