import 'package:unmute/features/chat/domain/entities/message_entity.dart';

abstract class ChatRepository {
  /// Sends a chat message.
  Future<void> sendMessage(String content);

  /// Subscribes to a stream of new messages.
  /// This will use Supabase Realtime to listen for new entries in our
  /// 'messages' table.
  Stream<List<MessageEntity>> getMessages();
}
// This repository defines the contract for chat-related operations.
// It includes methods for sending messages and subscribing to a stream of messages.
