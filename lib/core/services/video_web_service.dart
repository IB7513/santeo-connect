/// Import conditionnel VideoWebService.
/// Sur Web : enregistre les HtmlElementView via platformViewRegistry.
/// Sur mobile : no-op.

export 'video_web_service_stub.dart'
    if (dart.library.html) 'video_web_service_web.dart'
    if (dart.library.js_interop) 'video_web_service_web.dart';
