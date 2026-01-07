import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/chat_ai_service.dart';
import '../../providers/app_providers.dart';

// ============================================================
// MODÈLE MESSAGE
// ============================================================
class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final bool isTyping;

  _ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? time,
    this.isTyping = false,
  }) : time = time ?? DateTime.now();
}

// ============================================================
// ÉCRAN CHAT
// ============================================================
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;
  late ChatAIService _aiService;

  // Suggestions rapides
  static const _suggestions = [
    '💪 Comment débuter ?',
    '🏖️ Exercices en chaleur',
    '😴 Mieux dormir',
    '🦵 Douleur aux genoux',
    '🧘 Étirements du dos',
    '💧 Hydratation',
    '🎯 Mon programme',
    '💡 Motivation',
  ];

  @override
  void initState() {
    super.initState();
    // Initialiser le service sans profil d'abord (synchrone)
    _aiService = ChatAIService(userProfile: null);
    // Afficher le message de bienvenue immédiatement
    _messages.add(_ChatMessage(
      text: '🌺 Ia orana !\n\n'
          'Je suis **SANTEO IA**, votre assistant santé personnalisé pour le Pacifique.\n\n'
          'Je peux vous aider sur :\n'
          '• 🏋️ Exercices & mouvements\n'
          '• 🩺 Conseils santé & douleurs\n'
          '• 🌴 Adaptation au climat tropical\n'
          '• 💪 Motivation & progression\n'
          '• 🧘 Récupération & sommeil\n\n'
          'Posez-moi votre question !',
      isUser: false,
    ));
    // Mettre à jour avec le profil réel après le build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<AppProvider>();
      setState(() {
        _aiService = ChatAIService(userProfile: provider.userProfile);
        // Remplacer le message de bienvenue avec le prénom si disponible
        final prenom = provider.userProfile?.prenom ?? provider.userName ?? '';
        final territoire = provider.userProfile?.localisation ?? 'le Pacifique';
        if (prenom.isNotEmpty) {
          _messages[0] = _ChatMessage(
            text: '🌺 Ia orana, **$prenom** !\n\n'
                'Je suis **SANTEO IA**, votre assistant santé personnalisé, adapté au contexte de **$territoire**.\n\n'
                'Je peux vous aider sur :\n'
                '• 🏋️ Exercices & mouvements\n'
                '• 🩺 Conseils santé & douleurs\n'
                '• 🌴 Adaptation au climat tropical\n'
                '• 💪 Motivation & progression\n'
                '• 🧘 Récupération & sommeil\n\n'
                'Posez-moi votre question !',
            isUser: false,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }



  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _textCtrl.clear();

    setState(() {
      _messages.add(_ChatMessage(text: text.trim(), isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    // Simuler un délai de "réflexion" réaliste
    final delay = 600 + (text.length * 10).clamp(0, 1200);
    await Future.delayed(Duration(milliseconds: delay));

    if (!mounted) return;
    final response = _aiService.reply(text.trim());

    setState(() {
      _isTyping = false;
      _messages.add(_ChatMessage(text: response, isUser: false));
    });
    _scrollToBottom(delay: 150);
  }

  void _scrollToBottom({int delay = 0}) {
    Future.delayed(Duration(milliseconds: delay), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF0F4F8),
          body: SafeArea(
            child: Column(
              children: [
                // ── HEADER ──
                _ChatHeader(provider: provider),

                // ── MESSAGES ──
                Expanded(
                  child: ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (ctx, i) {
                      if (_isTyping && i == _messages.length) {
                        return _TypingBubble();
                      }
                      return _MessageBubble(message: _messages[i]);
                    },
                  ),
                ),

                // ── SUGGESTIONS ──
                if (!_isTyping) _SuggestionsRow(
                  suggestions: _suggestions,
                  onTap: _sendMessage,
                ),

                // ── INPUT ──
                _ChatInput(
                  controller: _textCtrl,
                  isTyping: _isTyping,
                  onSend: _sendMessage,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// HEADER
// ============================================================
class _ChatHeader extends StatelessWidget {
  final AppProvider provider;
  const _ChatHeader({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF26C6DA), Color(0xFF0097A7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x2026C6DA),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          // Avatar IA animé
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SANTEO IA',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF69F0AE),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'En ligne · Assistant santé Pacifique',
                      style: GoogleFonts.roboto(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Badge offline
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.offline_bolt,
                    color: Colors.white, size: 13),
                const SizedBox(width: 4),
                Text(
                  '100% Privé',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BULLES DE MESSAGE
// ============================================================
class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _AIAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.78,
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? const LinearGradient(
                            colors: [Color(0xFF26C6DA), Color(0xFF0097A7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isUser ? null : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft:
                          Radius.circular(isUser ? 18 : 4),
                      bottomRight:
                          Radius.circular(isUser ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _buildText(message.text, isUser),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatTime(message.time),
                  style: GoogleFonts.roboto(
                    fontSize: 10,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            _UserAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildText(String text, bool isUser) {
    // Parser le markdown basique (**gras**, • listes)
    final spans = <TextSpan>[];
    final parts = text.split('**');
    for (int i = 0; i < parts.length; i++) {
      if (i.isOdd) {
        spans.add(TextSpan(
          text: parts[i],
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isUser ? Colors.white : AppTheme.textPrimary,
          ),
        ));
      } else {
        spans.add(TextSpan(
          text: parts[i],
          style: TextStyle(
            color: isUser
                ? Colors.white
                : AppTheme.textPrimary,
            height: 1.55,
          ),
        ));
      }
    }

    return RichText(
      text: TextSpan(
        style: GoogleFonts.roboto(fontSize: 14),
        children: spans,
      ),
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ============================================================
// AVATAR IA
// ============================================================
class _AIAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF26C6DA), Color(0xFF0097A7)],
        ),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.psychology, color: Colors.white, size: 18),
    );
  }
}

// ============================================================
// AVATAR UTILISATEUR
// ============================================================
class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.secondary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: AppTheme.secondary, size: 18),
    );
  }
}

// ============================================================
// INDICATEUR DE FRAPPE
// ============================================================
class _TypingBubble extends StatefulWidget {
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _AIAvatar(),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _anim,
                  builder: (_, __) => Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.only(
                        right: i < 2 ? 5 : 0,
                        bottom: (i == 1 ? _anim.value : (i == 0 ? (1 - _anim.value) : _anim.value)) * 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary
                          .withValues(alpha: 0.5 + _anim.value * 0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SUGGESTIONS RAPIDES
// ============================================================
class _SuggestionsRow extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onTap;

  const _SuggestionsRow({
    required this.suggestions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: suggestions.map((s) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Material(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => onTap(s.replaceAll(RegExp(r'^[^\w\s]'), '').trim()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      s,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: AppTheme.primaryDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ============================================================
// INPUT
// ============================================================
class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isTyping;
  final Function(String) onSend;

  const _ChatInput({
    required this.controller,
    required this.isTyping,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                    color: AppTheme.divider, width: 1),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      enabled: true,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization:
                          TextCapitalization.sentences,
                      style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: isTyping
                            ? 'SANTEO IA répond...'
                            : 'Posez votre question santé...',
                        hintStyle: GoogleFonts.roboto(
                            fontSize: 13,
                            color: AppTheme.textLight),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12),
                      ),
                      onSubmitted: onSend,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Bouton envoyer — Material + InkWell pour compatibilité Web
          Material(
            color: isTyping ? AppTheme.divider : AppTheme.primary,
            shape: const CircleBorder(),
            elevation: isTyping ? 0 : 4,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: isTyping ? null : () => onSend(controller.text),
              child: SizedBox(
                width: 46,
                height: 46,
                child: Icon(
                  isTyping ? Icons.hourglass_top : Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
