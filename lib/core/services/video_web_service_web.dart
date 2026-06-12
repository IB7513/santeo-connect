/// VideoWebService — Version WEB
/// Enregistre le HtmlElementView via ui_web.platformViewRegistry
/// Supporte les URLs Google Drive sous toutes formes :
///   - https://drive.google.com/file/d/ID/view
///   - https://drive.google.com/file/d/ID/preview
///   - https://drive.google.com/open?id=ID
///   - https://drive.google.com/uc?id=ID

import 'dart:js_interop';
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
// ignore: avoid_web_libraries_in_flutter
import 'package:web/web.dart' as web;

class VideoWebService {
  /// Extrait l'ID Drive depuis n'importe quel format d'URL Drive
  static String? _extractDriveId(String url) {
    // Format /file/d/ID/...
    final m1 = RegExp(r'/file/d/([a-zA-Z0-9_-]+)').firstMatch(url);
    if (m1 != null) return m1.group(1);
    // Format ?id=ID ou open?id=ID
    final m2 = RegExp(r'[?&]id=([a-zA-Z0-9_-]+)').firstMatch(url);
    return m2?.group(1);
  }

  static void registerPlayer(String viewId, String videoUrl) {
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
      final container =
          web.document.createElement('div') as web.HTMLDivElement;
      container.style.cssText =
          'width:100%;height:100%;background:#0d2137;position:relative;'
          'overflow:hidden;border-radius:inherit;';

      if (videoUrl.isEmpty) {
        _appendPlaceholder(container, '🎥', 'Vidéo non disponible');
        return container;
      }

      final driveId = _extractDriveId(videoUrl);
      if (driveId == null || driveId.isEmpty) {
        _appendPlaceholder(container, '🎥', 'URL vidéo invalide');
        return container;
      }

      // Construire la page HTML avec spinner de chargement + iframe Drive /preview
      final previewUrl = 'https://drive.google.com/file/d/$driveId/preview';
      final html = '''<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
  * { margin:0; padding:0; box-sizing:border-box; }
  html, body { width:100%; height:100%; background:#0d2137; overflow:hidden; }

  /* Spinner affiché pendant le chargement */
  #loader {
    position:absolute; inset:0;
    display:flex; flex-direction:column;
    align-items:center; justify-content:center;
    background:#0d2137; z-index:10;
    color:#fff; font-family:sans-serif; gap:14px;
    transition: opacity 0.4s;
  }
  .spinner {
    width:40px; height:40px;
    border:3px solid rgba(255,255,255,0.2);
    border-top-color:#26c6da;
    border-radius:50%;
    animation: spin 0.8s linear infinite;
  }
  @keyframes spin { to { transform:rotate(360deg); } }
  #loader p { font-size:13px; opacity:0.7; }

  iframe {
    position:absolute; inset:0;
    width:100%; height:100%;
    border:none; display:block; background:#000;
    opacity:0; transition: opacity 0.5s;
  }
  iframe.loaded { opacity:1; }

  /* Bouton plein écran natif dans le blob */
  #fsBtn {
    position:absolute; bottom:10px; right:10px; z-index:20;
    background:rgba(0,0,0,0.65); border:none; border-radius:8px;
    color:#fff; font-size:11px; font-family:sans-serif;
    padding:5px 10px; cursor:pointer; display:flex;
    align-items:center; gap:5px; transition: background 0.2s;
  }
  #fsBtn:hover { background:rgba(38,198,218,0.8); }
  #fsBtn svg { width:16px; height:16px; fill:white; }
</style>
</head>
<body>
<div id="loader">
  <div class="spinner"></div>
  <p>Chargement de la vidéo…</p>
</div>
<iframe
  id="vid"
  src="$previewUrl"
  allowfullscreen
  allow="autoplay; fullscreen; picture-in-picture"
></iframe>
<button id="fsBtn" onclick="goFS()">
  <svg viewBox="0 0 24 24"><path d="M7 14H5v5h5v-2H7v-3zm-2-4h2V7h3V5H5v5zm12 7h-3v2h5v-5h-2v3zM14 5v2h3v3h2V5h-5z"/></svg>
  Plein écran
</button>
<script>
  var iframe = document.getElementById('vid');
  var loader = document.getElementById('loader');
  iframe.addEventListener('load', function() {
    iframe.classList.add('loaded');
    loader.style.opacity = '0';
    setTimeout(function(){ loader.style.display='none'; }, 400);
  });

  function goFS() {
    var el = document.documentElement;
    if (el.requestFullscreen) el.requestFullscreen();
    else if (el.webkitRequestFullscreen) el.webkitRequestFullscreen();
  }

  // Bloquer ouverture d'onglet depuis Drive
  window.open = function() { return null; };
  window.top = window;
  document.addEventListener('click', function(e) {
    var a = e.target.closest('a');
    if (a && a.href && !a.href.startsWith('javascript')) {
      e.preventDefault(); e.stopPropagation();
    }
  }, true);
  window.addEventListener('beforeunload', function(e) {
    e.preventDefault(); e.stopImmediatePropagation(); return false;
  });
</script>
</body>
</html>''';

      final blob = web.Blob(
        [html.toJS].toJS,
        web.BlobPropertyBag(type: 'text/html;charset=utf-8'),
      );
      final blobUrl = web.URL.createObjectURL(blob);

      final iframe =
          web.document.createElement('iframe') as web.HTMLIFrameElement;
      iframe.src = blobUrl;
      iframe.setAttribute('allowfullscreen', 'true');
      iframe.setAttribute('allow', 'autoplay; fullscreen; picture-in-picture');
      iframe.style.cssText =
          'width:100%;height:100%;border:none;display:block;background:#0d2137;';
      container.appendChild(iframe);
      return container;
    });
  }

  static void _appendPlaceholder(
      web.HTMLDivElement container, String icon, String text) {
    final div = web.document.createElement('div') as web.HTMLDivElement;
    div.style.cssText =
        'width:100%;height:100%;display:flex;flex-direction:column;'
        'align-items:center;justify-content:center;color:#fff;'
        'font-family:sans-serif;gap:12px;'
        'background:linear-gradient(135deg,#0d2137,#1a3a4f);';
    final iconEl = web.document.createElement('div') as web.HTMLDivElement;
    iconEl.style.cssText = 'font-size:48px;';
    iconEl.innerText = icon;
    final textEl = web.document.createElement('div') as web.HTMLDivElement;
    textEl.style.cssText =
        'font-size:14px;text-align:center;padding:0 16px;opacity:0.7;';
    textEl.innerText = text;
    div.appendChild(iconEl);
    div.appendChild(textEl);
    container.appendChild(div);
  }
}
