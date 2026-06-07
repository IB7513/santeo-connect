// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
// ignore: avoid_web_libraries_in_flutter
import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';

class VideoPlayerWeb extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerWeb({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWeb> createState() => _VideoPlayerWebState();
}

class _VideoPlayerWebState extends State<VideoPlayerWeb> {
  late final String _viewId;
  static final Set<String> _registeredIds = {};

  @override
  void initState() {
    super.initState();
    // ID unique basé sur timestamp pour éviter conflits
    _viewId =
        'video-player-${widget.videoUrl.hashCode}-${DateTime.now().millisecondsSinceEpoch}';

    if (!_registeredIds.contains(_viewId)) {
      _registeredIds.add(_viewId);
      ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
        final video =
            web.document.createElement('video') as web.HTMLVideoElement;

        // URL absolue pour éviter les problèmes de chemin
        final baseUrl = web.window.location.href.replaceAll(
          RegExp(r'[^/]*$'),
          '',
        );
        final fullUrl = widget.videoUrl.startsWith('http')
            ? widget.videoUrl
            : '$baseUrl${widget.videoUrl}';

        video.src = fullUrl;
        video.controls = true;
        video.setAttribute('playsinline', 'true');
        video.setAttribute('preload', 'metadata');
        video.style.width = '100%';
        video.style.height = '100%';
        video.style.objectFit = 'contain';
        video.style.backgroundColor = '#000000';
        video.style.borderRadius = '0 0 16px 16px';
        return video;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }
}
