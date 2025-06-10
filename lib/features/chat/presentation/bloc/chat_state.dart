import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unmute/features/chat/domain/entities/message_entity.dart';

part 'chat_state.freezed.dart';

@freezed
sealed class ChatState with _$ChatState {
  /// Initial state before anything happens.
  const factory ChatState.initial() = _Initial;

  /// Loading indicator while subscribing or waiting on network.
  const factory ChatState.loading() = _Loading;

  /// Loaded state with current messages and optional typing indicator.
  const factory ChatState.loaded({
    required List<MessageEntity> messages,
    @Default(false) bool isTyping,
  }) = _Loaded;

  /// Error state with a message.
  const factory ChatState.error({required String message}) = _Error;
}
