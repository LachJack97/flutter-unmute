import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unmute/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:unmute/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:unmute/features/chat/presentation/widgets/message_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      context.read<ChatBloc>().add(ChatEvent.messageSent(content));
      _messageController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unmute Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthEvent.logoutRequested());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                // Changed 'whenOrNull' to 'maybeWhen' as 'whenOrNull' is not a standard method for Freezed unions.
                // 'maybeWhen' allows providing callbacks for specific states and an optional orElse for unhandled states.
                state.maybeWhen(
                  loaded: (messages, isTyping) {
                    Future.delayed(
                        const Duration(milliseconds: 100), _scrollToBottom);
                  },
                  orElse: () {
                    // Provide a default orElse callback if other states don't need specific handling here.
                    // This is necessary for 'maybeWhen' if not all cases are explicitly handled.
                  },
                );
              },
              builder: (context, state) {
                return state.when(
                  initial: () => const Center(child: Text('Starting chat...')),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (message) => Center(child: Text('Error: $message')),
                  loaded: (messages, isTyping) {
                    if (messages.isEmpty && !isTyping) {
                      return const Center(
                          child: Text('No messages yet. Say hi!'));
                    }

                    // --- THIS IS THE UPDATED UI LOGIC ---
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      // Add 1 to the item count if the AI is typing
                      itemCount: messages.length + (isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        // If it's the last item and we're typing, show the indicator
                        if (isTyping && index == messages.length) {
                          return const TypingIndicator();
                        }
                        // Otherwise, build the regular message bubble
                        final message = messages[index];
                        return MessageBubble(message: message);
                      },
                    );
                  },
                );
              },
            ),
          ),
          _MessageInput(
            controller: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

// The message input widget (unchanged)
class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _MessageInput({required this.controller, required this.onSend});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onFieldSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(icon: const Icon(Icons.send), onPressed: onSend),
        ],
      ),
    );
  }
}

// --- NEW WIDGET FOR THE TYPING INDICATOR ---
class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
        ),
        // Here you could add a more complex animation
        child: const Text('...', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
