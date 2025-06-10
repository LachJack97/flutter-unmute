import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unmute/features/chat/data/repositories/chat_service.dart';
import 'package:collection/collection.dart'; // Import collection for firstWhereOrNull
import 'package:unmute/features/chat/domain/entities/message_entity.dart';
import 'package:unmute/features/chat/presentation/bloc/chat_event.dart';
import 'package:unmute/features/chat/presentation/bloc/chat_state.dart';
import 'package:unmute/features/chat/presentation/widgets/language_selector_pill.dart'; // Import Language and defaults

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService;
  StreamSubscription<List<MessageEntity>>? _messageSubscription;
  Language _currentTargetLanguage = LanguageSelectorPill.defaultLanguage;
  Language? _nativeLanguage;

  ChatBloc({required ChatService chatService})
      : _chatService = chatService,
        super(const ChatInitial()) {
    on<SubscriptionRequested>(_onSubscriptionRequested);
    on<MessageSent>(_onMessageSent);
    on<MessagesReceived>(_onMessagesReceived);
    on<LanguageChanged>(_onLanguageChanged);
    on<ChatHistoryCleared>(_onChatHistoryCleared);
    on<NativeLanguageSet>(_onNativeLanguageSet);
  }

  Future<void> _onSubscriptionRequested(
    SubscriptionRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());

    // Attempt to load the user's native language first
    try {
      final String? nativeLangCode = await _chatService.getNativeLanguage();
      if (nativeLangCode != null) {
        _nativeLanguage =
            LanguageSelectorPill.availableLanguages.firstWhereOrNull(
          (lang) => lang.code == nativeLangCode,
        );
      }
    } catch (e) {
      print("Error loading native language: $e");
      _nativeLanguage = null; // Default to no native language if error
    }

    // Attempt to load the user's preferred target language
    try {
      final String? targetLangCode = await _chatService.getTargetLanguage();
      if (targetLangCode != null) {
        final prefTargetLang =
            LanguageSelectorPill.availableLanguages.firstWhere(
          (lang) => lang.code == targetLangCode,
          orElse: () => LanguageSelectorPill.defaultLanguage,
        );
        _currentTargetLanguage = prefTargetLang;
      }
    } catch (e) {
      print("Error loading target language preference: $e");
      // Keep _currentTargetLanguage as default if loading fails
    }

    // Filter translatable languages for the pill (excluding native language)
    List<Language> translatableLanguagesForPill = LanguageSelectorPill
        .availableLanguages
        .where((lang) => lang.code != _nativeLanguage?.code)
        .toList();

    if (translatableLanguagesForPill.isEmpty) {
      // Fallback if filtering results in an empty list (e.g., only one language defined and it's native)
      translatableLanguagesForPill = [
        LanguageSelectorPill.defaultLanguage
      ]; // Or handle error
    }

    // If current target language is the native language, reset target to a valid translatable one
    if (_nativeLanguage != null &&
        _currentTargetLanguage.code == _nativeLanguage!.code) {
      _currentTargetLanguage = translatableLanguagesForPill.firstWhere(
        (lang) => lang.code != _nativeLanguage?.code, // Ensure it's not native
        orElse: () => translatableLanguagesForPill.isNotEmpty
            ? translatableLanguagesForPill.first
            : LanguageSelectorPill.defaultLanguage, // Fallback
      );
      // Persist this change if needed, or let user re-select
      // await _chatService.setTargetLanguage(_currentTargetLanguage.code);
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
    // Ensure translatableLanguagesForPill is up-to-date based on _nativeLanguage
    final translatableLanguagesForPill = LanguageSelectorPill.availableLanguages
        .where((lang) => lang.code != _nativeLanguage?.code)
        .toList();

    emit(ChatLoaded(
      messages: event.messages,
      selectedLanguage: _currentTargetLanguage,
      nativeLanguage: _nativeLanguage,
      translatableLanguagesForPill: translatableLanguagesForPill.isNotEmpty
          ? translatableLanguagesForPill
          : [LanguageSelectorPill.defaultLanguage],
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
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}', // Client-side temporary ID
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
      // First, get the translation data which includes the detected language
      final translationData = await _chatService.getTranslation(
          event.content, _currentTargetLanguage.code);

      String? detectedLanguageCode =
          translationData['detected_language'] as String?;

      // Prepare the data to be saved, potentially modifying it if no translation is needed
      Map<String, dynamic> effectiveTranslationData;

      if (detectedLanguageCode != null &&
          detectedLanguageCode == _currentTargetLanguage.code) {
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
        targetLanguage: _currentTargetLanguage.code,
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
    await _chatService.setTargetLanguage(_currentTargetLanguage.code);

    // If already loaded, update the state with the new language
    if (state is ChatLoaded) {
      // Keep native language and re-filter translatable languages if necessary (though not strictly needed here)
      final currentLoadedState = state as ChatLoaded;
      final translatableLanguagesForPill = LanguageSelectorPill
          .availableLanguages
          .where((lang) => lang.code != _nativeLanguage?.code)
          .toList();

      emit(currentLoadedState.copyWith(
          selectedLanguage: _currentTargetLanguage,
          translatableLanguagesForPill: translatableLanguagesForPill.isNotEmpty
              ? translatableLanguagesForPill
              : [LanguageSelectorPill.defaultLanguage]));
    }
  }

  Future<void> _onNativeLanguageSet(
    NativeLanguageSet event,
    Emitter<ChatState> emit,
  ) async {
    _nativeLanguage = event.language;
    await _chatService.setNativeLanguage(_nativeLanguage!.code);

    // Re-filter translatable languages
    List<Language> translatableLanguagesForPill = LanguageSelectorPill
        .availableLanguages
        .where((lang) => lang.code != _nativeLanguage?.code)
        .toList();

    if (translatableLanguagesForPill.isEmpty) {
      translatableLanguagesForPill = [LanguageSelectorPill.defaultLanguage];
    }

    // If current target language is now the native language, reset target
    if (_currentTargetLanguage.code == _nativeLanguage!.code) {
      _currentTargetLanguage =
          translatableLanguagesForPill.first; // Or more sophisticated selection
      await _chatService.setTargetLanguage(_currentTargetLanguage.code);
    }

    if (state is ChatLoaded) {
      emit((state as ChatLoaded).copyWith(
        nativeLanguage: _nativeLanguage,
        selectedLanguage:
            _currentTargetLanguage, // selectedLanguage is the target language
        translatableLanguagesForPill: translatableLanguagesForPill,
      ));
    }
    // If not ChatLoaded, the next MessagesReceived or initial load will pick up the changes.
  }

  Future<void> _onChatHistoryCleared(
    ChatHistoryCleared event,
    Emitter<ChatState> emit,
  ) async {
    // Optionally, show a loading or processing state if deletion takes time
    // if (state is ChatLoaded) {
    //   emit((state as ChatLoaded).copyWith(messages: [])); // Optimistic update
    // }
    try {
      await _chatService.clearChatHistory();
      // The message stream should automatically update to an empty list.
      // If not, you might need to explicitly emit ChatLoaded with empty messages.
    } catch (e) {
      emit(ChatError('Failed to clear chat history: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
