import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unmute/features/chat/data/repositories/chat_service.dart';
import 'package:unmute/features/chat/domain/entities/favorite_phrase_entity.dart';
import 'package:unmute/features/chat/presentation/bloc/phrase_book_event.dart';
import 'package:unmute/features/chat/presentation/bloc/phrase_book_state.dart';

class PhraseBookBloc extends Bloc<PhraseBookEvent, PhraseBookState> {
  final ChatService _chatService;
  StreamSubscription<List<FavoritePhraseEntity>>? _favoritesSubscription;

  PhraseBookBloc({required ChatService chatService})
      : _chatService = chatService,
        super(const PhraseBookInitial()) {
    on<LoadFavoritePhrases>(_onLoadFavoritePhrases);
    on<AddPhraseToFavorites>(_onAddPhraseToFavorites);
    on<RemovePhraseFromFavorites>(_onRemovePhraseFromFavorites);
    on<_FavoritePhrasesUpdated>(_onFavoritePhrasesUpdated);
  }

  void _onLoadFavoritePhrases(
    LoadFavoritePhrases event,
    Emitter<PhraseBookState> emit,
  ) {
    emit(const PhraseBookLoading());
    _favoritesSubscription?.cancel();
    _favoritesSubscription = _chatService.getFavoritePhrases().listen(
          (phrases) => add(_FavoritePhrasesUpdated(phrases)),
          onError: (error) => emit(PhraseBookError(message: error.toString())),
        );
  }

  void _onFavoritePhrasesUpdated(
  _FavoritePhrasesUpdated event,
  Emitter<PhraseBookState> emit,
) {
  final grouped = <String, List<FavoritePhraseEntity>>{};
  for (final phrase in event.phrases) {
    // CORRECTED: Use the existing field name from your entity
    (grouped[phrase.targetLanguageCode] ??= []).add(phrase);
  }
  emit(PhraseBookLoaded(groupedPhrases: grouped));
}
// lib/features/chat/presentation/bloc/phrase_book_bloc.dart

 // lib/features/chat/presentation/bloc/phrase_book_bloc.dart

  Future<void> _onAddPhraseToFavorites(
    AddPhraseToFavorites event,
    Emitter<PhraseBookState> emit,
  ) async {
    try {
      final message = event.message;
      String originalContent = message.content;
      String? translatedOutput = message.output;
      String? targetLanguageCode = message.targetLanguage;
      String? detectedLanguage = message.detectedLanguageCode;

      // If output is null or empty, but it's because source and target lang are the same,
      // then the 'translatedOutput' for the favorite can be the original content itself.
      if ((translatedOutput == null || translatedOutput.isEmpty) &&
          detectedLanguage != null &&
          targetLanguageCode != null &&
          detectedLanguage == targetLanguageCode) {
        translatedOutput = originalContent; // Use original content as "translated"
      }

      // If after the above logic, translatedOutput is still null or empty, then don't add.
      if (translatedOutput == null || translatedOutput.isEmpty) {
        // Optionally, emit an informational state or log this
        print("PhraseBookBloc: Cannot add favorite, translated output is effectively empty for message ID: ${message.id}");
        return;
      }

      await _chatService.addFavoritePhrase(
        originalContent: originalContent,
        translatedOutput: translatedOutput,
        targetLanguageCode: targetLanguageCode ?? 'unknown',
        romanisation: message.romanisation,
        language: detectedLanguage, // This is the original detected language of the input
      );
      
      add(const LoadFavoritePhrases());
    } catch (e) {
      emit(PhraseBookError(message: "Failed to add favorite: ${e.toString()}"));
    }
  }

  Future<void> _onRemovePhraseFromFavorites(
    RemovePhraseFromFavorites event,
    Emitter<PhraseBookState> emit,
  ) async {
    try {
      await _chatService.removeFavoritePhrase(event.favoritePhraseId);

      add(const LoadFavoritePhrases());
    } catch (e) {
      emit(PhraseBookError(
          message: "Failed to remove favorite: ${e.toString()}"));
    }
  }

  @override
  Future<void> close() {
    _favoritesSubscription?.cancel();
    return super.close();
  }
}

// Internal event for BLoC to react to stream updates
class _FavoritePhrasesUpdated extends PhraseBookEvent {
  final List<FavoritePhraseEntity> phrases;
  const _FavoritePhrasesUpdated(this.phrases);

  @override
  List<Object?> get props => [phrases];
}