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
      // Elevation and shape will be handled by CardTheme
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Original: ${phrase.originalContent}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 6),
            Text(
              // Translated output second
              phrase.translatedOutput,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface),
            ),
            if (phrase.romanisation != null &&
                phrase.romanisation!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Romanisation: ${phrase.romanisation}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error),
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
