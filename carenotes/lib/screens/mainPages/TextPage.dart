import 'package:carenotes/screens/mainPages/MenuPage.dart';
import 'package:carenotes/services/AuthServices.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:intl/intl.dart';

class TextPage extends StatefulWidget {
  final Map<String, dynamic> dataNote;
  final bool newData;
  final String refId;
  const TextPage(
      {Key? key,
      required this.dataNote,
      required this.newData,
      required this.refId})
      : super(key: key);

  @override
  State<TextPage> createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  HtmlEditorController _htmlController = HtmlEditorController();
  TextEditingController _titleController = TextEditingController();
  String noteText = '';
  late String _idRef = '';

  bool thisNewData = false;

  final AuthManager _authManager = AuthManager();

  Future<String> _getControllerHtmlText() async {
    String text = await _htmlController.getText();
    return text;
  }

  String formatDuration(dynamic durationData) {
    if (durationData is double) {
      return durationData.toStringAsFixed(2);
    } else if (durationData is String) {
      double duration = double.tryParse(durationData) ?? 0.0;
      return duration.toStringAsFixed(2);
    } else {
      return '0.00';
    }
  }

  void _firstCheck() async {
    if (thisNewData && widget.dataNote.isNotEmpty) {
      Map<String, dynamic> allData = {};
      allData.addAll(widget.dataNote);

      String _name = allData['nama'].toString();
      String _obat = allData['obat'].toString();
      String _saran = allData['saran'].toString();
      String _keluhan = allData['keluhan'].toString();
      String _penyakit = allData['penyakit'].toString();
      String _penggunaanObat = allData['penggunaan-obat'].toString();
      String _rouge = allData['rouge'].toString();

      print('--------------------------------------');
      print('name : ' + _name);
      print('obat : ' + _obat);
      print('saran : ' + _saran);
      print('keluahan : ' + _keluhan);
      print('penggunaan obat : ' + _penggunaanObat);
      print('rouge : ' + _rouge);
      print('--------------------------------------');

      String _audioDuration = formatDuration(allData['durasi-audio']);
      String _processDuration = formatDuration(allData['durasi-proses']);

      DateTime now = DateTime.now();
      String formattedDateText = DateFormat('MMMM dd, yyyy').format(now);

      String _textSumma = '''
      <h1><font color="#ffebee">Hasil Rangkuman</font></h1>
      <p><strong style=""><font color="#5c6bc0">${formattedDateText}</font></strong></p>
      <p><strong style=""><font color="#64b5f6">nama :</font>&nbsp;</strong><span style="color: rgb(255, 235, 238);">${_name}</span></p>
      <p><strong style=""><font color="#64b5f6">obat :</font>&nbsp;</strong><span style="color: rgb(255, 235, 238);">${_obat}</span></p>
      <p><strong style=""><font color="#64b5f6">Rekomendasi :</font>&nbsp;</strong><span style="color: rgb(255, 235, 238);">${_saran}</span></p>
      <p><strong style=""><font color="#64b5f6">Keluhan :</font>&nbsp;</strong><span style="color: rgb(255, 235, 238);">${_keluhan}</span></p>
      <p><strong style=""><font color="#4fc3f7">Nama penyakit :</font>&nbsp;</strong><span style="color: rgb(255, 235, 238);">${_penyakit}</span></p>
      <p><strong style=""><font color="#64b5f6">Penggunaan obat:</font>&nbsp;</strong><span style="color: rgb(255, 235, 238);">${_penggunaanObat}</span></p>
      ''';
      setState(() {
        noteText = _textSumma;
      });

      _showDialogSave(_textSumma, _rouge, _audioDuration, _processDuration);
    } else if (thisNewData == false) {
      setState(() {
        noteText = widget.dataNote['note'];
      });
    }
  }

  void _showDialogSave(String noteText, String rouge, String audioDuration,
      String processDuration) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(child: Text('Menyimpan catatan')),
            content: Container(
              height: 80,
              child: Column(
                children: [
                  Text('Masukan judul catatan'),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      fillColor: Colors.green,
                    ),
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () async {
                    Map<String, dynamic> _summaNote = {};

                    if (widget.dataNote.isNotEmpty) {
                      // memasukan teks hasil perangkuman otomatis

                      _summaNote = {
                        "message": 'auto',
                        "title": _titleController.text,
                        "note": noteText,
                        "audio_duration": audioDuration,
                        "process_time": processDuration,
                        "score": rouge,
                        "date": DateFormat('dd-MM-yyyy HH:mm:ss')
                            .format(DateTime.now())
                      };
                    } else {
                      // memasukan teks hasil perangkuman manual
                      _summaNote = {
                        "message": 'manually',
                        "title": _titleController.text,
                        "note": noteText,
                        "audio_duration": '-',
                        "process_time": '-',
                        "score": {},
                        "date": DateFormat('dd-MM-yyyy HH:mm:ss')
                            .format(DateTime.now())
                      };
                    }

                    setState(() {
                      noteText = noteText;
                    });

                    thisNewData = false;

                    AuthManager.addNote(context, _summaNote);

                    // _authManager.fetchNotes();

                    // setState(() {
                    //   noteText =
                    // });
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    thisNewData = widget.newData;
    _idRef = widget.refId;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _firstCheck();
      if (_idRef.isEmpty) {
        String? lastNoteId = await _authManager.getLastNoteId();
        setState(() {
          _idRef = lastNoteId ?? '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double heightScreen = MediaQuery.of(context).size.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double widthScreen = MediaQuery.of(context).size.width;

    double availableHeight = heightScreen - statusBarHeight;

    return WillPopScope(
      onWillPop: () async {
        return false; // Return false to prevent the default back action
      },
      child: Scaffold(
          body: Padding(
        padding: EdgeInsets.only(top: statusBarHeight),
        child: Column(
          children: [
            Column(
              children: [
                Container(
                  height: heightScreen * 0.07,
                  width: widthScreen,
                  color: Color.fromARGB(255, 4, 71, 153),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            GestureDetector(
                              child: Icon(
                                Icons.arrow_back_ios_rounded,
                                color: Color.fromARGB(255, 255, 255, 255),
                                size: heightScreen * 0.04,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MenuPage()),
                                );
                              },
                            ),
                            Text(
                              'Notes',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 250, 250, 250)),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            child: Icon(Icons.info_outline_rounded,
                                color: Color.fromARGB(255, 16, 161, 10),
                                size: heightScreen * 0.04),
                            onTap: () async {
                              Map<String, dynamic>? _noteDataFromDatabase =
                                  await _authManager.fetchNoteByRefId(_idRef);
                              String tanggal = '';
                              String durasiAudio = '';
                              String durasiProses = '';

                              if (_noteDataFromDatabase!.isNotEmpty) {
                                tanggal = _noteDataFromDatabase['date'];
                                durasiAudio =
                                    _noteDataFromDatabase['audio_duration'];
                                durasiProses =
                                    _noteDataFromDatabase['process_time'];
                              } else {
                                tanggal = '-';
                                durasiAudio = '-';
                                durasiProses = '-';
                              }

                              PanaraInfoDialog.showAnimatedFromBottom(context,
                                  title: 'Rangkuman Konsultasi',
                                  message:
                                      'tanggal : ${tanggal}\ndurasi audio : ${durasiAudio}\ntotal waktu proses : ${durasiProses}',
                                  buttonText: 'Oke', onTapDismiss: () {
                                Navigator.pop(context);
                              }, panaraDialogType: PanaraDialogType.normal);
                            },
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          GestureDetector(
                            child: Icon(Icons.save_outlined,
                                color: Color.fromARGB(255, 161, 151, 10),
                                size: heightScreen * 0.04),
                            onTap: () async {
                              String htmlText = await _getControllerHtmlText();
                              if (thisNewData == false) {
                                Map<String, dynamic>? _noteDataFromDatabase =
                                    await _authManager.fetchNoteByRefId(_idRef);

                                if (_noteDataFromDatabase != null) {
                                  String noteText =
                                      _noteDataFromDatabase["note"];
                                  print("Isi catatan: $noteText");

                                  if (noteText != htmlText) {
                                    // save
                                    Map<String, dynamic> summaNoteUpdate = {
                                      "message":
                                          _noteDataFromDatabase["message"],
                                      "title": _noteDataFromDatabase["title"],
                                      "note": htmlText,
                                      "audio_duration": _noteDataFromDatabase[
                                          "audio_duration"],
                                      "process_time":
                                          _noteDataFromDatabase["process_time"],
                                      "score": _noteDataFromDatabase["score"],
                                      "date": _noteDataFromDatabase["date"]
                                    };

                                    bool isUpdated =
                                        await _authManager.updateNoteByRefId(
                                            _idRef, summaNoteUpdate);

                                    String textMessage = '';

                                    if (isUpdated) {
                                      print("Note berhasil diperbarui.");
                                      textMessage =
                                          'Catatan berhasil diperbarui.';
                                    } else {
                                      print("Gagal memperbarui catatan.");
                                      textMessage =
                                          'Gagal memperbarui catatan.';
                                    }

                                    PanaraInfoDialog.showAnimatedFromBottom(
                                        context,
                                        message: textMessage,
                                        buttonText: 'ok', onTapDismiss: () {
                                      Navigator.pop(context);
                                    },
                                        panaraDialogType:
                                            PanaraDialogType.normal);
                                  }
                                }
                              } else {
                                _showDialogSave(htmlText, '', '', '');
                              }
                            },
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          GestureDetector(
                            child: Icon(Icons.delete_outline_rounded,
                                color: Color.fromARGB(255, 161, 10, 10),
                                size: heightScreen * 0.04),
                            onTap: () async {
                              Map<String, dynamic>? _noteDataFromDatabase =
                                  await _authManager.fetchNoteByRefId(_idRef);
                              String name = '';
                              if (_noteDataFromDatabase!.isNotEmpty) {
                                name = _noteDataFromDatabase['title'];
                              } else {
                                name = '-';
                              }

                              PanaraConfirmDialog.showAnimatedFromBottom(
                                context,
                                panaraDialogType: PanaraDialogType.warning,
                                title: 'Are you sure',
                                message: 'to delete ${name}',
                                confirmButtonText: 'Yes',
                                cancelButtonText: 'No',
                                onTapConfirm: () async {
                                  String refId = _idRef;
                                  bool isDeleted = await _authManager
                                      .deleteNoteByRefId(refId);
                                  if (isDeleted) {
                                    print("Note berhasil dihapus.");
                                  } else {
                                    print("Gagal menghapus catatan.");
                                  }

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
                                      pageBuilder: (context, animation,
                                          secondaryAnimation) {
                                        return MenuPage();
                                      },
                                    ),
                                  );
                                },
                                onTapCancel: () {
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
                child: Container(
              color: Color.fromARGB(255, 4, 71, 153),
              child: HtmlEditor(
                controller: _htmlController,
                htmlToolbarOptions: HtmlToolbarOptions(
                  toolbarPosition: ToolbarPosition.belowEditor,
                  toolbarType: ToolbarType.nativeExpandable,
                  textStyle: TextStyle(color: Colors.white),
                  buttonColor: Colors.white,
                  buttonSelectedColor: Color.fromARGB(255, 133, 125, 247),
                  dropdownBackgroundColor: Color.fromARGB(255, 3, 54, 117),
                  defaultToolbarButtons: const [
                    StyleButtons(),
                    FontSettingButtons(
                        fontName: true, fontSize: true, fontSizeUnit: true),
                    FontButtons(
                        bold: true,
                        italic: true,
                        underline: true,
                        clearAll: false,
                        strikethrough: false,
                        superscript: false,
                        subscript: false),
                    ColorButtons(foregroundColor: true, highlightColor: true),
                    ListButtons(ul: true, ol: true, listStyles: false),
                    ParagraphButtons(
                        alignCenter: true,
                        alignJustify: true,
                        alignLeft: true,
                        alignRight: true,
                        increaseIndent: false,
                        decreaseIndent: false,
                        caseConverter: false),
                    InsertButtons(
                        link: false,
                        picture: false,
                        audio: false,
                        video: false,
                        table: false,
                        otherFile: false,
                        hr: false)
                  ],
                ),
                htmlEditorOptions: HtmlEditorOptions(
                    hint: 'Ketik di sini..', initialText: noteText),
                otherOptions: OtherOptions(
                  height: availableHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    border: Border.fromBorderSide(
                      BorderSide(
                          color: Color.fromARGB(255, 4, 71, 153),
                          width: 1), // Ganti warna border menjadi biru
                    ),
                  ),
                ),
              ),
            ))
          ],
        ),
      )),
    );
  }
}
