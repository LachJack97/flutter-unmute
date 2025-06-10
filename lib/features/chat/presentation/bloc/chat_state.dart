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
  final Language
      selectedLanguage; // This is the target language for translation
  final Language? nativeLanguage;
  final List<Language>
      translatableLanguagesForPill; // Languages for the pill, excluding native

  const ChatLoaded({
    required this.messages,
    this.isTyping = false,
    required this.selectedLanguage,
    this.nativeLanguage,
    required this.translatableLanguagesForPill,
  });

  @override
  List<Object?> get props => [
        messages,
        isTyping,
        selectedLanguage,
        nativeLanguage,
        translatableLanguagesForPill
      ];

  ChatLoaded copyWith({
    List<MessageEntity>? messages,
    bool? isTyping,
    Language? selectedLanguage,
    // For nullable fields in copyWith, you might need a way to explicitly set to null.
    // For simplicity, if nativeLanguage is passed, it's used. If not, existing is kept.
    Language? nativeLanguage,
    List<Language>? translatableLanguagesForPill,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      translatableLanguagesForPill:
          translatableLanguagesForPill ?? this.translatableLanguagesForPill,
    );
  }
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}
