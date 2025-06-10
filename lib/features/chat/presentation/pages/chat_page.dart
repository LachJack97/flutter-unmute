import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unmute/features/auth/presentation/bloc/auth_bloc.dart'; // Ensure AuthBloc is accessible
import 'package:unmute/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:unmute/features/chat/presentation/bloc/chat_event.dart'; // Import ChatEvent
import 'package:unmute/features/chat/presentation/bloc/chat_state.dart'; // Import ChatState
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
      // Changed from ChatEvent.messageSent to MessageSent (the Equatable class)
      context.read<ChatBloc>().add(MessageSent(content));
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
              // Assuming AuthBloc's events are also Equatable-based,
              // replace with the direct event class name if not using Freezed.
              // For example: context.read<AuthBloc>().add(const LogoutRequested());
              // If AuthBloc still uses Freezed, keep AuthEvent.logoutRequested()
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
                // Using 'is' check for Equatable states instead of 'whenOrNull'/'maybeWhen'
                if (state is ChatLoaded) {
                  Future.delayed(
                      const Duration(milliseconds: 100), _scrollToBottom);
                }
              },
              builder: (context, state) {
                // Using 'is' checks for Equatable states instead of 'when'
                if (state is ChatInitial) {
                  return const Center(child: Text('Starting chat...'));
                } else if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ChatError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else if (state is ChatLoaded) {
                  if (state.messages.isEmpty && !state.isTyping) {
                    return const Center(
                        child: Text('No messages yet. Say hi!'));
                  }

                  // --- THIS IS THE UI LOGIC FOR LOADED STATE ---
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    // Add 1 to the item count if the AI is typing
                    itemCount: state.messages.length + (state.isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      // If it's the last item and we're typing, show the indicator
                      if (state.isTyping && index == state.messages.length) {
                        return const TypingIndicator();
                      }
                      // Otherwise, build the regular message bubble
                      final message = state.messages[index];
                      return MessageBubble(message: message);
                    },
                  );
                }
                // Fallback for any unhandled state (should ideally not be reached with exhaustive checks)
                return const SizedBox.shrink();
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

// The message input widget (unchanged from your provided code)
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

// --- NEW WIDGET FOR THE TYPING INDICATOR (unchanged from your provided code) ---
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
