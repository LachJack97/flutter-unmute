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
  final List<FavoritePhraseEntity> favoritePhrases;

  const PhraseBookLoaded({required this.favoritePhrases});

  @override
  List<Object?> get props => [favoritePhrases];
}

class PhraseBookError extends PhraseBookState {
  final String message;

  const PhraseBookError({required this.message});

  @override
  List<Object?> get props => [message];
}
