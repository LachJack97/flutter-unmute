import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart'; // Import for firstWhereOrNull
import 'package:unmute/features/chat/data/repositories/chat_service.dart';
import 'package:unmute/features/chat/domain/entities/message_entity.dart';
import 'package:unmute/features/chat/presentation/bloc/chat_event.dart';
import 'package:unmute/features/chat/presentation/bloc/chat_state.dart';
import 'package:unmute/features/chat/presentation/widgets/language_selector_pill.dart'; // Import Language and defaults
import 'package:uuid/uuid.dart'; // For generating temporary unique IDs
// Consider importing FunctionsHttpError if you want to type check specifically:
// import 'package:functions_client/functions_client.dart'; // For FunctionsHttpError

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
    on<ChatStreamErrorOccurred>(_onChatStreamErrorOccurred);
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
          onError: (e) => add(ChatStreamErrorOccurred(e.toString())),
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
      emit(const ChatError('User not authenticated. Cannot send message.'));
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
      print("[ChatBloc] Error in _onMessageSent: ${e.toString()}");
      String userFriendlyMessage = 'Failed to send message.';

      // Attempt to extract a more specific error message dynamically
      dynamic errorDetails;
      int? errorStatus;

      try {
        errorDetails = (e as dynamic).details;
      } catch (_) { /* details not found */ }

      try {
        errorStatus = (e as dynamic).status ?? (e as dynamic).code;
      } catch (_) { /* status/code not found */ }

      if (errorDetails is Map && errorDetails.containsKey('error')) {
        userFriendlyMessage = 'Failed to send message: ${errorDetails['error']}';
      } else if (errorDetails is String && errorDetails.isNotEmpty) {
        userFriendlyMessage = 'Failed to send message: $errorDetails';
      } else if (errorStatus != null) {
        userFriendlyMessage = 'Failed to send message. Server error (code: $errorStatus).';
      } else if (e is Exception) {
        final eStr = e.toString();
        userFriendlyMessage = 'Failed to send message: ${eStr.replaceFirst("Exception: ", "")}';
      } else {
        userFriendlyMessage = 'Failed to send message due to an unexpected server error.';
      }

      emit(ChatError(userFriendlyMessage));
      // The UI should hide the typing indicator upon receiving ChatError.
      // The previous emit of initialChatLoadedState.copyWith(isTyping: false)
      // was incorrect as it would overwrite the ChatError state.
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
    print("[ChatBloc] _onImageMessageSent: Received imageFile: ${event.imageFile.path}, targetLang: ${event.targetLanguageCode}");
    final initialChatLoadedState = state;
    if (initialChatLoadedState is! ChatLoaded) {
      emit(const ChatError('Cannot process image if chat is not loaded.'));
      return;
    }
    if (event.targetLanguageCode == null) {
      // This should be prevented by UI if no language is selected.
      emit(const ChatError(
          'Target language not selected for OCR.')); // Added const
      return;
    }

    final userId = _chatService.currentUserId;
    if (userId == null) {
      emit(const ChatError('User not authenticated. Cannot send image.'));
      return;
    }

    // Optimistic UI update with localImagePath and isUploadingImage = true
    final String tempId = 'local_${const Uuid().v4()}';
    final optimisticMessage = MessageEntity(
      id: tempId,
      content: '', // Content will be "📷 Image" after processing
      senderId: userId,
      createdAt: DateTime.now(),
      localImagePath: event.imageFile.path,
      isUploadingImage: true,
    );

    emit(initialChatLoadedState.copyWith(
      messages: List<MessageEntity>.from(initialChatLoadedState.messages)
        ..insert(0, optimisticMessage),
      // isTyping: false, // Keep global isTyping as is, or manage separately.
      // The optimisticMessage.isUploadingImage will handle its own loading state.
    ));

    try {
      final Uint8List imageBytes = await event.imageFile.readAsBytes();
      print("[ChatBloc] Calling _chatService.performOcrAndTranslate...");
      // Perform OCR and get translation data (which includes extracted text)
      final ocrTranslationData = await _chatService.performOcrAndTranslate(
          imageBytes, event.targetLanguageCode!);

      print("[ChatBloc] ocrTranslationData received: $ocrTranslationData");

      String? ocrMarkdownOutput; // This will hold the text from the AI
      Map<String, dynamic> translationDataToSave;

      // Handle the new Edge Function response structure: {"markdown_output": "..."}
      if (ocrTranslationData.containsKey('markdown_output')) {
        ocrMarkdownOutput = ocrTranslationData['markdown_output'] as String?;
        // Since the new format provides all content in markdown_output,
        // other translation-specific fields are considered not applicable for separate display.
        // The OCR markdown will go into the 'output' field of the message.
        translationDataToSave = {
          'utterance': ocrMarkdownOutput, // OCR text goes into 'utterance' to populate message.output
          'romanization': null,
          'breakdown': null,
          'detected_language': null, // Not provided by the new Edge Function format
        };
        print("[ChatBloc] Parsed 'markdown_output' structure from OCR function.");
        if (ocrMarkdownOutput == null || ocrMarkdownOutput.isEmpty) {
          print("[ChatBloc] 'markdown_output' is null or empty.");
          throw Exception('AI function returned empty content for the image.');
        }
      } else {
        // Fallback or error for unexpected structure from the OCR function
        print("[ChatBloc] Unexpected response structure from OCR function: $ocrTranslationData");
        throw Exception('Unexpected response structure from AI image processing function.');
      }

      // Determine content for the user's bubble (originalContent)
      String userBubbleContent;

      String? uploadedImageUrl;
      try {
        // Create a unique file name for the image
        final String fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.png';
        print("[ChatBloc] Uploading image with fileName: $fileName");
        uploadedImageUrl = await _chatService.uploadImage(
            imageBytes: imageBytes, fileName: fileName);
        print("[ChatBloc] Image uploaded, URL: $uploadedImageUrl");
        userBubbleContent = "📷 Image"; // This will be message.content for the user's bubble
      } catch (e) {
        print("[ChatBloc] Failed to upload image: $e. Proceeding without image URL.");
        userBubbleContent = "⚠️ Image (upload failed)"; // Placeholder for user's bubble
        // Non-critical error for now, message will be saved without image URL.
      }

      print(
          "[ChatBloc] Calling _chatService.saveMessage with userBubbleContent: $userBubbleContent, imageUrl: $uploadedImageUrl");
      await _chatService.saveMessage(
        originalContent: userBubbleContent, // This is for the user's bubble (message.content)
        translationData: translationDataToSave,
        targetLanguage: event.targetLanguageCode!, // Added null assertion
        imageUrl: uploadedImageUrl, // Pass the URL here
      );
      // The stream listener (_onMessagesReceived) will update the UI with the new message.
      // The ChatLoaded state emitted by _onMessagesReceived will set isTyping to false.
      // The optimistic message (with 'local_' ID) will be implicitly removed when the
      // new list of messages from the database is emitted by _onMessagesReceived.
    } catch (e) {
      print(
          "[ChatBloc] Error in _onImageMessageSent: ${e.toString()}"); // Debug print
      String userFriendlyMessage = 'Failed to process image.';

      // Attempt to extract a more specific error message dynamically
      dynamic errorDetails;
      int? errorStatus;

      try {
        errorDetails = (e as dynamic).details;
      } catch (_) { /* details not found */ }

      try {
        errorStatus = (e as dynamic).status ?? (e as dynamic).code;
      } catch (_) { /* status/code not found */ }

      if (errorDetails is Map && errorDetails.containsKey('error')) {
        userFriendlyMessage = 'Failed to process image: ${errorDetails['error']}';
      } else if (errorDetails is String && errorDetails.isNotEmpty) {
        userFriendlyMessage = 'Failed to process image: $errorDetails';
      } else if (errorStatus != null) {
        userFriendlyMessage = 'Failed to process image. Server error (code: $errorStatus).';
      } else if (e is Exception) {
        final eStr = e.toString();
        userFriendlyMessage = 'Failed to process image: ${eStr.replaceFirst("Exception: ", "")}';
      } else {
        userFriendlyMessage = 'Failed to process image due to an unexpected server error.';
      }
      emit(ChatError(userFriendlyMessage));
      // Remove the optimistic message on error
      if (state is ChatLoaded) {
        final currentMessages = (state as ChatLoaded).messages;
        final updatedMessages = currentMessages.where((msg) => msg.id != tempId).toList();
        emit((state as ChatLoaded).copyWith(messages: updatedMessages, isTyping: false));
      } else {
        emit(initialChatLoadedState.copyWith(isTyping: false));
      }
      // The UI should hide the typing indicator upon receiving ChatError.
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

  void _onChatStreamErrorOccurred(
    ChatStreamErrorOccurred event,
    Emitter<ChatState> emit,
  ) {
    emit(ChatError(event.errorMessage));
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
