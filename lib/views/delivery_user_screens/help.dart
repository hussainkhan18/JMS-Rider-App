import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:jms/helper/style.dart' as style;

class Help extends StatelessWidget {
  const Help({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> videos = [
      {
        'title': 'How to Use the App',
        'description':
            'Watch this tutorial to understand how to navigate through the app easily.',
        'thumbnailUrl': 'https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg',
        'videoUrl':
            'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      },
      {
        'title': 'Managing Your Account',
        'description':
            'Learn how to update your personal info and manage account settings.',
        'thumbnailUrl': 'https://img.youtube.com/vi/jNQXAC9IVRw/0.jpg',
        'videoUrl': 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4',
      },
      {
        'title': 'Order & Payments',
        'description':
            'Understand how to place orders and make secure payments through the app.',
        'thumbnailUrl': 'https://img.youtube.com/vi/aqz-KE-bpKQ/0.jpg',
        'videoUrl': 'https://samplelib.com/lib/preview/mp4/sample-10s.mp4',
      },
      {
        'title': 'Track Your Progress',
        'description':
            'Monitor your app activity and check insights from your account.',
        'thumbnailUrl': 'https://img.youtube.com/vi/V-_O7nl0Ii0/0.jpg',
        'videoUrl': 'https://samplelib.com/lib/preview/mp4/sample-15s.mp4',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Help'),
        titleTextStyle: style.pageTitle(),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Help & Tutorials',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: videos.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  final video = videos[index];
                  return VideoCard(
                    title: video['title']!,
                    description: video['description']!,
                    thumbnailUrl: video['thumbnailUrl']!,
                    videoUrl: video['videoUrl']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoCard extends StatelessWidget {
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;

  const VideoCard({
    super.key,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPlayerScreen(
                title: title,
                videoUrl: videoUrl,
              ),
            ),
          );
        },
        splashColor: Colors.blue.withOpacity(0.2),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  thumbnailUrl,
                  height: 80,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'medium',
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'regular',
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String title;
  final String videoUrl;

  const VideoPlayerScreen({
    super.key,
    required this.title,
    required this.videoUrl,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
      });

    _controller.addListener(() {
      if (_controller.value.hasError) {
        debugPrint("Video error: ${_controller.value.errorDescription}");
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  const SizedBox(height: 20),
                  VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: Colors.blue,
                      bufferedColor: Colors.grey,
                      backgroundColor: Colors.black12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  IconButton(
                    iconSize: 48,
                    color: Colors.blue,
                    icon: Icon(_controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow),
                    onPressed: _togglePlayPause,
                  ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
