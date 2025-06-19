import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unmute/features/chat/domain/entities/favorite_phrase_entity.dart';
import 'package:unmute/features/chat/presentation/bloc/phrase_book_bloc.dart';
import 'package:unmute/features/chat/presentation/bloc/phrase_book_state.dart';
import 'package:unmute/features/chat/presentation/widgets/language_selector_pill.dart'; 
import 'package:unmute/features/chat/presentation/widgets/phrase_card_item.dart'; 
import 'package:collection/collection.dart'; 

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
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/chat'), // Navigate back to chat
        ),
        title: const Text('Phrase Book'),
        elevation: 0,
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w500),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search phrases...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<PhraseBookBloc, PhraseBookState>(
              builder: (context, state) {
                if (state is PhraseBookLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is PhraseBookLoaded) {
                  if (state.favoritePhrases.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                            'Your phrase book is empty. Add some favorites from the chat!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ),
                    );
                  }

                  // Filter phrases based on search query
                  final filteredPhrases = state.favoritePhrases.where((phrase) {
                    final query = _searchQuery.toLowerCase();
                    return phrase.translatedOutput
                            .toLowerCase()
                            .contains(query) ||
                        phrase.originalContent.toLowerCase().contains(query) ||
                        (phrase.romanisation?.toLowerCase().contains(query) ??
                            false);
                  }).toList();

                  if (filteredPhrases.isEmpty && _searchQuery.isNotEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                          child: Text('No phrases match your search.',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey))),
                    );
                  }
                  if (filteredPhrases.isEmpty && _searchQuery.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                          child: Text(
                              'Your phrase book is empty. Add some favorites from the chat!',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey))),
                    );
                  }

                  // Group filtered phrases by language
                  final Map<String, List<FavoritePhraseEntity>> groupedPhrases =
                      {};
                  for (var phrase in filteredPhrases) {
                    groupedPhrases
                        .putIfAbsent(phrase.targetLanguageCode, () => [])
                        .add(phrase);
                  }

                  final languageGroups = groupedPhrases.entries.toList();

                  return ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: languageGroups.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 20),
                    itemBuilder: (context, groupIndex) {
                      final languageCode = languageGroups[groupIndex].key;
                      final phrasesInGroup = languageGroups[groupIndex].value;
                      final Language? langObject = LanguageSelectorPill
                          .availableLanguages
                          .firstWhereOrNull(
                              (lang) => lang.code == languageCode);
                      final String displayLanguageName =
                          langObject?.promptName ?? languageCode.toUpperCase();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$displayLanguageName Phrases (${phrasesInGroup.length})',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(
                              height: 12.0), // Spacing after the title
                          ListView.separated(
                            physics:
                                const NeverScrollableScrollPhysics(), // Important for nested lists
                            shrinkWrap: true, // Important for nested lists
                            itemCount: phrasesInGroup.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, phraseIndex) {
                              final phrase = phrasesInGroup[phraseIndex];
                              return PhraseCardItem(phrase: phrase);
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else if (state is PhraseBookError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                      child: Text(
                          'Tap the star on messages in the chat to save them here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey))),
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
