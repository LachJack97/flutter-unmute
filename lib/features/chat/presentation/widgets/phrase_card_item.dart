import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unmute/features/chat/domain/entities/favorite_phrase_entity.dart';
import 'package:unmute/features/chat/presentation/bloc/phrase_book_bloc.dart';
import 'package:unmute/features/chat/presentation/bloc/phrase_book_event.dart';

class PhraseCardItem extends StatelessWidget {
  final FavoritePhraseEntity phrase;

  const PhraseCardItem({
    super.key,
    required this.phrase,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              // Original content first
              'Original: ${phrase.originalContent}',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 6),
            Text(
              // Translated output second
              phrase.translatedOutput,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            if (phrase.romanisation != null &&
                phrase.romanisation!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                // Romanisation third
                'Romanisation: ${phrase.romanisation}',
                style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700]),
              ),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                tooltip: 'Remove from favorites',
                onPressed: () {
                  context.read<PhraseBookBloc>().add(
                      RemovePhraseFromFavorites(favoritePhraseId: phrase.id));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
