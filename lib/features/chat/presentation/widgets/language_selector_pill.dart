import 'package:flutter/material.dart';

// --- Data Model for a Language ---
// A simple class to hold the details for each language.
class Language {
  final String code;
  final String name;
  final String flag;

  const Language({required this.code, required this.name, required this.flag});
}

// --- The Main Language Selector Widget ---
// This is a stateful widget because we need to manage the currently selected language.
class LanguageSelectorPill extends StatefulWidget {
  // Callback function to notify the parent widget of a language change.
  // This is where you will call your Supabase update function.
  final Function(String languageCode) onLanguageSelected;

  const LanguageSelectorPill({super.key, required this.onLanguageSelected});

  @override
  State<LanguageSelectorPill> createState() => _LanguageSelectorPillState();
}

class _LanguageSelectorPillState extends State<LanguageSelectorPill> {
  // List of available languages. You can easily add or remove languages here.
  static const List<Language> languages = [
    Language(code: 'en', name: 'EN', flag: '🇺🇸'),
    Language(code: 'es', name: 'Español', flag: '🇪🇸'),
    Language(code: 'fr', name: 'Français', flag: '🇫🇷'),
    Language(code: 'de', name: 'Deutsch', flag: '🇩🇪'),
    Language(code: 'ja', name: '日本語', flag: '🇯🇵'),
    Language(code: 'ko', name: '한국어', flag: '🇰🇷'),
  ];

  // The currently selected language. Defaults to English.
  Language _selectedLanguage = languages[0];

  @override
  Widget build(BuildContext context) {
    // DropdownButton is a great built-in widget for this purpose.
    // We customize it to look like a pill.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20.0), // Pill shape
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Language>(
          // The currently selected language value.
          value: _selectedLanguage,
          // The dropdown arrow icon
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          // Style for the items in the dropdown menu.
          dropdownColor: Colors.white,
          // Generate the list of items for the dropdown menu.
          items: languages.map((Language language) {
            return DropdownMenuItem<Language>(
              value: language,
              child: Row(
                children: [
                  Text(language.flag, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(language.name),
                ],
              ),
            );
          }).toList(),
          // This function is called when a new language is selected.
          onChanged: (Language? newLanguage) {
            if (newLanguage != null) {
              setState(() {
                _selectedLanguage = newLanguage;
              });
              // --- SUPABASE INTEGRATION POINT ---
              // Call the callback function with the selected language code.
              widget.onLanguageSelected(newLanguage.code);
            }
          },
          // Customize the displayed item (the pill itself).
          selectedItemBuilder: (BuildContext context) {
            return languages.map<Widget>((Language language) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedLanguage.flag,
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    _selectedLanguage.name,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
      ),
    );
  }
}
