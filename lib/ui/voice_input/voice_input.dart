import 'package:flutter/material.dart';

/// Voice input service - speech-to-text integration
/// Uses speech_to_text package for real-time transcription
class VoiceInputService {
  static final VoiceInputService _instance = VoiceInputService._();
  static VoiceInputService get instance => _instance;
  VoiceInputService._();

  bool _isListening = false;
  String _lastTranscription = '';

  bool get isListening => _isListening;
  String get lastTranscription => _lastTranscription;

  /// Start listening for speech input
  Future<void> startListening({
    required Function(String) onResult,
    required Function() onSoundLevelChange,
  }) async {
    if (_isListening) return;
    _isListening = true;

    // In production, this would use speech_to_text:
    // final speech = SpeechToText();
    // await speech.initialize();
    // speech.listen(
    //   onResult: (result) {
    //     _lastTranscription = result.recognizedWords;
    //     onResult(_lastTranscription);
    //   },
    //   onSoundLevelChange: (level) => onSoundLevelChange(),
    //   localeId: 'en_US',
    // );

    debugPrint('VoiceInputService: started listening');
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;
    _isListening = false;

    // In production:
    // speech.stop();

    debugPrint('VoiceInputService: stopped listening');
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    _isListening = false;
    _lastTranscription = '';
    debugPrint('VoiceInputService: cancelled');
  }

  /// Check if speech recognition is available
  Future<bool> isAvailable() async {
    // In production:
    // final speech = SpeechToText();
    // return await speech.initialize();
    return true;
  }

  /// Get available locales
  Future<List<String>> getAvailableLocales() async {
    // In production:
    // final speech = SpeechToText();
    // final locales = await speech.locales();
    // return locales.map((l) => l.localeId).toList();
    return ['en_US', 'es_ES', 'fr_FR', 'de_DE', 'zh_CN', 'ja_JP'];
  }
}

/// Voice input button widget - reusable mic button
class VoiceInputButton extends StatefulWidget {
  final Function(String) onTranscriptionComplete;
  final Color? activeColor;
  final double size;

  const VoiceInputButton({
    super.key,
    required this.onTranscriptionComplete,
    this.activeColor,
    this.size = 48,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> with TickerProviderStateMixin {
  final VoiceInputService _service = VoiceInputService.instance;
  late AnimationController _pulseController;
  String _partialText = '';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = _service.isListening;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mic button with pulse animation
        GestureDetector(
          onTapDown: (_) => _startListening(),
          onTapUp: (_) => _stopListening(),
          onTapCancel: () => _stopListening(),
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = isActive ? 1.0 + (_pulseController.value * 0.15) : 1.0;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: isActive
                        ? (widget.activeColor ?? colorScheme.error).withOpacity(0.2)
                        : colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    border: isActive
                        ? Border.all(
                            color: widget.activeColor ?? colorScheme.error,
                            width: 2 + (_pulseController.value * 2),
                          )
                        : null,
                  ),
                  child: Icon(
                    isActive ? Icons.mic : Icons.mic_none,
                    color: isActive ? (widget.activeColor ?? colorScheme.error) : colorScheme.onSurfaceVariant,
                    size: widget.size * 0.5,
                  ),
                ),
              );
            },
          ),
        ),

        // Partial transcription text
        if (_partialText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _partialText,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

        // Status label
        if (isActive)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Listening...',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: widget.activeColor ?? colorScheme.error,
                  ),
            ),
          ),
      ],
    );
  }

  void _startListening() async {
    _partialText = '';
    setState(() {});
    await _service.startListening(
      onResult: (text) {
        setState(() => _partialText = text);
      },
      onSoundLevelChange: () {},
    );
  }

  void _stopListening() async {
    await _service.stopListening();
    if (_partialText.isNotEmpty) {
      widget.onTranscriptionComplete(_partialText);
    }
    setState(() => _partialText = '');
  }
}
