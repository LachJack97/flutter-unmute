import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unmute/features/chat/data/repositories/chat_service.dart'; // Ensure this path is correct
import 'package:unmute/features/chat/domain/entities/message_entity.dart'; // Ensure this path is correct

// Import the newly created event and state files
import 'package:unmute/features/chat/presentation/bloc/chat_event.dart';
import 'package:unmute/features/chat/presentation/bloc/chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService;
  StreamSubscription<List<MessageEntity>>? _messageSubscription;

  ChatBloc({required ChatService chatService})
      : _chatService = chatService,
        super(const ChatInitial()) {
    // Start with ChatInitial state
    on<SubscriptionRequested>(_onSubscriptionRequested);
    on<MessageSent>(_onMessageSent);
    on<MessagesReceived>(_onMessagesReceived);
  }

  /// Subscribes to the real-time message stream from the ChatService.
  void _onSubscriptionRequested(
    SubscriptionRequested event, // Use the non-underscored type
    Emitter<ChatState> emit,
  ) {
    emit(const ChatLoading()); // Emit loading state
    _messageSubscription?.cancel(); // Cancel previous subscription if any
    _messageSubscription = _chatService.getMessages().listen(
          (messages) =>
              add(MessagesReceived(messages)), // Add MessagesReceived event
          onError: (e) => emit(ChatError(e.toString())), // Emit error state
        );
  }

  /// Receives new messages from the stream and updates the state.
  void _onMessagesReceived(
    MessagesReceived event, // Use the non-underscored type
    Emitter<ChatState> emit,
  ) {
    emit(ChatLoaded(
        messages: event.messages)); // Emit loaded state with messages
  }

  /// Orchestrates the client-side process of sending a message.
  Future<void> _onMessageSent(
    MessageSent event, // Use the non-underscored type
    Emitter<ChatState> emit,
  ) async {
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
      // The UI will update automatically via the real-time stream via _onMessagesReceived
    } catch (e) {
      print("BLOC ERROR: Caught an exception -> ${e.toString()}");
      emit(ChatError('Failed to send message: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
