// This 'part of' directive is the key. It tells Dart that this file
// belongs to the 'chat_bloc.dart' library.
part of 'chat_bloc.dart';

@freezed
sealed class ChatEvent with _$ChatEvent {
  const factory ChatEvent.subscriptionRequested() = _SubscriptionRequested;
  const factory ChatEvent.messageSent(String content) = _MessageSent;
  const factory ChatEvent.messagesReceived(List<MessageEntity> messages) =
      _MessagesReceived;
}
