import 'package:flutter/material.dart';
import 'package:unmute/features/chat/domain/entities/message_entity.dart';

/// A stateful widget to handle a single message exchange.
/// This includes the user's bubble and the AI's response bubble.
/// It manages the expanded/collapsed state for its own breakdown.
class ChatMessageItem extends StatefulWidget {
  final MessageEntity message;
  const ChatMessageItem({super.key, required this.message});

  @override
  State<ChatMessageItem> createState() => _ChatMessageItemState();
}

class _ChatMessageItemState extends State<ChatMessageItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // User's situation bubble
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.message.content,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // AI's response bubble, only shown if there is output.
          if (widget.message.output != null &&
              widget.message.output!.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.message.output!,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    if (widget.message.romanisation != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.message.romanisation!,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                    if (widget.message.breakdown != null &&
                        widget.message.breakdown!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Text(
                          _isExpanded ? 'Hide breakdown ↑' : 'Show breakdown ↓',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (_isExpanded)
                        _BreakdownList(breakdown: widget.message.breakdown!)
                    ]
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A private helper widget to display the list of breakdown parts.
class _BreakdownList extends StatelessWidget {
  final List<Map<String, dynamic>> breakdown;
  const _BreakdownList({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: breakdown.map((part) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${part['part'] ?? ''}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('— ${part['gloss'] ?? ''}'),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
