import 'package:flutter/material.dart';

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

class LanguageSelectorPill extends StatelessWidget {
  // Default language for the application.
  static const Language defaultLanguage = Language(
      code: 'en', displayName: 'EN', promptName: 'English', flag: '🇺🇸');

  // A complete list of ALL languages the app knows. Filtering happens before passing to this widget.
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
  ];

  // The currently selected language, provided by the parent widget.
  final Language? selectedLanguage;

  // Callback to notify the parent when a new language is chosen.
  // It passes the entire Language object for maximum flexibility.
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
      padding: const EdgeInsets.symmetric(
          horizontal: 6.0, vertical: 1.0), // Further reduced padding
      decoration: BoxDecoration(
        color: Colors.orange[500], // Orange background
        borderRadius: BorderRadius.circular(30.0), // Pill shape
        border: Border.all(
          color: Colors.orange[500]!, // Thinner orange border
          width: 2.0, // Thinner border
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Language>(
          value: selectedLanguage,
          isDense: true, // Reduces the button's height.
          hint: const Text(
              // Hint for when no language is selected
            "Select Language",
            style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.normal),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white, // White icon for better contrast
            size: 16, // Further reduced icon size
          ),
          dropdownColor: colorScheme.surface,
          // When a new language is selected from the list.
          onChanged: (Language? newLanguage) {
            if (newLanguage != null) {
              onLanguageSelected(newLanguage);
            }
          },
          // How the currently selected item (the pill's content) is displayed.
          selectedItemBuilder: (context) {
            return LanguageSelectorPill.availableLanguages
                .map<Widget>((language) { // Corrected: Removed extra ')' and ';'
              // Use the passed list
              return Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      language.promptName, // Use full prompt name
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
          items: LanguageSelectorPill.availableLanguages.map<DropdownMenuItem<Language>>((language) {
            return DropdownMenuItem<Language>(
              value: language,
              child: Center(
                // Wrap the content in a Center widget
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Center the row content
                  children: [
                    Text(
                      language.promptName, // Use full prompt name
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                        fontSize: 13, // Adjusted font size in dropdown
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
