import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unmute/features/chat/domain/entities/message_entity.dart';
import 'package:unmute/features/chat/presentation/bloc/phrase_book_bloc.dart';
import 'package:unmute/features/chat/domain/entities/favorite_phrase_entity.dart';
import 'package:unmute/features/chat/presentation/bloc/phrase_book_event.dart';
import 'package:unmute/features/chat/presentation/bloc/phrase_book_state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:collection/collection.dart';
import 'dart:io';

class ChatMessageItem extends StatefulWidget {
  final MessageEntity message;
  const ChatMessageItem({super.key, required this.message});

  @override
  State<ChatMessageItem> createState() => _ChatMessageItemState();
}

class _ChatMessageItemState extends State<ChatMessageItem> {
  bool _isOcrContentExpanded = false;
  bool _isTranslationExpanded = false;

  static const Set<String> _languagesBenefitingFromRomanisation = {
    'ja', 'ko', 'zh', 'ar', 'hi', 'ru', 'el', 'th', 'he',
  };

  Widget _buildUserTextBubble(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary, // THEME FIX
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style:
                TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 16)),
      ),
    );
  }

  Widget _buildUserNetworkImageBubble(String imageUrl) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary, // THEME FIX
          borderRadius: BorderRadius.circular(15),
        ),
        constraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11.0),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                  child: CircularProgressIndicator(color: theme.colorScheme.onPrimary));
            },
            errorBuilder: (context, error, stackTrace) => Center(
                child: Icon(Icons.broken_image,
                    color: theme.colorScheme.onPrimary.withOpacity(0.7), size: 40)),
          ),
        ),
      ),
    );
  }

  Widget _buildUserLocalImageBubble(String localPath, bool isUploading) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer, // THEME FIX
          borderRadius: BorderRadius.circular(15),
        ),
        constraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(11.0),
              child: Image.file(
                File(localPath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(Icons.broken_image,
                        color: theme.colorScheme.onPrimaryContainer, size: 40)),
              ),
            ),
            if (isUploading)
              CircularProgressIndicator(color: theme.colorScheme.onPrimaryContainer),
          ],
        ),
      ),
    );
  }

  Widget _buildAiResponseBubble({
    required String mainText,
    String? romanization,
    String? targetLanguageForRomanization,
    List<Map<String, dynamic>>? breakdown,
    bool isOcrMarkdown = false,
  }) {
    final theme = Theme.of(context);
    final String? ocrImageUrlForAiBubble = isOcrMarkdown ? null : widget.message.imageUrl;
    bool showRomanization = !isOcrMarkdown &&
        romanization != null &&
        romanization.isNotEmpty &&
        targetLanguageForRomanization != null &&
        _languagesBenefitingFromRomanisation.contains(targetLanguageForRomanization);
    bool hasBreakdown = !isOcrMarkdown && breakdown != null && breakdown.isNotEmpty;

    String displayedText = mainText;
    bool canExpandOcr = false;

    if (isOcrMarkdown) {
      const int maxLinesShort = 7;
      const int maxLengthShort = 250;
      final lines = mainText.split('\n');
      if (lines.length > maxLinesShort || mainText.length > maxLengthShort) {
        canExpandOcr = true;
        if (!_isOcrContentExpanded) {
          displayedText = (lines.length > maxLinesShort)
              ? lines.take(maxLinesShort).join('\n') + "\n..."
              : mainText.substring(0, maxLengthShort) + "...";
        }
      }
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ocrImageUrlForAiBubble != null && ocrImageUrlForAiBubble.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      ocrImageUrlForAiBubble,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            BlocBuilder<PhraseBookBloc, PhraseBookState>(
              builder: (context, phraseBookState) {
                bool isFavorite = false;
                String? favoriteId;
                if (!isOcrMarkdown && phraseBookState is PhraseBookLoaded) {
                  final allFavoritePhrases =
                      phraseBookState.groupedPhrases.values.expand((phrases) => phrases);
                  final favoriteEntity = allFavoritePhrases.firstWhereOrNull(
                      (fav) =>
                          fav.translatedOutput == mainText &&
                          fav.originalContent == widget.message.content &&
                          // CORRECTED: Use the existing field name
                          fav.targetLanguageCode == widget.message.targetLanguage,
                    );
                  if (favoriteEntity != null) {
                    isFavorite = true;
                    favoriteId = favoriteEntity.id;
                  }
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: isOcrMarkdown
                          ? MarkdownBody(data: displayedText, selectable: true)
                          : Text(
                              displayedText,
                              style: TextStyle(
                                  fontSize: 16, color: theme.colorScheme.onSurface),
                            ),
                    ),
                    if (!isOcrMarkdown)
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.star : Icons.star_border,
                          size: 20,
                          // THEME FIX for star icon
                          color: isFavorite
                              ? Colors.amber
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        tooltip: isFavorite
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                        onPressed: () {
                          if (isFavorite && favoriteId != null) {
                            context
                                .read<PhraseBookBloc>()
                                .add(RemovePhraseFromFavorites(favoritePhraseId: favoriteId));
                          } else {
                            if (widget.message.output != null) {
                              context
                                  .read<PhraseBookBloc>()
                                  .add(AddPhraseToFavorites(message: widget.message));
                            }
                          }
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 16),
                      color: theme.colorScheme.onSurface,
                      padding: const EdgeInsets.only(left: 4.0),
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                      splashRadius: 18,
                      tooltip: isOcrMarkdown ? 'Copy text' : 'Copy translation',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: mainText));
                      },
                    ),
                  ],
                );
              },
            ),
            if (isOcrMarkdown && canExpandOcr) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () => setState(() => _isOcrContentExpanded = !_isOcrContentExpanded),
                child: Text(
                  _isOcrContentExpanded ? 'Show less ↑' : 'Show more ↓',
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: theme.colorScheme.primary),
                ),
              ),
            ],
            if (showRomanization) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      romanization!,
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurface,
                          fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    color: theme.colorScheme.onSurface,
                    padding: const EdgeInsets.only(left: 4.0),
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                    splashRadius: 18,
                    tooltip: 'Copy romanisation',
                    onPressed: () => Clipboard.setData(ClipboardData(text: romanization)),
                  ),
                ],
              ),
            ],
            if (hasBreakdown) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () => setState(() => _isTranslationExpanded = !_isTranslationExpanded),
                child: Text(
                  _isTranslationExpanded ? 'Hide breakdown ↑' : 'Show breakdown ↓',
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: theme.colorScheme.primary),
                ),
              ),
              if (_isTranslationExpanded) _BreakdownList(breakdown: breakdown!)
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.message;
    Widget userBubble;
    if (msg.localImagePath != null && msg.localImagePath!.isNotEmpty) {
      userBubble = _buildUserLocalImageBubble(msg.localImagePath!, msg.isUploadingImage);
    } else if (msg.imageUrl != null && msg.imageUrl!.isNotEmpty) {
      userBubble = _buildUserNetworkImageBubble(msg.imageUrl!);
    } else {
      userBubble = _buildUserTextBubble(msg.content);
    }
    bool aiContentIsMarkdown = (msg.localImagePath != null ||
        (msg.imageUrl != null && msg.imageUrl!.isNotEmpty) ||
        (msg.content == "📷 Image" || msg.content == "⚠️ Image (upload failed)"));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          userBubble,
          if (msg.output != null && msg.output!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildAiResponseBubble(
              mainText: msg.output!,
              romanization: msg.romanisation,
              targetLanguageForRomanization: msg.targetLanguage,
              breakdown: msg.breakdown,
              isOcrMarkdown: aiContentIsMarkdown,
            ),
          ]
        ],
      ),
    );
  }
}

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
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '— ${part['gloss'] ?? ''}',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14),
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