import 'package:equatable/equatable.dart';
import 'package:unmute/features/chat/domain/entities/favorite_phrase_entity.dart';

abstract class PhraseBookState extends Equatable {
  const PhraseBookState();

  @override
  List<Object?> get props => [];
}

class PhraseBookInitial extends PhraseBookState {
  const PhraseBookInitial();
}

class PhraseBookLoading extends PhraseBookState {
  const PhraseBookLoading();
}

class PhraseBookLoaded extends PhraseBookState {
  final Map<String, List<FavoritePhraseEntity>> groupedPhrases;

  const PhraseBookLoaded({required this.groupedPhrases});

  @override
  List<Object> get props => [groupedPhrases];

  Map<String, List<FavoritePhraseEntity>> getFilteredPhrases(String searchQuery) {
    if (searchQuery.isEmpty) {
      return groupedPhrases;
    }

    final lowerCaseQuery = searchQuery.toLowerCase();
    final filteredMap = <String, List<FavoritePhraseEntity>>{};

    groupedPhrases.forEach((languageCode, phrases) {
      final filteredPhrases = phrases.where((phrase) {
        final matchesOriginal = phrase.originalContent.toLowerCase().contains(lowerCaseQuery);
        final matchesTranslated = phrase.translatedOutput.toLowerCase().contains(lowerCaseQuery);
        // Optionally, match romanisation if it exists
        final matchesRomanisation = phrase.romanisation?.toLowerCase().contains(lowerCaseQuery) ?? false;
        return matchesOriginal || matchesTranslated || matchesRomanisation;
      }).toList();

      if (filteredPhrases.isNotEmpty) {
        filteredMap[languageCode] = filteredPhrases;
      }
    });

    return filteredMap;
  }
}

class PhraseBookError extends PhraseBookState {
  final String message;

  const PhraseBookError({required this.message});

  @override
  List<Object?> get props => [message];
}
