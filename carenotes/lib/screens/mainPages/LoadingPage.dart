import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:carenotes/screens/mainPages/MenuPage.dart';
import 'package:carenotes/screens/mainPages/TextPage.dart';
import 'package:flutter/material.dart';
// import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:path/path.dart' as pt;
import 'dart:io';

import 'package:sqflite/sqflite.dart';

class LoadingPage extends StatefulWidget {
  final String audioPath;

  const LoadingPage({Key? key, required this.audioPath}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  // String _recognizedText = '';

  // late Timer _timer;

  String loadingText = 'Harap tunggu';
  String message = '';
  Map<String, dynamic> result = {};
  Stopwatch _stopwatch = Stopwatch();
  final player = AudioPlayer();

  Future<String> _getLocalData() async {
    // Buka database lokal
    final database = await openDatabase(
      pt.join(await getDatabasesPath(), 'localDB.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE IF NOT EXISTS local_data(id INTEGER PRIMARY KEY, uriHttp TEXT)',
        );
      },
      version: 1,
    );

    // Ambil data dari database
    final List<Map<String, dynamic>> maps = await database.query('local_data');
    if (maps.isNotEmpty) {
      return maps.first['uriHttp'];
    } else {
      // Jika tidak ada data, kembalikan string kosong
      return '';
    }
  }

  Future<String?> getRealPath(String? filePath) async {
    if (filePath == null) return null;

    File file = File(filePath);
    return file.path;
  }

  Future<void> _uploadAudio(String audioFilePath) async {
    setState(() {
      loadingText = 'Process Audio...';
    });

    String? realPath = await getRealPath(audioFilePath);
    print('Real Path: $realPath');

    String uri = await _getLocalData();
    print('URI LINK: $uri');

    final url = Uri.parse(uri);
    var request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('audio', audioFilePath));

    try {
      var response = await http.Response.fromStream(await request.send());
      print('process upload...');
      if (response.statusCode == 200) {
        print('Audio uploaded successfully');
        // _deleteAudio(audioFilePath);

        // Reading response from server
        var responseBody = response.body;
        print('Response from server: $responseBody');
        Map<String, dynamic> responseJson = json.decode(responseBody);

        while (message != 'selesai') {
          message = responseJson['message'];
        }

        print(
            '${(_stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(1)} seconds');

        if (message == 'selesai') {
          _stopwatch.stop();

          result = {
            "nama": responseJson['name'].toString(),
            "obat": responseJson['obat'].toString(),
            "saran": responseJson['saran'].toString(),
            "keluhan": responseJson['keluhan'].toString(),
            "penyakit": responseJson['penyakit'].toString(),
            "penggunaan-obat": responseJson['penggunaan-obat'].toString(),
            "durasi-audio": responseJson['audio_duration'].toString(),
            "durasi-proses": (_stopwatch.elapsedMilliseconds / 1000).toString(),
            "rouge": responseJson['scores_rouge'].toString(),
          };

          playNotificationSound();

          PanaraConfirmDialog.show(context,
              message:
                  'proses selesai\n\nApakah ingin menyimpan rekaman?\nRekaman akan tersimpan di recording',
              confirmButtonText: 'simpan',
              cancelButtonText: 'hapus', 
              onTapConfirm: () {
            Navigator.pop(context);
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
                    dataNote: result,
                    newData: true,
                    refId: '',
                  );
                },
              ),
            );
          }, onTapCancel: () {
            Navigator.pop(context);
            _deleteAudio(audioFilePath);
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
                    dataNote: result,
                    newData: true,
                    refId: '',
                  );
                },
              ),
            );
          }, panaraDialogType: PanaraDialogType.success);
        }
      } else {
        if (response.statusCode != 200) {
          // Reading response from server
          var responseBody = response.body;
          print('Response from server: $responseBody');
          Map<String, dynamic> responseJson = json.decode(responseBody);

          print("message : $responseJson['message']");

          showErrorDialog(responseJson['message'], audioFilePath);
        }

        // print('Failed to upload audio. Error: ${response.reasonPhrase}');
        // Navigator.pop(context);
      }
    } on TimeoutException catch (e) {
      print('Request timed out: $e');
      showErrorDialog('$e', audioFilePath);
      // Tambahkan kode penanganan untuk time out di sini
    } catch (e) {
      print('Error : $e');
      showErrorDialog('$e', audioFilePath);
      // Tambahkan kode penanganan untuk kesalahan lain di sini
    }
  }

  void playNotificationSound() async {
    try {
      await player.play(AssetSource('sound/done.mp3'));
    } catch (e) {
      print('Error playing notification sound: $e');
    }
  }

  void showErrorDialog(String responJSOn, String path) {
    PanaraConfirmDialog.show(context,
        message: 'Terjadi Error : ${responJSOn}\n\nRekaman telah disimpan',
        confirmButtonText: 'Kirim ulang',
        cancelButtonText: 'Batal', onTapConfirm: () {
      _uploadAudio(path);
      setState(() {
        loadingText = 'Mengirim ulang...';
      });
      Navigator.pop(context);
    }, onTapCancel: () {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 150),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          pageBuilder: (context, animation, secondaryAnimation) {
            return MenuPage();
          },
        ),
      );
    }, panaraDialogType: PanaraDialogType.error, barrierDismissible: false);
  }

  Future<void> _deleteAudio(String audioFilePath) async {
    setState(() {
      loadingText = 'Delete Audio File';
    });

    await Future.delayed(Duration(seconds: 1), () {});

    try {
      File audioFile = File(audioFilePath);
      await audioFile.delete();
      print('Audio file deleted successfully');
    } catch (e) {
      print('Failed to delete audio file: $e');
    }
  }

  @override
  void initState() {
    _uploadAudio(widget.audioPath);
    _stopwatch.start();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // String timerText = _seconds.toString().padLeft(2, '0');

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
            color: Color.fromARGB(255, 206, 206, 206),
            child: Center(
                child: Column(
              children: [
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Text(
                    'harap tunggu',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                        color: Color(0xFF00295A),
                        fontSize: 24,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Center(
                    child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Color(0xFF005D96)),
                  child: LoadingAnimationWidget.hexagonDots(
                    color: Colors.white,
                    size: 50,
                  ),
                )),
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Text(
                    loadingText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                        color: Color(0xFF00295A),
                        fontSize: 24,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(top: 50, bottom: 25),
                  child: Stack(
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/carenotes-logo-dark.png',
                          scale: 7,
                        ),
                      ),
                      Container(
                        width: widthScreen,
                        height: 50,
                        color: Color.fromARGB(169, 206, 206, 206),
                      ),
                    ],
                  ),
                ),
              ],
            ))),
      ),
    );
  }

  // Future toggleRecording() => SpeechApi.toggleRecording(
  //     onResult: (text) => this._recognizedText = text);

  @override
  void dispose() {
    // _timer.cancel();
    super.dispose();
  }
}
