import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chewie Video Player Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const VideoFeedPage(),
    );
  }
}

class VideoFeedPage extends StatefulWidget {
  const VideoFeedPage({super.key});

  @override
  State<VideoFeedPage> createState() => _VideoFeedPageState();
}

class _VideoFeedPageState extends State<VideoFeedPage> {
  final PageController _pageController = PageController();
  final ValueNotifier<double> _progressNotifier = ValueNotifier<double>(0.0);
  Function(double)? _seekCallback;
  final List<String> _videoUrls = [
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _progressNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _videoUrls.length,
            itemBuilder: (context, index) {
              return VideoPlayerWidget(
                videoUrl: _videoUrls[index],
                index: index,
                progressNotifier: _progressNotifier,
                onSeekCallbackReady: (callback) {
                  _seekCallback = callback;
                },
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 63,
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar on navbar
            _buildProgressBar(),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home, true),
                  _buildNavItem(Icons.search, false),
                  _buildNavItem(Icons.add_box_outlined, false),
                  _buildNavItem(Icons.favorite_border, false),
                  _buildNavItem(Icons.person_outline, false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return ValueListenableBuilder<double>(
      valueListenable: _progressNotifier,
      builder: (context, progress, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                if (_seekCallback != null) {
                  final seekRatio = (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
                  _seekCallback!(seekRatio);
                }
              },
              onHorizontalDragUpdate: (details) {
                if (_seekCallback != null) {
                  final seekRatio = (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
                  _seekCallback!(seekRatio);
                }
              },
              child: Container(
                height: 12,
                width: double.infinity,
                color: Colors.transparent,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 5,
                      margin: const EdgeInsets.symmetric(vertical: 3.5),
                      color: Colors.white.withOpacity(0.3),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        height: 5,
                        margin: const EdgeInsets.symmetric(vertical: 3.5),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNavItem(IconData icon, bool isSelected) {
    return Icon(
      icon,
      color: isSelected ? Colors.white : Colors.grey[600],
      size: 28,
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final int index;
  final ValueNotifier<double> progressNotifier;
  final Function(Function(double)) onSeekCallbackReady;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.index,
    required this.progressNotifier,
    required this.onSeekCallbackReady,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _isLiked = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await _videoPlayerController!.initialize();

      if (!mounted) return;

      _videoPlayerController!.addListener(_videoListener);

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: true,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        autoInitialize: true,
        showControls: false,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Video Error',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      );

      // Register seek callback
      widget.onSeekCallbackReady((double seekRatio) async {
        if (_videoPlayerController != null) {
          final duration = _videoPlayerController!.value.duration;
          if (duration.inMilliseconds > 0) {
            final wasPlaying = _videoPlayerController!.value.isPlaying;
            final seekPosition = Duration(
              milliseconds: (seekRatio * duration.inMilliseconds).round(),
            );
            await _videoPlayerController!.seekTo(seekPosition);
            // Resume playback if it was playing before seek
            if (wasPlaying && mounted) {
              _videoPlayerController!.play();
            }
          }
        }
      });

      setState(() {
        _isInitialized = true;
        _isPaused = !_videoPlayerController!.value.isPlaying;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _videoListener() {
    if (_videoPlayerController != null && mounted) {
      final isPlaying = _videoPlayerController!.value.isPlaying;
      final position = _videoPlayerController!.value.position;
      final duration = _videoPlayerController!.value.duration;
      
      final progress = duration.inMilliseconds > 0
          ? position.inMilliseconds / duration.inMilliseconds
          : 0.0;
      widget.progressNotifier.value = progress;
      
      setState(() {
        _isPaused = !isPlaying;
      });
    }
  }

  void _togglePlayPause() {
    if (_videoPlayerController != null) {
      if (_videoPlayerController!.value.isPlaying) {
        _videoPlayerController!.pause();
      } else {
        _videoPlayerController!.play();
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.removeListener(_videoListener);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video Player
          _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'Failed to load video',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage ?? 'Unknown error',
                        style: const TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : _isInitialized && _chewieController != null
                  ? Chewie(controller: _chewieController!)
                  : const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),

          // Play/Pause Overlay
          if (_isInitialized && _isPaused)
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),


          // Instagram-style UI Overlay
          if (_isInitialized && !_hasError)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Left side - Profile info
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.grey[800],
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  '@username',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Video description here',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Right side - Action icons
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Like button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isLiked = !_isLiked;
                              });
                            },
                            child: Column(
                              children: [
                                Icon(
                                  _isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: _isLiked ? Colors.red : Colors.white,
                                  size: 32,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '1.2K',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Comment button
                          const Column(
                            children: [
                              Icon(
                                Icons.comment_outlined,
                                color: Colors.white,
                                size: 32,
                              ),
                              SizedBox(height: 4),
                              Text(
                                '234',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Share button
                          const Column(
                            children: [
                              Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 32,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Share',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Bookmark button
                          const Icon(
                            Icons.bookmark_border,
                            color: Colors.white,
                            size: 32,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
