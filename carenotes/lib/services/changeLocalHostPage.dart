import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ChangeLP extends StatefulWidget {
  const ChangeLP({Key? key}) : super(key: key);

  @override
  State<ChangeLP> createState() => _ChangeLPState();
}

class _ChangeLPState extends State<ChangeLP> {
  final textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk memeriksa dan mengisi nilai TextField dari database lokal
    _checkAndFetchData();
  }

  Future<void> _checkAndFetchData() async {
    String uriHttp = await _getLocalData();
    if (uriHttp.isNotEmpty) {
      setState(() {
        textFieldController.text = uriHttp;
      });
    }
  }

  Future<String> _getLocalData() async {
    // Buka database lokal
    final database = await openDatabase(
      join(await getDatabasesPath(), 'localDB.db'),
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

  Future<void> _saveLocalData(String uriHttp) async {
    // Buka database lokal
    final database = await openDatabase(
      join(await getDatabasesPath(), 'localDB.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE IF NOT EXISTS local_data(id INTEGER PRIMARY KEY, uriHttp TEXT)',
        );
      },
      version: 1,
    );

    // Cek apakah data sudah ada di database
    final List<Map<String, dynamic>> existingData =
        await database.query('local_data');
    if (existingData.isNotEmpty) {
      // Jika data sudah ada, gunakan fungsi _updateLocalData
      await _updateLocalData(uriHttp);
    } else {
      // Jika data belum ada, gunakan fungsi _insertLocalData
      await _insertLocalData(uriHttp);
    }
  }

  Future<void> _insertLocalData(String uriHttp) async {
    // Buka database lokal
    final database = await openDatabase(
      join(await getDatabasesPath(), 'localDB.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE IF NOT EXISTS local_data(id INTEGER PRIMARY KEY, uriHttp TEXT)',
        );
      },
      version: 1,
    );

    // Simpan data baru ke dalam database
    await database.insert(
      'local_data',
      {'uriHttp': uriHttp},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Cetak pesan berhasil
    print('Data berhasil disimpan');

    // Perbarui state dengan nilai yang baru
    setState(() {
      textFieldController.text = uriHttp;
    });
  }

  Future<void> _updateLocalData(String uriHttp) async {
    // Buka database lokal
    final database = await openDatabase(
      join(await getDatabasesPath(), 'localDB.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE IF NOT EXISTS local_data(id INTEGER PRIMARY KEY, uriHttp TEXT)',
        );
      },
      version: 1,
    );

    // Perbarui data di database
    await database.update(
      'local_data',
      {'uriHttp': uriHttp},
      where: 'id = ?',
      whereArgs: [1], // Ubah sesuai dengan id yang sesuai
    );

    // Cetak pesan berhasil
    print('Data berhasil diperbarui');

    // Perbarui state dengan nilai yang baru
    setState(() {
      textFieldController.text = uriHttp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              child: TextField(
                controller: textFieldController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await _saveLocalData(textFieldController.text);
            },
            child: Text('Change'),
          ),
          ElevatedButton(
            onPressed: () async {
              String data = await _getLocalData();
              print('Data dari database lokal: $data');
            },
            child: Text('get'),
          )
        ],
      ),
    );
  }
}
