// ignore: avoid_web_libraries_in_flutter
import 'package:web/web.dart' as web;
import 'dart:js_interop';
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ─── Bindings JS ─────────────────────────────────────────────────────────
@JS('window.__santeoSpeak')
external void _jsSanteoSpeak(JSString text);

@JS('window.__santeoTtsStop')
external void _jsSanteoTtsStop();

// ─── Compteur pour IDs uniques ────────────────────────────────────────────
int _viewCounter = 0;
final Set<String> _registeredViews = {};

class TtsService {
  // ── speak() classique via @JS ─────────────────────────────────────────
  static void speak(String text) {
    if (text.isEmpty) return;
    try {
      _jsSanteoSpeak(text.toJS);
    } catch (e) {
      if (kDebugMode) debugPrint('[TTS] $e');
    }
  }

  static void stop() {
    try { _jsSanteoTtsStop(); } catch (_) {}
  }

  // ── runJs : injection de script dans le DOM ───────────────────────────
  static void runJs(String js) {
    try {
      final s = web.document.createElement('script') as web.HTMLScriptElement;
      s.text = js;
      web.document.body?.appendChild(s);
      s.remove();
    } catch (_) {}
  }

  // ── buildSpeakButton : HtmlElementView avec vrai <button> HTML ────────
  // Chaque instance génère un viewId unique → plusieurs boutons possibles.
  static Widget buildSpeakButton({
    required String text,
    required Widget child,
    double? width,
    double height = 44,
  }) {
    if (!kIsWeb) {
      return SizedBox(width: width, height: height, child: child);
    }

    _viewCounter++;
    final viewId = 'tts-vol-view-$_viewCounter';

    final escapedText = text
        .replaceAll('\\', '\\\\')
        .replaceAll("'", "\\'")
        .replaceAll('\n', ' ')
        .replaceAll('\r', '');

    if (!_registeredViews.contains(viewId)) {
      _registeredViews.add(viewId);
      ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
        final btn = web.document.createElement('button') as web.HTMLButtonElement;
        btn.setAttribute('style',
          'width:100%;height:100%;background:transparent;border:none;'
          'cursor:pointer;padding:0;margin:0;outline:none;'
          '-webkit-tap-highlight-color:transparent;',
        );
        btn.setAttribute('onclick',
          "(function(e){"
          "e.stopPropagation();"
          "var s=window.speechSynthesis;if(!s)return;"
          "s.cancel();"
          "var u=new SpeechSynthesisUtterance('$escapedText');"
          "u.lang='fr-FR';u.rate=0.85;u.pitch=1.0;u.volume=1.0;"
          "var vv=s.getVoices();"
          "for(var i=0;i<vv.length;i++){if(vv[i].lang==='fr-FR'){u.voice=vv[i];break;}}"
          "s.speak(u);"
          "})(event);"
        );
        return btn;
      });
    }

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(child: child),
          HtmlElementView(viewType: viewId),
        ],
      ),
    );
  }
}
