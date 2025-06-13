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
    emit(PhraseBookLoaded(favoritePhrases: event.phrases));
  }

  Future<void> _onAddPhraseToFavorites(
    AddPhraseToFavorites event,
    Emitter<PhraseBookState> emit,
  ) async {
    try {
      // Ensure there's something to save as translatedOutput
      if (event.message.output == null || event.message.output!.isEmpty) {
        // Optionally emit an error or handle silently
        print("Cannot add to favorites: translated output is missing.");
        return;
      }
      await _chatService.addFavoritePhrase(
        originalContent: event.message.content,
        translatedOutput: event.message.output!,
        targetLanguageCode:
            event.message.targetLanguage ?? 'unknown', // Provide a fallback
        romanisation: event.message.romanisation,
      );
      // Optimistically update the state if currently loaded
      if (state is PhraseBookLoaded) {
        // To properly update, we'd ideally get the newly created FavoritePhraseEntity
        // back from addFavoritePhrase or simulate it. For simplicity, we'll re-trigger a load
        // which will pick up the new item via the stream.
        // A more advanced optimistic update would construct the FavoritePhraseEntity locally.
        add(const LoadFavoritePhrases()); // Re-fetch to ensure UI updates
      }
    } catch (e) {
      emit(PhraseBookError(message: "Failed to add favorite: ${e.toString()}"));
    }
  }

  Future<void> _onRemovePhraseFromFavorites(
    RemovePhraseFromFavorites event,
    Emitter<PhraseBookState> emit,
  ) async {
    final currentState = state;
    try {
      await _chatService.removeFavoritePhrase(event.favoritePhraseId);
      // Optimistically update the state if currently loaded
      if (currentState is PhraseBookLoaded) {
        final updatedList = currentState.favoritePhrases
            .where((phrase) => phrase.id != event.favoritePhraseId)
            .toList();
        emit(PhraseBookLoaded(favoritePhrases: updatedList));
      }
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
