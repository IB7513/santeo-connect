// Import conditionnel VideoWebService.

export 'video_web_service_stub.dart'
    if (dart.library.html) 'video_web_service_web.dart'
    if (dart.library.js_interop) 'video_web_service_web.dart';
