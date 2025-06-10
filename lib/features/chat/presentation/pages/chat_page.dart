import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unmute/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/foundation.dart'; // Import for listEquals
import 'package:unmute/features/auth/presentation/bloc/auth_event.dart';
import 'package:unmute/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:unmute/features/chat/presentation/bloc/chat_event.dart';
import 'package:unmute/features/chat/presentation/bloc/chat_state.dart';

// Import the new, separated widget files
import 'package:unmute/features/chat/presentation/widgets/chat_input_bar.dart';
import 'package:unmute/features/chat/presentation/widgets/chat_message_item.dart';
import 'package:unmute/features/chat/presentation/widgets/chat_typing_indicator.dart';
// Make sure this path points to your rebuilt LanguageSelectorPill file
import 'package:unmute/features/chat/presentation/widgets/language_selector_pill.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  // Language state is now managed by ChatBloc

  @override
  void initState() {
    super.initState();
    // ChatBloc's SubscriptionRequested will handle loading initial language.
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
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

  // The callback now provides the full Language object.
  void _onLanguageSelected(Language newLanguage) {
    // Dispatch LanguageChanged event with the full Language object
    context.read<ChatBloc>().add(LanguageChanged(newLanguage));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      appBar: AppBar(
        elevation: 0, // Removes shadow for a flatter, modern look
        backgroundColor: Colors.white, // Explicitly set to white
        scrolledUnderElevation: 0, // Ensures no elevation change on scroll
        leading: PopupMenuButton<String>(
          icon: Icon(
            Icons.account_circle,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onSelected: (value) {
            if (value == 'logout') {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            } else if (value == 'clear_chat') {
              // Dispatch event to clear chat history
              context.read<ChatBloc>().add(const ChatHistoryCleared());
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'logout',
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
              ),
            ),
            const PopupMenuDivider(), // Optional: adds a visual separator
            const PopupMenuItem<String>(
              value: 'clear_chat',
              child: ListTile(
                leading: Icon(Icons.delete_sweep_outlined),
                title: Text('Clear Chat History'),
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value:
                  'set_native_language', // This value won't be directly used for action
              child: SubmenuButton(
                menuChildren:
                    LanguageSelectorPill.availableLanguages.map((lang) {
                  return MenuItemButton(
                    child: Text(lang.promptName), // Show full name for clarity
                    onPressed: () {
                      context.read<ChatBloc>().add(NativeLanguageSet(lang));
                      Navigator.pop(context); // Close the main popup menu
                    },
                  );
                }).toList(),
                child: const Text('Set Native Language'),
              ),
            ),
            // You can add more items here like 'Profile', 'Settings', etc.
          ],
        ),
        title: Text(
          'Chat',
          style: TextStyle(
            fontWeight: FontWeight.w500, // Slightly bolder title
            color: Theme.of(context).colorScheme.onSurface, // Adapts to theme
          ),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<ChatBloc, ChatState>(
            buildWhen: (previous, current) =>
                previous is! ChatLoaded ||
                current is! ChatLoaded ||
                (previous as ChatLoaded).selectedLanguage !=
                    (current as ChatLoaded).selectedLanguage ||
                !listEquals(
                    (previous as ChatLoaded).translatableLanguagesForPill,
                    (current as ChatLoaded).translatableLanguagesForPill),
            builder: (context, state) {
              Language currentSelectedLanguage =
                  LanguageSelectorPill.defaultLanguage;
              List<Language> languagesForPill = [
                LanguageSelectorPill.defaultLanguage
              ]; // Fallback
              if (state is ChatLoaded) {
                currentSelectedLanguage = state.selectedLanguage;
                languagesForPill = state.translatableLanguagesForPill;
              }
              return LanguageSelectorPill(
                languagesToDisplayInPill: languagesForPill,
                selectedLanguage: currentSelectedLanguage,
                onLanguageSelected: _onLanguageSelected,
              );
            },
          ),
          const SizedBox(
              width:
                  12.0), // Increased spacing for better balance from the edge
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatLoaded) {
                  // Optional: Add a check to prevent scrolling on every rebuild
                  // if new messages haven't been added.
                  Future.delayed(
                      const Duration(milliseconds: 100), _scrollToBottom);
                }
              },
              builder: (context, state) {
                if (state is ChatInitial ||
                    (state is ChatLoading &&
                        (state is! ChatLoaded ||
                            (state as ChatLoaded).messages.isEmpty))) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ChatError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else if (state is ChatLoaded) {
                  if (state.messages.isEmpty && !state.isTyping) {
                    return const Center(
                        child: Text('No messages yet. Say hi!'));
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 12.0),
                    itemCount: state.messages.length + (state.isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (state.isTyping && index == state.messages.length) {
                        return const TypingIndicator();
                      }
                      final message = state.messages[index];
                      return ChatMessageItem(message: message);
                    },
                  );
                }
                return const SizedBox.shrink(); // Fallback
              },
            ),
          ),
          ChatInputBar(
            controller: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}
