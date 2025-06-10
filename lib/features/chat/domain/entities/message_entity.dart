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
  // --- THIS IS THE PERMANENT FIX ---
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
        breakdown,
      ];
}
