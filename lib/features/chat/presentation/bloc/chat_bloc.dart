import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unmute/features/chat/data/repositories/chat_service.dart';
import 'package:unmute/features/chat/domain/entities/message_entity.dart';
import 'package:unmute/features/chat/presentation/bloc/chat_event.dart';
import 'package:unmute/features/chat/presentation/bloc/chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService;
  StreamSubscription<List<MessageEntity>>? _messageSubscription;
  String _currentLanguageCode = "en"; // Default language, managed internally.

  ChatBloc({required ChatService chatService})
      : _chatService = chatService,
        super(const ChatInitial()) {
    on<SubscriptionRequested>(_onSubscriptionRequested);
    on<MessageSent>(_onMessageSent);
    on<MessagesReceived>(_onMessagesReceived);
    on<LanguageChanged>(_onLanguageChanged);
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
    emit(ChatLoaded(messages: event.messages));
  }

  Future<void> _onMessageSent(
    MessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is ChatLoaded) {
      emit(currentState.copyWith(isTyping: true));
    }

    try {
      final translationData = await _chatService.getTranslation(
          event.content, _currentLanguageCode);
      await _chatService.saveMessage(
        originalContent: event.content,
        translationData: translationData,
      );

      if (currentState is ChatLoaded) {
        emit(currentState.copyWith(isTyping: false));
      }
    } catch (e) {
      emit(ChatError('Failed to send message: ${e.toString()}'));
      if (currentState is ChatLoaded) {
        emit(currentState.copyWith(isTyping: false));
      }
    }
  }

  Future<void> _onLanguageChanged(
    LanguageChanged event,
    Emitter<ChatState> emit,
  ) async {
    _currentLanguageCode = event.languageCode;
    await _chatService.setTargetLanguage(_currentLanguageCode);
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}

class LanguageChanged extends ChatEvent {
  final String languageCode;

  const LanguageChanged(this.languageCode);

  @override
  List<Object> get props => [languageCode];
}
