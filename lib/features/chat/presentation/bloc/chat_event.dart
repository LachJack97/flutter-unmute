import 'package:equatable/equatable.dart';
import 'package:unmute/features/chat/domain/entities/message_entity.dart'; // Ensure this path is correct

abstract class ChatEvent extends Equatable {
  const ChatEvent(); // Constructor for base class

  @override
  List<Object> get props => []; // Equatable requires props
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
  final String languageCode;
  const LanguageChanged(this.languageCode);

  @override
  List<Object> get props => [languageCode];
}
