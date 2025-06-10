import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unmute/features/chat/domain/entities/message_entity.dart';

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

    await _supabase
        .from(
      'profiles',
    )
        .update({'target_language': languageCode}).eq('id', userId);
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
          .single(); // .single() expects one row or throws an error.

      // Ensure response is not empty and contains the target_language field.
      if (response.isNotEmpty && response['target_language'] != null) {
        return response['target_language'] as String;
      }
    } catch (e) {
      print('Error fetching target language: $e');
    }
    return null;
  }

  /// Stores the user's selected native language in their profile.
  Future<void> setNativeLanguage(String languageCode) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase
        .from('profiles')
        .update({'native_language': languageCode}).eq('id', userId);
  }

  /// Fetches the user's selected native language from their profile.
  Future<String?> getNativeLanguage() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final response = await _supabase
          .from('profiles')
          .select('native_language')
          .eq('id', userId)
          .single();

      if (response.isNotEmpty && response['native_language'] != null) {
        return response['native_language'] as String;
      }
    } catch (e) {
      // It's okay if native_language is not set, might be a new user.
      // Or if the column doesn't exist yet.
      print('Info: Could not fetch native language or not set: $e');
    }
    return null;
  }

  /// Subscribes to the real-time message stream from the 'messages' table.
  /// This listens for new messages being inserted or updated.
  Stream<List<MessageEntity>> getMessages() {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
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
                detectedLanguageCode:
                    map['detected_language'], // Map the new field
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
      'translate-message',
      body: {'text': text, 'target_language': targetLanguage},
    );

    if (response.status != 200) {
      // If the function returns an error, throw an exception with details.
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
  }) async {
    final userId = _supabase.auth.currentUser!.id;

    // Build the full database row using both the original content
    // and the data returned from your detailed AI prompt.
    final messageToSave = {
      'content': originalContent,
      'sender_id': userId,
      'output': translationData['utterance'],
      'target_language': targetLanguage, // Correctly uses the passed language
      'romanisation': translationData['romanization'],
      'detected_language': translationData[
          'detected_language'], // Include detected language from function response
      'breakdown': translationData['breakdown'],
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
}
