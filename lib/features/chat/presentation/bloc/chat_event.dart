import 'package:equatable/equatable.dart';
import 'package:unmute/features/chat/domain/entities/message_entity.dart'; // Ensure this path is correct
import 'dart:typed_data'; // Import for Uint8List
import 'package:unmute/features/chat/presentation/widgets/language_selector_pill.dart'; // Import Language

abstract class ChatEvent extends Equatable {
  const ChatEvent(); // Constructor for base class

  @override
  List<Object?> get props => []; // Equatable requires props
}

class SubscriptionRequested extends ChatEvent {
  const SubscriptionRequested();
}

class MessageSent extends ChatEvent {
  final String content;
  const MessageSent(this.content);

  @override
  List<Object> get props => [content];
}

class MessagesReceived extends ChatEvent {
  final List<MessageEntity> messages;
  const MessagesReceived(this.messages);

  @override
  List<Object> get props => [messages];
}

class LanguageChanged extends ChatEvent {
  final Language language; // Changed from languageCode to Language object
  const LanguageChanged(this.language);

  @override
  List<Object> get props => [language];
}

class ChatHistoryCleared extends ChatEvent {
  const ChatHistoryCleared();
}

class ImageMessageSent extends ChatEvent {
  final Uint8List imageBytes; // Changed from imagePath to imageBytes
  final String? targetLanguageCode; // Now nullable

  const ImageMessageSent(
      {required this.imageBytes, required this.targetLanguageCode});

  @override
  List<Object?> get props => [imageBytes, targetLanguageCode];
}
