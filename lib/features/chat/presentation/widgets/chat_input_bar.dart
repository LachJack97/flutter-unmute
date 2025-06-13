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
            icon: Icon(Icons.image_outlined, color: Colors.grey[700]),
            onPressed: onImagePick, // Call the new callback
            tooltip: 'Pick image for OCR',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onFieldSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 4), // Adjusted spacing
          IconButton(
              icon: const Icon(Icons.send),
              style: ButtonStyle(
                  iconColor: MaterialStateProperty.all(Colors.orange[700])),
              onPressed: onSend),
        ],
      ),
    );
  }
}
