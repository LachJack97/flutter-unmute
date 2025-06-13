import 'package:equatable/equatable.dart';
import 'package:unmute/features/chat/domain/entities/message_entity.dart'; // Ensure this path is correct
import 'package:unmute/features/chat/presentation/widgets/language_selector_pill.dart'; // Import Language

abstract class ChatState extends Equatable {
  const ChatState(); // Constructor for base class

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<MessageEntity> messages;
  final bool isTyping;
  final Language? selectedLanguage; // Now nullable

  const ChatLoaded({
    required this.messages,
    this.isTyping = false,
    required this.selectedLanguage,
  });

  @override
  List<Object?> get props => [
        messages,
        isTyping,
        selectedLanguage,
      ];

  ChatLoaded copyWith({
    List<MessageEntity>? messages,
    bool? isTyping,
    Language? selectedLanguage, // Allow setting to null via copyWith
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}
