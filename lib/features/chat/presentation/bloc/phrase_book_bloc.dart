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
      if (event.message.output == null || event.message.output!.isEmpty) {
        return;
      }
      await _chatService.addFavoritePhrase(
        originalContent: event.message.content,
        translatedOutput: event.message.output!,
        targetLanguageCode: event.message.targetLanguage ?? 'unknown',
        romanisation: event.message.romanisation,
        // FIX: Pass the detected language from the message
        language: event.message.detectedLanguageCode,
      );
      
      // This line is from a previous fix, it's correct to keep it.
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