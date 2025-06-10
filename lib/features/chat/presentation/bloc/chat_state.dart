import 'package:equatable/equatable.dart';
import 'package:unmute/features/chat/domain/entities/message_entity.dart'; // Ensure this path is correct

abstract class ChatState extends Equatable {
  const ChatState(); // Constructor for base class

  @override
  List<Object> get props => [];
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

  const ChatLoaded({required this.messages, this.isTyping = false});

  @override
  List<Object> get props => [messages, isTyping];

  ChatLoaded copyWith({
    List<MessageEntity>? messages,
    bool? isTyping,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}
