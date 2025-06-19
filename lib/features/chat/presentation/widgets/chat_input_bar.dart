import 'package:flutter/material.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onImagePick; // New callback for image picking

  const ChatInputBar(
      {super.key,
      required this.controller,
      required this.onSend,
      required this.onImagePick});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.image_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            onPressed: onImagePick, // Call the new callback
            tooltip: 'Pick image for OCR',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                  hintText: 'Type your message...',
                  // Border and fillColor will be handled by InputDecorationTheme
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
              onFieldSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 4), // Adjusted spacing
          IconButton(
              icon: Icon(Icons.send,
                  color: Theme.of(context).colorScheme.primary),
              onPressed: onSend),
        ],
      ),
    );
  }
}
