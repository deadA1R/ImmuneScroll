import 'package:flutter/material.dart';
import 'package:immune_scroll/upload.dart';
import 'package:immune_scroll/main_page.dart';




void main() => runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primaryColor: const Color.fromARGB(255, 15, 23, 105),

    ),
    initialRoute: '/main_page',
    routes: {
      '/upload_page': (context) => UploadVideoPage(),
      '/main_page': (context) => VideoPlayerPage(),
    }
));
