/// Barrel d'import conditionnel pour le lecteur vidéo.
/// Sur Web : utilise [VideoPlayerWeb] (iframe Google Drive + blob URL).
/// Sur Android/iOS : utilise le stub [VideoPlayerWeb] (placeholder).
///
/// Usage dans le reste de l'app :
///   import 'video_player_factory.dart';
///   VideoPlayerWeb(videoUrl: url)   ← même API partout

export 'video_player_mobile.dart'
    if (dart.library.html) 'video_player_web.dart'
    if (dart.library.js_interop) 'video_player_web.dart';
