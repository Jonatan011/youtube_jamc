import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:youtube_jamc/features/controllers/home_controller.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerScreen extends StatefulWidget {
  final List<String> ids;

  const VideoPlayerScreen({super.key, required this.ids});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  late TextEditingController _idController;
  late TextEditingController _seekToController;

  late YoutubeMetaData _videoMetaData;
  double _volume = 100;
  bool _muted = false;
  bool _isPlayerReady = false;
  final HomeController homeController = Get.find();
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    try {
      _controller = YoutubePlayerController(
        initialVideoId: widget.ids.isNotEmpty ? widget.ids.first : "",
        flags: const YoutubePlayerFlags(
          mute: false,
          autoPlay: true,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: true,
        ),
      )..addListener(listener);
      _idController = TextEditingController();
      _seekToController = TextEditingController();
      _videoMetaData = const YoutubeMetaData();
    } catch (e) {
      print(e);
    }
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _videoMetaData = _controller.metadata;
      });
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    _idController.dispose();
    _seekToController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant VideoPlayerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ids != widget.ids && widget.ids.isNotEmpty) {
      _controller.load(widget.ids[0]);
    }
  }

  void _togglePlayerSize() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeController.isPlayerMinimizedOrMaximixed(!homeController.isPlayerMinimized.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: !homeController.isPlayerMinimized.value
              ? AppBar(
                  backgroundColor: Colors.black,
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Image.asset('assets/image/youtube_logo.png', fit: BoxFit.fitWidth),
                  ),
                  title: const Text('Youtube Player Flutter', style: TextStyle(color: Colors.white)),
                )
              : AppBar(
                  backgroundColor: Colors.black,
                  toolbarHeight: 60,
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black, Colors.grey.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                            child: TextButton(
                          onPressed: () {
                            homeController.isPlayerMinimizedOrMaximixed(false);
                          },
                          child: Text(
                            _controller.metadata.title,
                            style: const TextStyle(color: Colors.white, fontSize: 16.0), // Tamaño de fuente aumentado
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        )),
                        IconButton(
                          icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                          onPressed: _isPlayerReady
                              ? () {
                                  _controller.value.isPlaying ? _controller.pause() : _controller.play();
                                  setState(() {});
                                }
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              homeController.isPlayerFinish.value = true;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
          body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: YoutubePlayerBuilder(
                onExitFullScreen: () {
                  SystemChrome.setPreferredOrientations(DeviceOrientation.values);
                },
                player: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.blueAccent,
                  topActions: <Widget>[
                    Stack(
                      children: [
                        Positioned(
                          child: IconButton(
                            icon: Icon(
                              homeController.isPlayerMinimized.value ? Icons.expand : Icons.minimize,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: _togglePlayerSize,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        _controller.metadata.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 25.0,
                      ),
                      onPressed: () {
                        log('Settings Tapped!');
                      },
                    ),
                  ],
                  onReady: () {
                    _isPlayerReady = true;
                  },
                  onEnded: (data) {
                    _controller.load(widget.ids[(widget.ids.indexOf(data.videoId) + 1) % widget.ids.length]);
                    // _showSnackBar('Next Video Started!');
                  },
                ),
                builder: (context, player) => _buildFullPlayer(player),
              )),
        ),
      ),
    );
  }

  Widget _buildFullPlayer(Widget player) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: ListView(
          children: [
            SizedBox(height: homeController.isPlayerMinimized.value ? 40 : null, child: player),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _space,
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 15,
                    child: _text('Titulo', _videoMetaData.title),
                  ),
                  _space,
                  _text('Autor', _videoMetaData.author),
                  _space,
                  _text('Duración', _videoMetaData.duration.toString()),
                  _space,
                  /* Row(
                    children: [
                      _text(
                        'Playback Quality',
                        _controller.value.playbackQuality ?? '',
                      ),
                      const Spacer(),
                      _text(
                        'Playback Rate',
                        '${_controller.value.playbackRate}x  ',
                      ),
                    ],
                  ),*/
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous, color: Colors.white),
                        onPressed: _isPlayerReady
                            ? () => _controller.load(widget.ids[(widget.ids.indexOf(_controller.metadata.videoId) - 1) % widget.ids.length])
                            : null,
                      ),
                      IconButton(
                        icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                        onPressed: _isPlayerReady
                            ? () {
                                _controller.value.isPlaying ? _controller.pause() : _controller.play();
                                setState(() {});
                              }
                            : null,
                      ),
                      IconButton(
                        icon: Icon(_muted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
                        onPressed: _isPlayerReady
                            ? () {
                                _muted ? _controller.unMute() : _controller.mute();
                                setState(() {
                                  _muted = !_muted;
                                });
                              }
                            : null,
                      ),
                      FullScreenButton(
                        controller: _controller,
                        color: Colors.blueAccent,
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next, color: Colors.white),
                        onPressed: _isPlayerReady
                            ? () => _controller.load(widget.ids[(widget.ids.indexOf(_controller.metadata.videoId) + 1) % widget.ids.length])
                            : null,
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      const Text(
                        "Volumen",
                        style: TextStyle(fontWeight: FontWeight.w400, color: Colors.white),
                      ),
                      Expanded(
                        child: Slider(
                          inactiveColor: Colors.transparent,
                          activeColor: Colors.white,
                          value: _volume,
                          min: 0.0,
                          max: 100.0,
                          divisions: 10,
                          label: '${(_volume).round()}',
                          onChanged: _isPlayerReady
                              ? (value) {
                                  setState(() {
                                    _volume = value;
                                  });
                                  _controller.setVolume(_volume.round());
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _text(String title, String value) {
    return RichText(
      text: TextSpan(
        text: '$title : ',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget get _space => const SizedBox(height: 10);
}
