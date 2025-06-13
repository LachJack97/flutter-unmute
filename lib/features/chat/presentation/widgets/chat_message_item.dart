import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unmute/features/chat/domain/entities/message_entity.dart';
import 'package:unmute/features/chat/presentation/bloc/phrase_book_bloc.dart';
import 'package:unmute/features/chat/domain/entities/favorite_phrase_entity.dart'; // Import FavoritePhraseEntity
import 'package:unmute/features/chat/presentation/bloc/phrase_book_event.dart';
import 'package:unmute/features/chat/presentation/bloc/phrase_book_state.dart';
import 'package:flutter/services.dart'; // Import for Clipboard

/// A stateful widget to handle a single message exchange.
/// This includes the user's bubble and the AI's response bubble.
/// It manages the expanded/collapsed state for its own breakdown.
class ChatMessageItem extends StatefulWidget {
  final MessageEntity message;
  const ChatMessageItem({super.key, required this.message});

  @override
  State<ChatMessageItem> createState() => _ChatMessageItemState();
}

class _ChatMessageItemState extends State<ChatMessageItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // User's situation bubble
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[500],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.message.content,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // AI's response bubble, only shown if there is output.
          if (widget.message.output != null &&
              widget.message.output!.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<PhraseBookBloc, PhraseBookState>(
                      builder: (context, phraseBookState) {
                        bool isFavorite = false;
                        String? favoriteId;

                        if (phraseBookState is PhraseBookLoaded) {
                          final favorite = phraseBookState.favoritePhrases
                              .firstWhere(
                                  (fav) =>
                                      fav.translatedOutput ==
                                          widget.message.output &&
                                      fav.originalContent ==
                                          widget.message.content &&
                                      fav.targetLanguageCode ==
                                          widget.message.targetLanguage,
                                  orElse: () => FavoritePhraseEntity(
                                      id: '',
                                      userId: '',
                                      originalContent: '',
                                      translatedOutput: '',
                                      targetLanguageCode: '',
                                      createdAt: DateTime
                                          .now()) // Dummy non-matching entity
                                  );
                          if (favorite.id.isNotEmpty) {
                            isFavorite = true;
                            favoriteId = favorite.id;
                          }
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                widget.message.output!,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black87),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isFavorite ? Icons.star : Icons.star_border,
                                size: 20,
                                color: isFavorite ? Colors.amber : Colors.grey,
                              ),
                              tooltip: isFavorite
                                  ? 'Remove from favorites'
                                  : 'Add to favorites',
                              onPressed: () {
                                if (isFavorite && favoriteId != null) {
                                  context.read<PhraseBookBloc>().add(
                                      RemovePhraseFromFavorites(
                                          favoritePhraseId: favoriteId));
                                } else {
                                  context.read<PhraseBookBloc>().add(
                                      AddPhraseToFavorites(
                                          message: widget.message));
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 16),
                              color: Colors.black45,
                              padding: const EdgeInsets.only(left: 4.0),
                              constraints: const BoxConstraints(
                                  minWidth: 24, minHeight: 24),
                              splashRadius: 18,
                              tooltip: 'Copy translation',
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                    text: widget.message.output!));
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    if (widget.message.romanisation != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              widget.message.romanisation!,
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy,
                                size: 16), // Made icon smaller
                            color: Colors.black45, // Slightly lighter color
                            padding: const EdgeInsets.only(
                                left: 4.0), // Reduced left padding
                            constraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24), // Smaller tap target
                            splashRadius: 18, // Smaller splash radius
                            tooltip: 'Copy romanisation',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                  text: widget.message.romanisation!));
                            },
                          ),
                        ],
                      ),
                    ],
                    if (widget.message.breakdown != null &&
                        widget.message.breakdown!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Text(
                          _isExpanded ? 'Hide breakdown ↑' : 'Show breakdown ↓',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                      if (_isExpanded)
                        _BreakdownList(breakdown: widget.message.breakdown!)
                    ]
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}

/// A private helper widget to display the list of breakdown parts.
class _BreakdownList extends StatelessWidget {
  final List<Map<String, dynamic>> breakdown;
  const _BreakdownList({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: breakdown.map((part) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${part['part'] ?? ''}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '— ${part['gloss'] ?? ''}',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
