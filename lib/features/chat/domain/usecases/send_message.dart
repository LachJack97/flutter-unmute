import 'package:unmute/features/chat/domain/repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository repository;

  SendMessage(this.repository);

  Future<void> call(String content) {
    return repository.sendMessage(content);
  }
}
