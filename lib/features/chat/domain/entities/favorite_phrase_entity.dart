import 'package:equatable/equatable.dart';

class FavoritePhraseEntity extends Equatable {
  final String id;
  final String language;
  final String userId;
  final String originalContent;
  final String translatedOutput;
  final String targetLanguageCode;
  final String? romanisation;
  final DateTime createdAt;

  const FavoritePhraseEntity({
    required this.id,
    required this.language,
    required this.userId,
    required this.originalContent,
    required this.translatedOutput,
    required this.targetLanguageCode,
    this.romanisation,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        language,
        userId,
        originalContent,
        translatedOutput,
        targetLanguageCode,
        romanisation,
        createdAt,
      ];
}
