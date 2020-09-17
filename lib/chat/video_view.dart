import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  VideoView({
    this.videoToPlay = "",
    this.videoFromWebToPlay = ""});

  final String videoToPlay;
  final String videoFromWebToPlay;

  @override
  _VideoViewState createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.videoFromWebToPlay != null && widget.videoFromWebToPlay.isNotEmpty) {
      _controller = VideoPlayerController.network(widget.videoFromWebToPlay);
    } else if (widget.videoToPlay != null && widget.videoToPlay.isNotEmpty) {
      _controller = VideoPlayerController.file(File(widget.videoToPlay));
    }
    _controller?.addListener(() {
      setState(() {});
    });
    if (_controller?.value?.initialized == false) {
      _controller.initialize().then((_) {
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || _controller?.value?.hasError == true) {
      return Center(
        child: Text(_controller?.value?.errorDescription ?? ""),
      );
    }
    if (!_controller.value.initialized) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Container(
        color: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 8,
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(alignment: Alignment.bottomCenter, children: [
                  VideoPlayer(_controller),
                  _PlayPauseOverlay(controller: _controller),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                ]),
              ),
            ),
          ],
        ),
      );
    }
  }
}

class _PlayPauseOverlay extends StatefulWidget {
  const _PlayPauseOverlay({Key key, this.controller}) : super(key: key);

  final VideoPlayerController controller;

  @override
  _PlayPauseOverlayState createState() => _PlayPauseOverlayState();
}

class _PlayPauseOverlayState extends State<_PlayPauseOverlay> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: widget.controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            widget.controller.value.isPlaying
                ? widget.controller.pause()
                : widget.controller.play();
          },
        ),
      ],
    );
  }
}
