import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

class UploadVideoPage extends StatefulWidget {
  @override
  _UploadVideoPageState createState() => _UploadVideoPageState();
}

class _UploadVideoPageState extends State<UploadVideoPage> {
  File? _video;
  final picker = ImagePicker();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController tagController = TextEditingController();

  Future getVideo() async {
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _video = File(pickedFile.path);
      } else {
        print('No video selected.');
      }
    });
  }

  Future uploadVideoToSQLite() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'demo.db');

    // open the database
    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          'CREATE TABLE Videos (id INTEGER PRIMARY KEY, title TEXT, tag TEXT, video BLOB)');
    });

    List<int> videoBytes = await _video!.readAsBytesSync();

    // Insert some records in a transaction
    await database.transaction((txn) async {
      int id = await txn.rawInsert(
          'INSERT INTO Videos(title, tag, video) VALUES(?, ?, ?)',
          [titleController.text, tagController.text, videoBytes]);
      print('inserted: $id');
    });

    await database.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Video'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Enter video title"),
            ),
            TextField(
              controller: tagController,
              decoration: InputDecoration(labelText: "Enter video tag"),
            ),
            _video == null
                ? Text('No video selected.')
                : Image.file(_video!),
            ElevatedButton(
              child: Text('Select Video'),
              onPressed: getVideo,
            ),
            ElevatedButton(
              child: Text('Upload Video'),
              onPressed: () {
                uploadVideoToSQLite();
                titleController.clear();
                tagController.clear();
              },
            ),
          ],
        ),
      ),
    );
  }
}
