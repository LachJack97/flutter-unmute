import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unmute/features/chat/data/repositories/chat_service.dart'; // <-- Correctly imports ChatService
import 'package:unmute/features/chat/domain/entities/message_entity.dart';

part 'chat_bloc.freezed.dart';
part 'chat_event.dart';
part 'chat_state.dart';

// These are the simplified events and states for this architecture
// You may need to run build_runner if these are different from your files.
// @freezed sealed class ChatEvent with _$ChatEvent { ... }
// @freezed sealed class ChatState with _$ChatState { ... }

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService;
  StreamSubscription<List<MessageEntity>>? _messageSubscription;

  // The BLoC now depends on the ChatService, not the old use cases.
  ChatBloc({required ChatService chatService})
      : _chatService = chatService,
        super(const ChatState.loading()) {
    on<_SubscriptionRequested>(_onSubscriptionRequested);
    on<_MessageSent>(_onMessageSent);
    on<_MessagesReceived>(_onMessagesReceived);
  }

  /// Subscribes to the real-time message stream from the ChatService.
  void _onSubscriptionRequested(
    _SubscriptionRequested event,
    Emitter<ChatState> emit,
  ) {
    emit(const ChatState.loading());
    _messageSubscription?.cancel();
    _messageSubscription = _chatService.getMessages().listen(
          (messages) => add(ChatEvent.messagesReceived(messages)),
          onError: (e) => emit(ChatState.error(message: e.toString())),
        );
  }

  /// Receives new messages from the stream and updates the state.
  void _onMessagesReceived(
    _MessagesReceived event,
    Emitter<ChatState> emit,
  ) {
    emit(ChatState.loaded(messages: event.messages));
  }

  /// Orchestrates the client-side process of sending a message.
  /// This is the adjusted method with our crucial debugging print statements.
  Future<void> _onMessageSent(
    _MessageSent event,
    Emitter<ChatState> emit,
  ) async {
    // These print statements will trace the execution flow in your Debug Console.
    print("BLOC: Received MessageSent event for content: '${event.content}'");
    try {
      print("BLOC: Calling translation function...");
      final translationData = await _chatService.getTranslation(event.content);
      print("BLOC: Got translation response: $translationData");

      print("BLOC: Saving complete message to database...");
      await _chatService.saveMessage(
        originalContent: event.content,
        translationData: translationData,
      );
      print("BLOC: Save message command completed successfully.");
      // The UI will update automatically via the real-time stream.
    } catch (e) {
      // If any step in the 'try' block fails, this will be executed.
      print("BLOC ERROR: Caught an exception -> ${e.toString()}");
      emit(ChatState.error(message: 'Failed to send message: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
