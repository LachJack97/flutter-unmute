import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unmute/features/chat/domain/entities/message_entity.dart';
import 'package:unmute/features/chat/presentation/bloc/phrase_book_bloc.dart';
import 'package:unmute/features/chat/domain/entities/favorite_phrase_entity.dart'; // Import FavoritePhraseEntity
import 'package:unmute/features/chat/presentation/bloc/phrase_book_event.dart';
import 'package:unmute/features/chat/presentation/bloc/phrase_book_state.dart';
import 'package:flutter/services.dart'; // Import for Clipboard
import 'package:flutter_markdown/flutter_markdown.dart'; // Import for Markdown rendering
import 'package:collection/collection.dart'; // For firstWhereOrNull
import 'dart:io'; // For File

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
  bool _isOcrContentExpanded = false; // For expanding OCR/Markdown content
  bool _isTranslationExpanded = false; // For expanding translation breakdown

  // Define a set of language codes for which romanization is generally useful.
  // These are typically languages not using a Latin-based script.
  static const Set<String> _languagesBenefitingFromRomanisation = {
    'ja', // Japanese
    'ko', // Korean
    'zh', // Chinese (covers variants like zh-CN, zh-TW)
    'ar', // Arabic
    'hi', // Hindi
    'ru', // Russian
    'el', // Greek
    'th', // Thai
    'he', // Hebrew
  };

  Widget _buildUserTextBubble(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange[500],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  Widget _buildUserNetworkImageBubble(String imageUrl) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(4), // Reduced padding for image
        decoration: BoxDecoration(
          color: Colors.orange[500],
          borderRadius: BorderRadius.circular(15), // Slightly less rounded for image
        ),
        constraints: const BoxConstraints(
          maxWidth: 200, // Max width for the image bubble
          maxHeight: 200, // Max height for the image bubble
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11.0), // Inner rounding for image
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover, // Cover to fill the bubble
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            },
            errorBuilder: (context, error, stackTrace) =>
                const Center(child: Icon(Icons.broken_image, color: Colors.white70, size: 40)),
          ),
        ),
      ),
    );
  }

  Widget _buildUserLocalImageBubble(String localPath, bool isUploading) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.orange[300], // Slightly different color for uploading?
          borderRadius: BorderRadius.circular(15),
        ),
        constraints: const BoxConstraints(
          maxWidth: 200,
          maxHeight: 200,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(11.0),
              child: Image.file(
                File(localPath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.white70, size: 40)),
              ),
            ),
            if (isUploading) const CircularProgressIndicator(color: Colors.white),
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
    // Decide if we show an image thumbnail INSIDE the AI bubble.
    // For this optimization, we'll set it to false if isOcrMarkdown is true,
    // as the user's bubble already shows the sent image.
    final String? ocrImageUrlForAiBubble = isOcrMarkdown ? null : widget.message.imageUrl; // MODIFIED LINE
    bool showRomanization = !isOcrMarkdown &&
        romanization != null &&
        romanization.isNotEmpty &&
        targetLanguageForRomanization != null &&
        _languagesBenefitingFromRomanisation.contains(targetLanguageForRomanization);

    bool hasBreakdown = !isOcrMarkdown && breakdown != null && breakdown.isNotEmpty;

    String displayedText = mainText;
    bool canExpandOcr = false;

    if (isOcrMarkdown) {
      const int maxLinesShort = 7; // Number of lines to show when collapsed
      const int maxLengthShort = 250; // Max characters to show when collapsed
      final lines = mainText.split('\n');

      if (lines.length > maxLinesShort || mainText.length > maxLengthShort) {
        canExpandOcr = true;
        if (!_isOcrContentExpanded) {
          if (lines.length > maxLinesShort) {
            displayedText = lines.take(maxLinesShort).join('\n') + "\n...";
          } else if (mainText.length > maxLengthShort) {
            // If it's fewer than maxLines but still too long
            displayedText = mainText.substring(0, maxLengthShort) + "...";
          }
        }
      }
    }

    return Align(
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
            if (ocrImageUrlForAiBubble != null && ocrImageUrlForAiBubble.isNotEmpty) ...[ // MODIFIED CONDITION
              Center( // Center the image
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      ocrImageUrlForAiBubble, // MODIFIED USAGE
                      height: 120, // Adjust height as needed
                      width: double.infinity,
                      fit: BoxFit.contain, // Use contain to see more of the image
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          height: 120,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => const SizedBox(height: 120, child: Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey))),
                    ),
                  ),
                ),
              ),
            ],
            BlocBuilder<PhraseBookBloc, PhraseBookState>(
              builder: (context, phraseBookState) {
                bool isFavorite = false;
                String? favoriteId;
                FavoritePhraseEntity? favoriteEntity;

                if (!isOcrMarkdown && phraseBookState is PhraseBookLoaded) {
                  favoriteEntity = phraseBookState.favoritePhrases.firstWhereOrNull(
                    (fav) =>
                        fav.translatedOutput == mainText &&
                        fav.originalContent == widget.message.content &&
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
                          ? MarkdownBody(
                              data: displayedText,
                              selectable: true, // Allows text selection
                              // You can customize the style sheet if needed:
                              // styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(...),
                            )
                          : Text(
                              displayedText,
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                    ),
                    if (!isOcrMarkdown) // Only show star for actual translations
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.star : Icons.star_border,
                          size: 20,
                          color: isFavorite ? Colors.amber : Colors.grey,
                        ),
                        tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
                        onPressed: () {
                          if (isFavorite && favoriteId != null) {
                            context.read<PhraseBookBloc>().add(
                                RemovePhraseFromFavorites(favoritePhraseId: favoriteId));
                          } else {
                            // Ensure widget.message.output is not null for favoriting translations
                            if (widget.message.output != null) {
                              context.read<PhraseBookBloc>().add(
                                  AddPhraseToFavorites(message: widget.message));
                            }
                          }
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 16),
                      color: Colors.black45,
                      padding: const EdgeInsets.only(left: 4.0),
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                      splashRadius: 18,
                      tooltip: isOcrMarkdown ? 'Copy text' : 'Copy translation',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: mainText)); // Copy the full original text
                      },
                    ),
                  ],
                );
              },
            ),

            if (isOcrMarkdown && canExpandOcr) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  setState(() {
                    _isOcrContentExpanded = !_isOcrContentExpanded;
                  });
                },
                child: Text(
                  _isOcrContentExpanded ? 'Show less ↑' : 'Show more ↓',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],

            if (showRomanization) ...[
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      romanization!,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    color: Colors.black45,
                    padding: const EdgeInsets.only(left: 4.0),
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                    splashRadius: 18,
                    tooltip: 'Copy romanisation',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: romanization));
                    },
                  ),
                ],
              ),
            ],

            if (hasBreakdown) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  setState(() {
                    _isTranslationExpanded = !_isTranslationExpanded;
                  });
                },
                child: Text(
                  _isTranslationExpanded ? 'Hide breakdown ↑' : 'Show breakdown ↓',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
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
      // This is a successfully uploaded image, content should be "📷 Image" or similar
      userBubble = _buildUserNetworkImageBubble(msg.imageUrl!);
    } else {
      // This is a text message or a failed image upload (content might be "⚠️ Image (upload failed)")
      userBubble = _buildUserTextBubble(msg.content);
    }

    // Determine if the AI bubble content (msg.output) should be treated as Markdown.
    // This is true if it's an image-originated message.
    // We infer it's an image-originated message if:
    // 1. It was an image being uploaded (localImagePath was present).
    // 2. It's an image that has been uploaded (imageUrl is present).
    // 3. Or, if neither of the above, but the content is a known image placeholder.
    bool aiContentIsMarkdown = false;
    if (msg.localImagePath != null || (msg.imageUrl != null && msg.imageUrl!.isNotEmpty)) {
      aiContentIsMarkdown = true;
    } else if (msg.output != null && msg.output!.isNotEmpty && msg.content.isNotEmpty) {
      // If no image URLs, check if content is a placeholder, implying output is OCR from a (possibly failed) image
      if (msg.content == "📷 Image" || msg.content == "⚠️ Image (upload failed)") {
        aiContentIsMarkdown = true;
      }
    }

    // The AI bubble should only show if there's output.
    // The `ocrImageUrlForAiBubble` in `_buildAiResponseBubble` uses `widget.message.imageUrl`.
    // This is fine; it means the AI bubble will show the (network) image thumbnail
    // only after the image has been successfully uploaded and processed,
    // and only if `isOcrMarkdown` is false (i.e., it's a translation of text that happened to have an image, not OCR of an image).
    // For OCR (where `isOcrMarkdown` is true), the user bubble already shows the image.

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          userBubble, // User's message (text, local image, or network image)
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
