import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unmute/features/chat/presentation/bloc/phrase_book_bloc.dart';
import 'package:unmute/features/chat/presentation/bloc/phrase_book_event.dart';
import 'package:unmute/features/chat/presentation/bloc/phrase_book_state.dart';
import 'package:unmute/features/chat/presentation/widgets/phrase_card_item.dart';
// Correctly importing the file with the new Language class
import 'package:unmute/features/chat/presentation/widgets/language_selector_pill.dart';

class PhraseBookPage extends StatefulWidget {
  const PhraseBookPage({super.key});

  @override
  State<PhraseBookPage> createState() => _PhraseBookPageState();
}

class _PhraseBookPageState extends State<PhraseBookPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<PhraseBookBloc>().add(const LoadFavoritePhrases());
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phrase Book'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/chat'),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search phrases...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
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
                  final filteredGroupedPhrases =
                      state.getFilteredPhrases(_searchQuery);

                  if (filteredGroupedPhrases.isEmpty) {
                    return const Center(child: Text('No phrases found.'));
                  }

                  final languages = filteredGroupedPhrases.keys.toList();

                  return ListView.builder(
                    itemCount: languages.length,
                    itemBuilder: (context, index) {
                      final languageCode = languages[index];
                      final phrasesForLanguage =
                          filteredGroupedPhrases[languageCode]!;

                      // FIX: Use the new Language class structure to find the language details
                      final language = (LanguageSelectorPill.availableLanguages as Iterable<Language>)
                          .firstWhere(
                        (lang) => lang.code == languageCode,
                        // Update the fallback to match the new constructor
                        orElse: () => Language(
                          code: languageCode,
                          promptName: languageCode,
                          displayName: languageCode.toUpperCase(),
                          flag: '🏳️', // A neutral flag
                        ),
                      );

                      return ExpansionTile(
                        // FIX: Use a Row to display both the flag and the name
                        title: Row(
                          children: [
                            Text(language.flag,
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(
                              language.promptName, // Use the correct property
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 18),
                            ),
                          ],
                        ),
                        initiallyExpanded: true,
                        children: phrasesForLanguage
                            .map((phrase) => PhraseCardItem(phrase: phrase))
                            .toList(),
                      );
                    },
                  );
                }
                return const Center(
                    child: Text('Add phrases from the chat to see them here.'));
              },
            ),
          ),
        ],
      ),
    );
  }
}