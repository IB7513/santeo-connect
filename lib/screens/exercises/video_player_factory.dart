// Barrel d'import conditionnel pour le lecteur vidéo.

export 'video_player_mobile.dart'
    if (dart.library.html) 'video_player_web.dart'
    if (dart.library.js_interop) 'video_player_web.dart';
