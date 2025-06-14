// In lib/features/chat/domain/entities/message_entity.dart

import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String content;
  final String senderId;
  final DateTime createdAt;

  final String? output;
  final String? targetLanguage;
  final String? romanisation;
  final String? detectedLanguageCode; // Add this field
  // --- THIS IS THE PERMANENT FIX ---
  final String? imageUrl; // To store the URL of the sent image
  // Change this field from Map? to a List of Maps?
  final List<Map<String, dynamic>>? breakdown;

  const MessageEntity({
    required this.id,
    required this.content,
    required this.senderId,
    required this.createdAt,
    this.output,
    this.targetLanguage,
    this.romanisation,
    this.detectedLanguageCode, // Add this to the constructor
    this.imageUrl,
    this.breakdown,
  });

  @override
  List<Object?> get props => [
        id,
        content,
        senderId,
        createdAt,
        output,
        targetLanguage,
        romanisation,
        detectedLanguageCode, // Add this to props
        imageUrl,
        breakdown,
      ];
}
