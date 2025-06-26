import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// --- Data Model for a Language ---
// A robust, immutable class to hold all language details.
@immutable
class Language {
  final String code; // e.g., 'en', 'ko'
  final String displayName; // The short name for the UI, e.g., 'EN', 'KR'
  final String
      promptName; // The full name for AI prompts, e.g., 'English', 'Korean'
  final String flag; // The emoji flag for the language.

  const Language({
    required this.code,
    required this.displayName,
    required this.promptName,
    required this.flag,
  });

  // Override equals and hashCode to ensure DropdownButton and other
  // collection widgets can correctly compare Language objects.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Language &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

// --- The Main Language Selector Widget ---
class LanguageSelectorPill extends StatelessWidget {
  static const Language defaultLanguage = Language(
      code: 'en', displayName: 'EN', promptName: 'English', flag: '🇺🇸');

  // FIX: Added more languages to the list
  static const List<Language> availableLanguages = [
    Language(
        code: 'en', displayName: 'EN', promptName: 'English', flag: '🇺🇸'),
    Language(
        code: 'es', displayName: 'ES', promptName: 'Spanish', flag: '🇪🇸'),
    Language(code: 'fr', displayName: 'FR', promptName: 'French', flag: '🇫🇷'),
    Language(code: 'de', displayName: 'DE', promptName: 'German', flag: '🇩🇪'),
    Language(
        code: 'ja', displayName: 'JP', promptName: 'Japanese', flag: '🇯🇵'),
    Language(code: 'ko', displayName: 'KR', promptName: 'Korean', flag: '🇰🇷'),
    Language(
        code: 'it', displayName: 'IT', promptName: 'Italian', flag: '🇮🇹'),
    Language(
        code: 'pt', displayName: 'PT', promptName: 'Portuguese', flag: '🇵🇹'),
    Language(
        code: 'ru', displayName: 'RU', promptName: 'Russian', flag: '🇷🇺'),
    Language(
        code: 'zh', displayName: 'CN', promptName: 'Chinese', flag: '🇨🇳'),
    Language(
        code: 'ar', displayName: 'SA', promptName: 'Arabic', flag: '🇸🇦'),
    Language(code: 'hi', displayName: 'IN', promptName: 'Hindi', flag: '🇮🇳'),
  ];

  final Language? selectedLanguage;
  final ValueChanged<Language> onLanguageSelected;

  const LanguageSelectorPill({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.0),
      decoration: BoxDecoration(
        color: Colors.orange[500],
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(
          color: Colors.orange[500]!,
          width: 2.0,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Language>(
          value: selectedLanguage,
          isDense: true,
          hint: const Text(
            "Select Language",
            style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.normal),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white,
            size: 16,
          ),
          dropdownColor: colorScheme.surface,
          onChanged: (Language? newLanguage) {
            if (newLanguage != null) {
              onLanguageSelected(newLanguage);
            }
          },
          // How the currently selected item (the pill's content) is displayed.
          selectedItemBuilder: (context) {
            return LanguageSelectorPill.availableLanguages
                .map<Widget>((language) {
              return Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // FIX: Display the flag emoji
                    Text(language.flag, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    Text(
                      language.promptName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },
          // How the items in the dropdown menu are displayed.
          items: LanguageSelectorPill.availableLanguages
              .map<DropdownMenuItem<Language>>((language) {
            return DropdownMenuItem<Language>(
              value: language,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // FIX: Display the flag emoji in the dropdown list
                    Text(language.flag, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(
                      language.promptName,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}