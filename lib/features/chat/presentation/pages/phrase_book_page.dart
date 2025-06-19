import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unmute/features/chat/presentation/bloc/phrase_book_bloc.dart';
import 'package:unmute/features/chat/presentation/bloc/phrase_book_event.dart';
import 'package:unmute/features/chat/presentation/bloc/phrase_book_state.dart';
import 'package:unmute/features/chat/presentation/widgets/phrase_card_item.dart';

class PhraseBookPage extends StatefulWidget {
  const PhraseBookPage({super.key});

  @override
  State<PhraseBookPage> createState() => _PhraseBookPageState();
}

class _PhraseBookPageState extends State<PhraseBookPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load the phrases when the page is first initialized
    context.read<PhraseBookBloc>().add(const LoadFavoritePhrases());
    _searchController.addListener(() {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text.toLowerCase();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/chat'),
        ),
        title: const Text('Phrase Book'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search phrases...',
                prefixIcon:
                    Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
                // Use theme color for the search bar fill
                fillColor: theme.colorScheme.surface,
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<PhraseBookBloc, PhraseBookState>(
              builder: (context, state) {
                if (state is PhraseBookLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is PhraseBookError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else if (state is PhraseBookLoaded) {
                  // Filter the grouped phrases based on the search query
                  final filteredGroupedPhrases =
                      state.groupedPhrases.map((language, phrases) {
                    final filteredPhrases = phrases.where((phrase) {
                      return phrase.originalContent
                              .toLowerCase()
                              .contains(_searchQuery) ||
                          phrase.translatedOutput
                              .toLowerCase()
                              .contains(_searchQuery) ||
                          (phrase.romanisation
                                  ?.toLowerCase()
                                  .contains(_searchQuery) ??
                              false);
                    }).toList();
                    return MapEntry(language, filteredPhrases);
                  })
                    ..removeWhere((language, phrases) => phrases.isEmpty);

                  final languages = filteredGroupedPhrases.keys.toList();

                  if (languages.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _searchQuery.isNotEmpty
                              ? 'No phrases match your search.'
                              : 'Your phrase book is empty. Add some favorites from the chat!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                    );
                  }

                  // Build the UI with ExpansionTile
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: languages.length,
                    itemBuilder: (context, index) {
                      final language = languages[index];
                      final phrasesForLanguage =
                          filteredGroupedPhrases[language]!;

                      return ExpansionTile(
                        title: Text(
                          language,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(color: theme.colorScheme.primary),
                        ),
                        subtitle: Text('${phrasesForLanguage.length} phrases'),
                        initiallyExpanded: true, // Keep books open by default
                        childrenPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        children: phrasesForLanguage
                            .map((phrase) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: PhraseCardItem(phrase: phrase),
                                ))
                            .toList(),
                      );
                    },
                  );
                }
                // Default/Initial state
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Tap the star on messages in the chat to save them here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}