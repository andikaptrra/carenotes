import 'package:carenotes/screens/mainPages/LoadingPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:io';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  final record = AudioRecorder();
  bool isRecorderReady = false;
  bool isRecording = false;
  String _path = "";
  String _filePath = "";
  int _seconds = 0;
  Timer? _timer;
  String statusRecorder = 'Perekaman Siap';

  Future<void> _openFilePicker() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result != null) {
        if (result.files.single.extension == 'wav') {
          setState(() {
            _filePath = result.files.single.path!;
            print(_filePath);

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
                  return LoadingPage(audioPath: _filePath);
                },
              ),
            );
          });
        } else {
          // Handle error when file format is not WAV
          PanaraInfoDialog.showAnimatedFromBottom(
            context,
            message: 'format audio harus wav',
            buttonText: 'oke',
            onTapDismiss: () {
              Navigator.pop(context);
            },
            panaraDialogType: PanaraDialogType.normal);
        }
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  @override
  void initState() {
    initRecorder();
    setPermission();
    super.initState();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    record.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void setPermission() async {
    await Permission.manageExternalStorage.request();
    await Permission.storage.request();
  }

  final recorder = FlutterSoundRecorder();

  Future initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Permission not granted';
    }
    await recorder.openRecorder();
    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  Future startRecord() async {
    startTimer();

    DateTime now = DateTime.now();
    String formattedDate =
        '${now.year}-${now.month}-${now.day}_${now.hour}-${now.minute}-${now.second}';

    String filePath = '/storage/emulated/0/recordings/audio_$formattedDate.wav';

    await record.start(
        const RecordConfig(
            noiseSuppress: true,
            encoder: AudioEncoder.wav,
            bitRate: 320000,
            sampleRate: 44100),
        path: filePath);

    setState(() {
      isRecording = true;
      statusRecorder = 'Mendengarkan...';
    });
  }

  Future<void> stopRecorder() async {
    final filePath = await recorder.stopRecorder();

    if (filePath == null) {
      print('Recording failed or was not started.');
      return;
    }

    final recordingsDirectory = Directory('/storage/emulated/0/recordings');
    if (!await recordingsDirectory.exists()) {
      await recordingsDirectory.create(
          recursive: true); // Buat direktori jika belum ada
    }

    _path = (await record.stop())!;
    setState(() {
      _seconds = 0;
      statusRecorder = 'Rekaman berhenti';
      isRecording = false;
    });

    stopTimer();

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
          return LoadingPage(audioPath: _path);
        },
      ),
    );
  }

  Future<void> startTimer() async {
    const oneSecond = Duration(seconds: 1);
    _timer = Timer.periodic(oneSecond, (Timer timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  String _getTimerText(int seconds) {
    int hours = seconds ~/ 3600;
    int remainingSeconds = seconds % 3600;
    int minutes = remainingSeconds ~/ 60;
    int remainingMinutes = remainingSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}';
  }

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
                child: Column(
              children: [
                Opacity(
                  opacity: 0.3,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Image.asset(
                      'assets/images/carenotes-logo.png',
                      scale: 7,
                    ),
                  ),
                ),
                Spacer(),
                Text(
                  statusRecorder,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                      color: Colors.white, fontSize: 24),
                ),
                SizedBox(
                  height: 10,
                ),
                Spacer(),
                Container(
                  height: availableHeight * 0.5,
                  width: widthScreen,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(1000),
                        topRight: Radius.circular(1000)),
                    color: Color(0xFFD9D9D9),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 25),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1000),
                              color: Color(0xFF005D96),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: Offset(0, 3))
                              ]),
                          child: Center(
                            child: Icon(
                              Icons.mic_none_rounded,
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            color: Color(0xFF00295A),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: _getTimerText(_seconds),
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Batal',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18),
                            ),
                            style: ElevatedButton.styleFrom(
                                fixedSize: const Size(100, 15),
                                backgroundColor: Color(0xFF021E3F),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50))),
                          ),
                          Spacer(),
                          ElevatedButton(
                            onPressed: () async {
                              if (isRecording) {
                                stopRecorder();
                              } else {
                                startRecord();
                              }

                              setState(() {});
                            },
                            child: Text(
                              isRecording ? 'Stop' : 'Start',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                                fixedSize: const Size(100, 15),
                                backgroundColor: Color(0xFF021E3F),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50))),
                          ),
                          Spacer(),
                          ElevatedButton(
                            onPressed: () async {
                              _openFilePicker();
                            },
                            child: Text(
                              'folder',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                                fixedSize: const Size(100, 15),
                                backgroundColor: Color(0xFF021E3F),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50))),
                          ),
                          Spacer()
                        ],
                      ),
                      Spacer(),
                    ],
                  ),
                )
              ],
            ))),
      ),
    );
  }
}
