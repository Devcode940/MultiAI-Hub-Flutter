import 'package:flutter/material.dart';
import 'package:multiai_hub/data/models/models.dart';
import 'package:multiai_hub/ui/voice_input/voice_input.dart';

/// Chat overlay - floating mini-chat that appears over any app
/// Provides quick AI access without leaving the current context
class ChatOverlay {
  static final ChatOverlay _instance = ChatOverlay._();
  static ChatOverlay get instance => _instance;
  ChatOverlay._();

  OverlayEntry? _overlayEntry;
  bool _isVisible = false;
  AiProvider? _activeProvider;

  bool get isVisible => _isVisible;
  AiProvider? get activeProvider => _activeProvider;

  /// Show the floating chat overlay
  void show(BuildContext context, {AiProvider? provider}) {
    if (_isVisible) return;
    _activeProvider = provider;
    _isVisible = true;

    _overlayEntry = OverlayEntry(
      builder: (context) => const _FloatingChatWidget(),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Hide the floating chat overlay
  void hide() {
    if (!_isVisible) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isVisible = false;
  }

  /// Toggle visibility
  void toggle(BuildContext context, {AiProvider? provider}) {
    if (_isVisible) {
      hide();
    } else {
      show(context, provider: provider);
    }
  }
}

/// Floating chat widget - the actual overlay UI
class _FloatingChatWidget extends StatefulWidget {
  const _FloatingChatWidget();

  @override
  State<_FloatingChatWidget> createState() => _FloatingChatWidgetState();
}

class _FloatingChatWidgetState extends State<_FloatingChatWidget> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _expandController;
  final TextEditingController _messageController = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _isExpanded = true;
  Offset _position = const Offset(20, 100); // Initial position

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _expandController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
         "end": Offset.zero,
        ).animate(CurvedAnimation(parent: _slideController, curve: Curves.elasticOut)),
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _position = Offset(
                (_position.dx + details.delta.dx).clamp(0, size.width - 320),
                (_position.dy + details.delta.dy).clamp(0, size.height - 500),
              );
            });
          },
          child: Material(
            elevation: 12,
            borderRadius: BorderRadius.circular(16),
            shadowColor: Colors.black26,
            child: AnimatedBuilder(
              animation: _expandController,
              builder: (context, child) {
                final height = _isExpanded ? 420.0 : 60.0;
                return Container(
                  width: 300,
                  height: height * _expandController.value,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: _isExpanded ? _buildExpandedContent(colorScheme) : _buildCollapsedContent(colorScheme),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Expanded overlay with full chat
  Widget _buildExpandedContent(ColorScheme colorScheme) {
    return Column(
      children: [
        // Drag handle + header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              // Drag indicator
              Container(width: 30, height: 4, decoration: BoxDecoration(
                color: colorScheme.onPrimaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              )),
              const Spacer(),
              Text('Quick AI Chat', style: TextStyle(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              )),
              const Spacer(),
              // Minimize button
              GestureDetector(
                onTap: () => setState(() => _isExpanded = false),
                child: Icon(Icons.minimize, size: 16, color: colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 8),
              // Close button
              GestureDetector(
                onTap: () => ChatOverlay.instance.hide(),
                child: Icon(Icons.close, size: 16, color: colorScheme.onPrimaryContainer),
              ),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Text('Type a message to any AI', style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  )),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return Align(
                      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: msg.isUser ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(msg.text, style: TextStyle(fontSize: 12)),
                      ),
                    );
                  },
                ),
        ),

        // Input bar
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Ask any AI...',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  style: const TextStyle(fontSize: 13),
                  onSubmitted: _sendMessage,
                ),
              ),
              const SizedBox(width: 4),
              // Voice input
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  icon: const Icon(Icons.mic, size: 16),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                ),
              ),
              // Send
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  icon: Icon(Icons.send, size: 16, color: colorScheme.primary),
                  onPressed: () => _sendMessage(_messageController.text),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Collapsed mini FAB
  Widget _buildCollapsedContent(ColorScheme colorScheme) {
    return InkWell(
      onTap: () => setState(() => _isExpanded = true),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text('Quick AI', style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            )),
          ],
        ),
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _messages.add(_ChatMessage(text: 'Opening in WebView...', isUser: false));
    });
    _messageController.clear();
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}
