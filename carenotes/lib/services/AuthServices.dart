import 'dart:async';

import 'package:carenotes/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

class AuthManager {
  Stream<List<Map<String, dynamic>>> notesStream = Stream.empty();

  Future<bool> signUp(String password, String confirmPassword, String email,
      String name) async {
    if (password == confirmPassword) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        String userId = FirebaseAuth.instance.currentUser!.uid;
        await addUserDetails(userId, name);
        return true;
      } catch (e) {
        print("Error during sign up: $e");
        return false;
      }
    } else {
      print('password not same');
      return false;
    }
  }

  Future addUserDetails(String userId, String name) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'name': name,
    });
  }

  Future<bool> signIn(
      BuildContext context, String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Wrapper()));
      return true;
    } catch (error) {
      PanaraInfoDialog.showAnimatedFromBottom(context,
          message:
              'Terjadi kesalahan saat masuk. Mohon periksa kembali email dan password Anda.',
          buttonText: 'oke', onTapDismiss: () {
        Navigator.pop(context);
      }, panaraDialogType: PanaraDialogType.error);
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userInfo = userSnapshot.data()!;
        // Dapatkan email pengguna dari FirebaseAuth
        userInfo['email'] = FirebaseAuth.instance.currentUser!.email;
        return userInfo;
      } else {
        print("Informasi pengguna tidak ditemukan.");
        return null;
      }
    } catch (e) {
      print("Error fetching user info: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchNoteByRefId(String refId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot<Map<String, dynamic>> noteSnapshot =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .collection("notes")
              .doc(refId)
              .get();

      if (noteSnapshot.exists) {
        return noteSnapshot.data();
      } else {
        print("Dokumen dengan ID $refId tidak ditemukan.");
        return null;
      }
    } catch (e) {
      print("Error fetching note: $e");
      return null;
    }
  }

  void fetchNotes() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    notesStream = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notes')
        .orderBy('date',
            descending: true) // Misalnya, diurutkan berdasarkan waktu pembuatan
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<String?> fetchNoteIdByDate(String date) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      QuerySnapshot<Map<String, dynamic>> noteSnapshots =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .collection("notes")
              .where("date", isEqualTo: date)
              .get();

      if (noteSnapshots.docs.isNotEmpty) {
        // Mengambil ID dokumen dari dokumen pertama yang ditemukan dan mengembalikannya
        return noteSnapshots.docs.firstOrNull?.id;
      } else {
        print("Tidak ada dokumen dengan tanggal $date.");
        return null;
      }
    } catch (e) {
      print("Error fetching note ID: $e");
      return null;
    }
  }

  Future<String?> getLastNoteId() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      var querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("notes")
          .orderBy("date",
              descending: true) // Urutkan berdasarkan timestamp secara menurun
          .limit(1) // Batasi hasil hanya satu dokumen
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var lastDocId = querySnapshot.docs.first.id;
        return lastDocId;
      } else {
        print("No notes found.");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  static Future<void> addNote(
      BuildContext context, Map<String, dynamic> summaNote) async {
    if (summaNote.isNotEmpty) {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('notes')
            .add(summaNote);

        var snackBar = SnackBar(content: Text('Berhasil menyimpan catatan'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        Navigator.pop(context);
      } catch (e) {
        print("Error adding note: $e");
        var snackBar = SnackBar(content: Text('Gagal menyimpan'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      print('summaNote is empty');
    }
  }

  Future<bool> updateNoteByRefId(
      String refId, Map<String, dynamic> summaNote) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("notes")
          .doc(refId)
          .update(summaNote);
      print("Note with ID $refId updated successfully.");
      return true; // Pembaruan berhasil
    } catch (e) {
      print("Error updating note: $e");
      return false; // Pembaruan gagal
    }
  }

  Future<bool> deleteNoteByRefId(String refId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("notes")
          .doc(refId)
          .delete();
      print("Note with ID $refId deleted successfully.");
      return true; // Penghapusan berhasil
    } catch (e) {
      print("Error deleting note: $e");
      return false; // Penghapusan gagal
    }
  }

  void searchNotes(String query) {
    final userId = FirebaseAuth.instance.currentUser!.uid;


    if (query.isEmpty) {
      notesStream = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notes')
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList());
    } else {
      String title = query.trim();

      Query querySnapshot = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notes')
          .where('title', isGreaterThanOrEqualTo: title)
          .where('title', isLessThanOrEqualTo: title + '\uf8ff');

      notesStream = querySnapshot.snapshots().map((snapshot) => snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList());
    }
  }

  Stream<List<Map<String, dynamic>>> getNotesStream() {
    return notesStream;
  }

  Future<bool> updateNoteTitleByRefId(String refId, String newTitle) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("notes")
          .doc(refId)
          .update({'title': newTitle});
      print("Title of note with ID $refId updated successfully.");
      return true; // Pembaruan berhasil
    } catch (e) {
      print("Error updating note title: $e");
      return false; // Pembaruan gagal
    }
  }
}
