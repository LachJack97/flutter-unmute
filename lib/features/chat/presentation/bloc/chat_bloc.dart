import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unmute/features/chat/data/repositories/chat_service.dart';
import 'package:unmute/features/chat/domain/entities/message_entity.dart';

// These now correctly import your new equatable-based event/state files.
import 'package:unmute/features/chat/presentation/bloc/chat_event.dart';
import 'package:unmute/features/chat/presentation/bloc/chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService;
  StreamSubscription<List<MessageEntity>>? _messageSubscription;

  ChatBloc({required ChatService chatService})
      : _chatService = chatService,
        super(const ChatInitial()) {
    // Correctly starts with ChatInitial
    on<SubscriptionRequested>(_onSubscriptionRequested);
    on<MessageSent>(_onMessageSent);
    on<MessagesReceived>(_onMessagesReceived);
  }

  void _onSubscriptionRequested(
    SubscriptionRequested event,
    Emitter<ChatState> emit,
  ) {
    emit(const ChatLoading());
    _messageSubscription?.cancel();
    _messageSubscription = _chatService.getMessages().listen(
          (messages) => add(MessagesReceived(messages)),
          onError: (e) => emit(ChatError(e.toString())),
        );
  }

  void _onMessagesReceived(
    MessagesReceived event,
    Emitter<ChatState> emit,
  ) {
    // When new messages arrive from the stream, the 'isTyping' flag is
    // automatically handled because the emitted ChatLoaded state defaults it to false.
    emit(ChatLoaded(messages: event.messages));
  }

  Future<void> _onMessageSent(
    MessageSent event,
    Emitter<ChatState> emit,
  ) async {
    // --- THIS IS THE UPDATED LOGIC FOR EQUATABLE ---
    final currentState = state;
    // We only want to show the typing indicator if we are already in a loaded state.
    if (currentState is ChatLoaded) {
      // 1. Immediately emit a new state to show the typing indicator
      //    using the 'copyWith' method from your ChatLoaded state.
      emit(currentState.copyWith(isTyping: true));
    }

    try {
      // 2. Call the function and save the message as before.
      final translationData = await _chatService.getTranslation(event.content);
      await _chatService.saveMessage(
        originalContent: event.content,
        translationData: translationData,
      );
      // 3. We don't need to do anything else. The real-time stream will
      //    trigger _onMessagesReceived, which will hide the indicator automatically.
    } catch (e) {
      emit(ChatError('Failed to send message: ${e.toString()}'));
      // If there's an error, turn off the typing indicator.
      if (currentState is ChatLoaded) {
        emit(currentState.copyWith(isTyping: false));
      }
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
