import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerView extends StatefulWidget {
  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  VideoPlayerController? _videoPlayerController;

  ChewieController? _chewieController;

  @override
  void initState() {
    _videoPlayerController = VideoPlayerController.network(
        'https://drive.google.com/uc?export=download&id=1I76mtOh_fSs-Oo4pfv9fK6xSifChtMkF');

    _chewieController = ChewieController(
      allowedScreenSleep: false,
      allowFullScreen: true,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
      videoPlayerController: _videoPlayerController!,
      aspectRatio: 9 / 18,
      autoInitialize: true,
      autoPlay: true,
      showControls: true,
    );
    _chewieController!.addListener(() {
      if (_chewieController!.isFullScreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(toolbarHeight: 0),
      body: SafeArea(
        top: false,
        child: Container(
          child: Chewie(
            controller: _chewieController!,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController!.dispose();
    _chewieController!.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}
