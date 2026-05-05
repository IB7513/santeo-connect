import 'package:flutter/material.dart';

/// Stub mobile du lecteur vidéo — affiche un placeholder sur Android/iOS
/// (les vidéos Drive ne sont accessibles qu'en Web via iframe)
class VideoPlayerWeb extends StatelessWidget {
  final String videoUrl;
  const VideoPlayerWeb({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.play_circle_outline, color: Colors.white54, size: 56),
          const SizedBox(height: 12),
          const Text(
            'Vidéo disponible\nsur la version Web',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 8),
          if (videoUrl.isNotEmpty)
            Text(
              'Regarder la démo sur votre navigateur',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }
}
