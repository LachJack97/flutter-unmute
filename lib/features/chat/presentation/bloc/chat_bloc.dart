import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart'; // Import for firstWhereOrNull
import 'package:unmute/features/chat/data/repositories/chat_service.dart';
import 'package:unmute/features/chat/domain/entities/message_entity.dart';
import 'package:unmute/features/chat/presentation/bloc/chat_event.dart';
import 'package:unmute/features/chat/presentation/bloc/chat_state.dart';
import 'package:unmute/features/chat/presentation/widgets/language_selector_pill.dart'; // Import Language and defaults

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService;
  StreamSubscription<List<MessageEntity>>? _messageSubscription;
  Language? _currentTargetLanguage; // Now nullable, initialized to null

  ChatBloc({required ChatService chatService})
      : _chatService = chatService,
        super(const ChatInitial()) {
    on<SubscriptionRequested>(_onSubscriptionRequested);
    on<MessageSent>(_onMessageSent);
    on<MessagesReceived>(_onMessagesReceived);
    on<LanguageChanged>(_onLanguageChanged);
    on<ChatHistoryCleared>(_onChatHistoryCleared);
    on<ImageMessageSent>(_onImageMessageSent);
  }

  Future<void> _onSubscriptionRequested(
    SubscriptionRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());

    // Attempt to load the user's preferred target language
    try {
      final String? targetLangCode = await _chatService.getTargetLanguage();
      if (targetLangCode != null) {
        // Use firstWhereOrNull to safely handle cases where the code might not match
        _currentTargetLanguage =
            LanguageSelectorPill.availableLanguages.firstWhereOrNull(
          (lang) => lang.code == targetLangCode,
        );
      } else {
        _currentTargetLanguage =
            null; // Explicitly set to null if no preference found
      }
    } catch (e) {
      // Consider using a logger here instead of print
      _currentTargetLanguage = null; // Default to null on error
    }

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
    emit(ChatLoaded(
      messages: event.messages,
      selectedLanguage: _currentTargetLanguage,
    ));
  }

  Future<void> _onMessageSent(
    MessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final initialChatLoadedState = state;
    if (initialChatLoadedState is! ChatLoaded) {
      // Should not happen if subscription is established and UI allows sending.
      // If it's ChatInitial or ChatLoading, we might not have a messages list.
      return;
    }

    final userId = _chatService.currentUserId;
    if (userId == null) {
      emit(ChatError('User not authenticated. Cannot send message.'));
      // If for some reason isTyping was true, reset it.
      if (initialChatLoadedState.isTyping) {
        emit(initialChatLoadedState.copyWith(isTyping: false));
      }
      return;
    }

    // Create a temporary message for optimistic UI update
    final tempMessage = MessageEntity(
      // Cannot be const due to DateTime.now()
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      content: event.content,
      senderId: userId,
      createdAt: DateTime.now(),
      // output, targetLanguage, romanisation, breakdown will be null initially
    );

    // Emit new state with the temporary message and set isTyping to true
    emit(initialChatLoadedState.copyWith(
      messages: List.from(initialChatLoadedState.messages)..add(tempMessage),
      isTyping: true,
    ));

    try {
      if (_currentTargetLanguage == null) {
        // This case should ideally be prevented by the UI (e.g., disable send button)
        throw Exception("Target language not selected.");
      }
      // First, get the translation data which includes the detected language
      final translationData = await _chatService.getTranslation(
          event.content, _currentTargetLanguage!.code); // Added null assertion

      String? detectedLanguageCode =
          translationData['detected_language'] as String?;

      // Prepare the data to be saved, potentially modifying it if no translation is needed
      Map<String, dynamic> effectiveTranslationData;

      if (detectedLanguageCode != null &&
          detectedLanguageCode == _currentTargetLanguage!.code) {
        // Added null assertion
        // Source and target languages are the same.
        // Set translation-specific fields to null so the AI bubble doesn't show a redundant translation.
        effectiveTranslationData = {
          'utterance': null, // This will result in message.output being null
          'romanization': null,
          'breakdown': null,
          'detected_language':
              detectedLanguageCode, // Still save the detected language
        };
      } else {
        // Languages are different, use the full translation data from the function
        effectiveTranslationData = translationData;
      }

      await _chatService.saveMessage(
        originalContent: event.content,
        translationData: effectiveTranslationData, // Use the processed data
        targetLanguage: _currentTargetLanguage!.code, // Added null assertion
      );
      // On success, the stream listener (_onMessagesReceived) will update the list
      // with the final message from the DB (including ID and translation).
      // That handler's ChatLoaded emission will also set isTyping to false by default.
    } catch (e) {
      emit(ChatError('Failed to send message: ${e.toString()}'));
      // On error, revert to the state before the optimistic update (remove tempMessage)
      // and ensure isTyping is false.
      emit(initialChatLoadedState.copyWith(isTyping: false));
    }
  }

  Future<void> _onLanguageChanged(
    LanguageChanged event,
    Emitter<ChatState> emit,
  ) async {
    _currentTargetLanguage = event.language;
    await _chatService.setTargetLanguage(_currentTargetLanguage!
        .code); // Added null check, assuming language in event is never null

    // If already loaded, update the state with the new language
    if (state is ChatLoaded) {
      final currentLoadedState = state as ChatLoaded;
      emit(currentLoadedState.copyWith(
        selectedLanguage: _currentTargetLanguage,
      ));
    }
    // If not ChatLoaded, the next MessagesReceived or initial load will pick up the changes.
  }

  Future<void> _onImageMessageSent(
    ImageMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    print(
        "[ChatBloc] _onImageMessageSent: Received imageBytes (length: ${event.imageBytes.length}), targetLang: ${event.targetLanguageCode}");
    final initialChatLoadedState = state;
    if (initialChatLoadedState is! ChatLoaded) {
      emit(ChatError('Cannot process image if chat is not loaded.'));
      return;
    }
    if (event.targetLanguageCode == null) {
      // This should be prevented by UI if no language is selected.
      emit(const ChatError(
          'Target language not selected for OCR.')); // Added const
      return;
    }

    // Optionally, show a temporary message or different typing indicator for image processing
    // For now, we'll just use the existing isTyping.
    emit(initialChatLoadedState.copyWith(isTyping: true));

    try {
      print(
          "[ChatBloc] Calling _chatService.performOcrAndTranslate..."); // Debug print
      // Perform OCR and get translation data (which includes extracted text)
      final ocrTranslationData = await _chatService.performOcrAndTranslate(
          event.imageBytes, event.targetLanguageCode!);

      print("[ChatBloc] ocrTranslationData received: $ocrTranslationData");
      // The Edge function should return 'extracted_text' and the usual translation fields
      // for the *translated extracted text*.
      final String? extractedText =
          ocrTranslationData['extracted_text'] as String?;
      print("[ChatBloc] Extracted text from OCR: $extractedText");
      if (extractedText == null || extractedText.isEmpty) {
        print("[ChatBloc] OCR failed: extractedText is null or empty.");
        throw Exception(
            'OCR failed to extract text from the image.'); // Debug print; Consider a more specific error type
      }

      // Save the message. The 'originalContent' will be the text extracted from the image.
      // The 'translationData' will contain the translation of this extracted text.
      print(
          "[ChatBloc] Calling _chatService.saveMessage with extractedText: $extractedText"); // Debug print
      await _chatService.saveMessage(
        originalContent:
            extractedText, // Text from OCR is the "original" for this message
        translationData:
            ocrTranslationData, // Contains translation of extractedText
        targetLanguage: event.targetLanguageCode!, // Added null assertion
      );
      // The stream listener (_onMessagesReceived) will update the UI with the new message.
      // The ChatLoaded state emitted by _onMessagesReceived will set isTyping to false.
    } catch (e) {
      print(
          "[ChatBloc] Error in _onImageMessageSent: ${e.toString()}"); // Debug print
      emit(ChatError('Failed to process image: ${e.toString()}'));
      // Revert isTyping state on error
      if (state is ChatLoaded) {
        // Check current state again
        emit((state as ChatLoaded).copyWith(isTyping: false));
      } else {
        // If state changed to something else (e.g. ChatError already), emit based on initial
        emit(initialChatLoadedState.copyWith(isTyping: false));
      }
    }
  }

  Future<void> _onChatHistoryCleared(
    ChatHistoryCleared event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoaded) {
      // Optimistically update the UI to show an empty list immediately.
      // Keep the selectedLanguage from the current state.
      emit((state as ChatLoaded).copyWith(messages: [], isTyping: false));
    }

    try {
      await _chatService.clearChatHistory();
      // The message stream should automatically update to an empty list.
      // If not, you might need to explicitly emit ChatLoaded with empty messages.
      // The optimistic update above should handle the immediate UI change.
      // If the stream sends an update later, it will just confirm the empty state
      // or show any new messages that might have arrived post-clear.
    } catch (e) {
      emit(ChatError('Failed to clear chat history: ${e.toString()}'));
      // If clearing failed, you might want to revert to the previous state
      // or fetch messages again, but for now, ChatError is emitted.
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
