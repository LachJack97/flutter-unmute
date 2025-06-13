import 'package:equatable/equatable.dart';
import 'package:unmute/features/chat/domain/entities/message_entity.dart';

abstract class PhraseBookEvent extends Equatable {
  const PhraseBookEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavoritePhrases extends PhraseBookEvent {
  const LoadFavoritePhrases();
}

class AddPhraseToFavorites extends PhraseBookEvent {
  final MessageEntity
      message; // Pass the whole message to extract necessary data

  const AddPhraseToFavorites({required this.message});

  @override
  List<Object?> get props => [message];
}

class RemovePhraseFromFavorites extends PhraseBookEvent {
  final String favoritePhraseId;

  const RemovePhraseFromFavorites({required this.favoritePhraseId});

  @override
  List<Object?> get props => [favoritePhraseId];
}
