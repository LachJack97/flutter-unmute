import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unmute/features/chat/domain/entities/message_entity.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isMe = message.senderId == currentUserId;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).primaryColor : Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(color: isMe ? Colors.white : Colors.black87),
            ),
            if (message.output != null) ...[
              const Divider(height: 8, thickness: 0.5),
              Text(
                message.output!,
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (message.romanisation != null)
              Text(
                message.romanisation!,
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                ),
              )
          ],
        ),
      ),
    );
  }
}
