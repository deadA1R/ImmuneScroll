import 'dart:math';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:sqflite/sqflite.dart';
import 'package:immune_scroll/upload.dart';


class VideoPlayerPage extends StatefulWidget {
  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? _controller;
  final List<Map<String, dynamic>> videosList = [
    {'path': 'assets/videos/video1.mp4', 'tag': 'peoples'},
    {'path': 'assets/videos/video2.mp4', 'tag': 'animals'},
    {'path': 'assets/videos/video3.mp4', 'tag': 'peoples'},
    {'path': 'assets/videos/video4.mp4', 'tag': 'ai'},
  ];

  final random = Random();
  int videoIndex = 0;
  List<String> excludedTags = [];

   @override
  void initState() {
    super.initState();
    videoIndex = random.nextInt(videosList.length);
    _initializeVideo(videoIndex);
  }

  void _initializeVideo(int videoIndex) {
    if (excludedTags.contains(videosList[videoIndex]['tag'])) {
      return;
    }
    _controller = VideoPlayerController.asset(videosList[videoIndex]['path'])
      ..initialize().then((_) {
        setState(() {});
        _controller!.addListener(checkIfVideoFinished);
        _controller!.play();
      });
  }

  void checkIfVideoFinished() {
    if (_controller!.value.position == _controller!.value.duration) {
      nextVideo();
    }
  }

  void nextVideo() {
    do {
      videoIndex++;
      if (videoIndex >= videosList.length) {
        videoIndex = 0;
      }
    } while (excludedTags.contains(videosList[videoIndex]['tag']));
    changeVideo(videoIndex);
  }

  void changeVideo(int videoIndex) {
    _controller!.removeListener(checkIfVideoFinished);
    _controller!.pause();
    _initializeVideo(videoIndex);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String tag) {
              setState(() {
                if (excludedTags.contains(tag)) {
                  excludedTags.remove(tag);
                } else {
                  excludedTags.add(tag);
                }
              });
            },
            itemBuilder: (BuildContext context) {
              return videosList.map((video) => video['tag']).toSet().map((tag) {
                return PopupMenuItem<String>(
                  value: tag,
                  child: Row(
                    children: <Widget>[
                      Checkbox(
                        value: !excludedTags.contains(tag),
                        onChanged: null,
                      ),
                      Text(tag),
                    ],
                  ),
                );
              }).toList();
            },
          ),
          IconButton(
            icon: Icon(Icons.file_upload),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UploadVideoPage()),
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            nextVideo();
          }
        },
        child: Center(
          child: _controller != null && _controller!.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                )
              : Container(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller!.value.isPlaying
                ? _controller!.pause()
                : _controller!.play();
          });
        },
        child: Icon(
          _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }
}
