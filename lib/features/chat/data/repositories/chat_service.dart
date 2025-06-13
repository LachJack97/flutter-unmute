import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data'; // Required for Uint8List
import 'dart:convert'; // Required for base64Encode
import 'package:unmute/features/chat/domain/entities/message_entity.dart';
import 'package:unmute/features/chat/domain/entities/favorite_phrase_entity.dart';

/// A service class dedicated to handling all chat-related interactions
/// with the Supabase backend for the client-orchestrated architecture.
class ChatService {
  final _supabase = Supabase.instance.client;

  /// Gets the current authenticated user's ID.
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Stores the user's selected target language in their profile.
  Future<void> setTargetLanguage(String languageCode) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Use upsert to ensure the profile is created if it doesn't exist,
      // or updated if it does. Assumes 'id' is the primary key of 'profiles'
      // and matches the authenticated user's ID.
      await _supabase
          .from('profiles')
          .upsert({'id': userId, 'target_language': languageCode});
    } catch (e) {
      // Log error or handle as appropriate for your app
      print('Error setting target language: $e');
    }
  }

  /// Fetches the user's selected target language from their profile.
  Future<String?> getTargetLanguage() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;
    try {
      final response = await _supabase
          .from('profiles')
          .select('target_language')
          .eq('id', userId)
          .maybeSingle(); // Use .maybeSingle() to return null if no row, or the row if found.

      // If a profile row exists and target_language is set, return it.
      if (response != null && response['target_language'] != null) {
        return response['target_language'] as String;
      }
    } catch (e) {
      print('Error fetching target language: $e');
    }
    return null;
  }

  /// Subscribes to the real-time message stream from the 'messages' table.
  /// This listens for new messages being inserted or updated.
  Stream<List<MessageEntity>> getMessages() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      // If no user is logged in, return an empty stream or handle error
      return Stream.value([]);
    }
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('sender_id', userId) // Filter messages by the current user's ID
        .order('created_at', ascending: true)
        .map((listOfMaps) {
          // Maps the raw database data into our clean MessageEntity objects.
          return listOfMaps.map((map) {
            // We wrap the parsing of each message in a try-catch block.
            // This makes the app more resilient and prevents a single malformed
            // message from freezing the entire UI.
            try {
              // This logic now correctly handles the breakdown as a List.
              return MessageEntity(
                id: map['id'],
                content: map['content'],
                senderId: map['sender_id'],
                createdAt: DateTime.parse(map['created_at']),
                output: map['output'],
                targetLanguage: map['target_language'],
                romanisation: map['romanisation'],
                detectedLanguageCode: map['detected_language']
                    as String?, // Correctly assign detected_language
                imageUrl:
                    map['image_url'] as String?, // Correctly assign image_url
                breakdown: map['breakdown'] != null
                    ? List<Map<String, dynamic>>.from(map['breakdown'])
                    : null,
              );
            } catch (e) {
              // If parsing fails, log the error and the problematic message data.
              print("Error parsing message data: ${map.toString()}. Error: $e");
              // Return a valid MessageEntity with null for the failed parts.
              // This prevents the entire application from crashing.
              return MessageEntity(
                id: map['id'],
                content: map['content'],
                senderId: map['sender_id'],
                createdAt: DateTime.parse(map['created_at']),
                detectedLanguageCode: null, // Set to null on error
                imageUrl: map[
                    'image_url'], // Fetch image URL even on error if possible
                output: map['output'],
                breakdown: null, // Set to null to prevent freezing
              );
            }
          }).toList();
        });
  }

  /// Calls the 'translate-message' Edge Function, now with a target language.
  Future<Map<String, dynamic>> getTranslation(
      String text, String targetLanguage) async {
    final response = await _supabase.functions.invoke(
      'translate-text-message', // Updated function name
      body: {
        // 'type' field no longer needed if functions are separate
        'text': text,
        'target_language': targetLanguage
      },
    );
    return _handleFunctionResponse(response);
  }

  /// Calls the 'translate-message' Edge Function for OCR and translation.
  Future<Map<String, dynamic>> performOcrAndTranslate(
    Uint8List imageBytes, // Changed from imagePath to imageBytes
    String targetLanguage,
  ) async {
    final base64Image =
        base64Encode(imageBytes); // Encode image bytes to Base64
    final response = await _supabase.functions.invoke(
      'ocr-and-translate-image', // Updated function name
      body: {
        // 'type' field no longer needed if functions are separate
        'image': base64Image,
        'target_language': targetLanguage,
      },
    );

    return _handleFunctionResponse(response);
  }

  /// Uploads an image to Supabase Storage and returns its public URL.
  Future<String> uploadImage(
      {required Uint8List imageBytes, required String fileName}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated. Cannot upload image.');
    }
    // Construct a unique path for the image in storage.
    // Example: 'chat_images/user_id/timestamp_filename.png'
    // For simplicity, using fileName directly under user_id. Ensure fileName is unique.
    final filePath = '$userId/$fileName';

    await _supabase.storage.from('chat-images').uploadBinary(
          filePath,
          imageBytes,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    return _supabase.storage.from('chat-images').getPublicUrl(filePath);
  }

  // Helper method to handle common response logic from Edge Functions
  Map<String, dynamic> _handleFunctionResponse(FunctionResponse response) {
    if (response.status != 200) {
      // If the function returns an error, throw an exception with details.
      print('Edge function error: ${response.data}');
      throw Exception(
          'Failed to get translation. Status: ${response.status}, Body: ${response.data}');
    }
    // The Edge Function returns a JSON object, which is parsed into a Map.
    return response.data as Map<String, dynamic>;
  }

  /// Saves the complete, translated message to the database.
  Future<void> saveMessage({
    required String originalContent,
    required Map<String, dynamic> translationData,
    required String targetLanguage,
    String? imageUrl, // New parameter for the image URL
  }) async {
    final userId = _supabase.auth.currentUser!.id;

    // Build the full database row using both the original content
    // and the data returned from your detailed AI prompt.
    final messageToSave = {
      // For image messages, 'content' will store the extracted text from OCR.
      'content': originalContent,
      'sender_id': userId,
      'output': translationData['utterance'],
      'target_language': targetLanguage, // Correctly uses the passed language
      'romanisation': translationData['romanization'],
      'detected_language': translationData[
          'detected_language'], // Include detected language from function response
      'breakdown': translationData['breakdown'],
      'image_url': imageUrl, // Save the image URL
    };

    // Insert the complete row into the 'messages' table.
    await _supabase.from('messages').insert(messageToSave);
  }

  /// Deletes all messages for the current user.
  Future<void> clearChatHistory() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated. Cannot clear chat history.');
    }
    try {
      await _supabase.from('messages').delete().eq('sender_id', userId);
    } catch (e) {
      throw Exception('Failed to clear chat history from database: $e');
    }
  }

  // --- Favorite Phrases Methods ---

  /// Adds a message to the user's favorite phrases.
  Future<void> addFavoritePhrase({
    required String originalContent,
    required String translatedOutput,
    required String targetLanguageCode,
    String? romanisation,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated. Cannot add favorite.');
    }

    await _supabase.from('favorite_phrases').insert({
      'user_id': userId,
      'original_content': originalContent,
      'translated_output': translatedOutput,
      'target_language_code': targetLanguageCode,
      'romanisation': romanisation,
    });
  }

  /// Removes a phrase from the user's favorites by its ID.
  Future<void> removeFavoritePhrase(String favoriteId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated. Cannot remove favorite.');
    }
    // Ensure user can only delete their own favorites
    await _supabase
        .from('favorite_phrases')
        .delete()
        .eq('id', favoriteId)
        .eq('user_id', userId);
  }

  /// Gets a stream of the current user's favorite phrases.
  Stream<List<FavoritePhraseEntity>> getFavoritePhrases() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return Stream.value([]);
    }

    return _supabase
        .from('favorite_phrases')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false) // Show newest first
        .map((listOfMaps) {
          return listOfMaps
              .map((map) {
                try {
                  return FavoritePhraseEntity(
                    id: map['id'],
                    userId: map['user_id'],
                    originalContent: map['original_content'],
                    translatedOutput: map['translated_output'],
                    targetLanguageCode: map['target_language_code'],
                    romanisation: map['romanisation'],
                    createdAt: DateTime.parse(map['created_at']),
                  );
                } catch (e) {
                  print(
                      "Error parsing favorite phrase data: ${map.toString()}. Error: $e");
                  // In case of parsing error, you might want to filter it out or return a default
                  // For now, rethrowing or filtering might be best.
                  // This example will filter out malformed entries.
                  return null;
                }
              })
              .whereType<FavoritePhraseEntity>()
              .toList(); // Filter out nulls from parsing errors
        });
  }
}
