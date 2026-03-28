import 'package:flutter/material.dart';
import 'package:jms/models/help_video_model.dart';
import 'package:jms/widgets/youtube_player_screen.dart';

class HelpVideoCard extends StatelessWidget {
  final HelpVideo video;

  const HelpVideoCard({
    super.key,
    required this.video,
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
              builder: (_) => YoutubePlayerScreen(
                title: video.title,
                videoUrl: video.video,
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
                  video.image,
                  height: 80,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.play_circle_outline,
                          size: 40, color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                video.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500, // Assuming 'medium' is w500
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                video.description,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.normal, // Assuming 'regular' is w400
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
