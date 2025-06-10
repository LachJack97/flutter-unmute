import 'package:unmute/features/chat/domain/entities/message_entity.dart';
import 'package:unmute/features/chat/domain/repositories/chat_repository.dart';

class GetMessagesStream {
  final ChatRepository repository;

  GetMessagesStream(this.repository);

  Stream<List<MessageEntity>> call() {
    return repository.getMessages();
  }
}
