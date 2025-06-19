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
  final String? localImagePath; // For instant display from local file
  final bool isUploadingImage; // To show a sending/uploading indicator for this specific image
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
    this.localImagePath,
    this.isUploadingImage = false,
    this.imageUrl,
    this.breakdown,
  });

  MessageEntity copyWith({
    String? id,
    String? content,
    String? senderId,
    DateTime? createdAt,
    String? output,
    String? targetLanguage,
    String? romanisation,
    String? detectedLanguageCode,
    String? localImagePath,
    bool? isUploadingImage,
    String? imageUrl,
    List<Map<String, dynamic>>? breakdown,
    bool clearLocalImagePath = false,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      createdAt: createdAt ?? this.createdAt,
      output: output ?? this.output,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      romanisation: romanisation ?? this.romanisation,
      detectedLanguageCode: detectedLanguageCode ?? this.detectedLanguageCode,
      localImagePath: clearLocalImagePath ? null : localImagePath ?? this.localImagePath,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      imageUrl: imageUrl ?? this.imageUrl,
      breakdown: breakdown ?? this.breakdown,
    );
  }

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
        localImagePath,
        isUploadingImage,
        imageUrl,
        breakdown,
      ];
}
