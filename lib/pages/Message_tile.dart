import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:friendly_chat/Theme/app_theme.dart';

class MessageTile extends StatefulWidget {
  final String message;
  final String sender;
  final bool sentByMe;
  final DateTime? timestamp;
  final bool isRead;
  final VoidCallback? onLongPress;

  const MessageTile({
    super.key,
    required this.message,
    required this.sender,
    required this.sentByMe,
    this.timestamp,
    this.isRead = false,
    this.onLongPress,
  });

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onLongPress: widget.onLongPress,
        child: Container(
          alignment:
              widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: widget.sentByMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!widget.sentByMe) ...[
                _buildAvatar(),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: _buildMessageBubble(),
              ),
              if (widget.sentByMe) ...[
                const SizedBox(width: 8),
                _buildAvatar(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: widget.sentByMe
          ? AppTheme.primaryColor.withOpacity(0.2)
          : Colors.grey[300],
      child: Text(
        widget.sender[0].toUpperCase(),
        style: TextStyle(
          color: widget.sentByMe ? AppTheme.primaryColor : Colors.grey[700],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMessageBubble() {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: widget.sentByMe
            ? AppTheme.sentMessageColor
            : AppTheme.receivedMessageColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppTheme.messageBubbleRadius),
          topRight: const Radius.circular(AppTheme.messageBubbleRadius),
          bottomLeft: Radius.circular(
              widget.sentByMe ? AppTheme.messageBubbleRadius : 4),
          bottomRight: Radius.circular(
              widget.sentByMe ? 4 : AppTheme.messageBubbleRadius),
        ),
        boxShadow: AppTheme.messageBubbleShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment:
            widget.sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            widget.sender,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: widget.sentByMe
                  ? Colors.white.withOpacity(0.9)
                  : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.message,
            style: TextStyle(
              fontSize: 15,
              color: widget.sentByMe ? Colors.white : Colors.black87,
            ),
          ),
          if (widget.timestamp != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(widget.timestamp!),
                  style: TextStyle(
                    fontSize: 11,
                    color: widget.sentByMe
                        ? Colors.white.withOpacity(0.7)
                        : Colors.grey[600],
                  ),
                ),
                if (widget.sentByMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    widget.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
