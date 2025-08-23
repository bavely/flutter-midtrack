import 'package:flutter/material.dart';

import '../../core/models/chat_message.dart';
import '../../core/theme/app_theme.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageWidget({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment:
          message.isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!message.isFromUser) ...[
          // AI Avatar
          CircleAvatar(
            backgroundColor: AppTheme.primaryColor,
            radius: 16,
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
        ],

        // Message Bubble
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: message.isFromUser
                  ? AppTheme.primaryColor
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18).copyWith(
                bottomRight: message.isFromUser
                    ? const Radius.circular(4)
                    : const Radius.circular(18),
                bottomLeft: message.isFromUser
                    ? const Radius.circular(18)
                    : const Radius.circular(4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: message.isFromUser
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    message.timeDisplay,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: message.isFromUser
                              ? Colors.white.withOpacity(0.7)
                              : Theme.of(context).colorScheme.outline,
                          fontSize: 10,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (message.isFromUser) ...[
          const SizedBox(width: 8),
          // User Avatar
          CircleAvatar(
            backgroundColor: AppTheme.secondaryColor,
            radius: 16,
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ],
    );
  }
}
