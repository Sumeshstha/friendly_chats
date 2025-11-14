import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:friendly_chat/Widgets/widgets.dart';
import 'package:friendly_chat/pages/Homepage.dart';
import 'package:friendly_chat/pages/Message_tile.dart';
import 'package:friendly_chat/pages/ProfilePage.dart';
import 'package:friendly_chat/services/database_service.dart';
import 'package:friendly_chat/Theme/app_theme.dart';
import 'package:intl/intl.dart';
import '../Components/my_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  final String currentUserName;
  final String chatId;
  final String friendName;
  const ChatPage({
    Key? key,
    required this.currentUserName,
    required this.chatId,
    required this.friendName,
  });
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream? messages;
  final currentMessage = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = true;
  bool _isTyping = false;
  bool _isOnline = true;
  bool _isAttaching = false;
  final List<String> _recentEmojis = ['😊', '👍', '❤️', '😂', '🙏'];

  @override
  void initState() {
    getStream();
    super.initState();
  }

  getStream() async {
    setState(() => _isLoading = true);
    await DatabaseService().getChatMessages(widget.chatId).then((value) {
      setState(() {
        messages = value;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: getMessages(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppTheme.surfaceColor,
      leading: IconButton(
        icon:
            const Icon(Icons.arrow_back_ios, color: AppTheme.primaryTextColor),
        onPressed: () => goto(context, HomePage()),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.video_call, color: AppTheme.primaryTextColor),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.call, color: AppTheme.primaryTextColor),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppTheme.primaryTextColor),
          onPressed: () => _showChatOptions(),
        ),
      ],
      title: FutureBuilder<String>(
        future: DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
            .getUserProfilePicture(widget.friendName),
        builder: (context, snapshot) {
          String profilePic = '';
          if (snapshot.hasData) {
            profilePic = snapshot.data ?? '';
          }
          
          return Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                backgroundImage: (profilePic.isNotEmpty)
                    ? NetworkImage(profilePic)
                    : null,
                child: (profilePic.isEmpty)
                    ? Text(
                        widget.friendName[0].toUpperCase(),
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.friendName,
                    style: const TextStyle(
                      color: AppTheme.primaryTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isOnline ? AppTheme.successColor : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      if (_isTyping) ...[
                        const SizedBox(width: 4),
                        const Text(
                          'typing...',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: AppTheme.cardShadow,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              if (_isAttaching) _buildAttachmentOptions(),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isAttaching ? Icons.close : Icons.attach_file,
                      color: AppTheme.primaryColor,
                    ),
                    onPressed: () =>
                        setState(() => _isAttaching = !_isAttaching),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                // Simulate typing indicator
                                if (value.isNotEmpty && !_isTyping) {
                                  setState(() => _isTyping = true);
                                  Future.delayed(const Duration(seconds: 2),
                                      () {
                                    if (mounted)
                                      setState(() => _isTyping = false);
                                  });
                                }
                              },
                              onSubmitted: (value) {
                                _focusNode.requestFocus();
                                sendMessages();
                                scrollToBottom();
                              },
                              focusNode: _focusNode,
                              controller: currentMessage,
                              decoration: InputDecoration(
                                hintText: 'Type your message',
                                hintStyle: TextStyle(color: Colors.grey[500]),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.emoji_emotions_outlined),
                            color: AppTheme.primaryColor,
                            onPressed: _showEmojiPicker,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      color: Colors.white,
                      onPressed: () {
                        sendMessages();
                        scrollToBottom();
                      },
                      icon: const Icon(Icons.send),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentOptions() {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildAttachmentOption(Icons.image, 'Gallery', () {}),
          _buildAttachmentOption(Icons.camera_alt, 'Camera', () {}),
          _buildAttachmentOption(Icons.insert_drive_file, 'Document', () {}),
          _buildAttachmentOption(Icons.location_on, 'Location', () {}),
          _buildAttachmentOption(Icons.person, 'Contact', () {}),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption(
      IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentEmojis
                  .map((emoji) => _buildEmojiButton(emoji))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiButton(String emoji) {
    return InkWell(
      onTap: () {
        currentMessage.text += emoji;
        Navigator.pop(context);
      },
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 20)),
      ),
    );
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search in conversation'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Mute notifications'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Change theme'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title:
                  const Text('Clear chat', style: TextStyle(color: Colors.red)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget getMessages() {
    return StreamBuilder(
      stream: messages,
      builder: ((context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: getStream,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (_isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline,
                    size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No messages yet',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start a conversation with ${widget.friendName}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          scrollDirection: Axis.vertical,
          controller: _scrollController,
          itemCount: snapshot.data.docs.length,
          itemBuilder: ((context, index) {
            final message = snapshot.data.docs[index];
            final isMe = widget.currentUserName == message['messageSender'];
            final timestamp =
                DateTime.fromMillisecondsSinceEpoch(message['messageTime']);

            // Group messages by date
            final showDate = index == 0 ||
                _shouldShowDate(
                    timestamp,
                    DateTime.fromMillisecondsSinceEpoch(
                        snapshot.data.docs[index - 1]['messageTime']));

            return Column(
              children: [
                if (showDate) _buildDateDivider(timestamp),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: MessageTile(
                    message: message['message'],
                    sender: message['messageSender'],
                    sentByMe: isMe,
                    timestamp: timestamp,
                    isRead: isMe && index == snapshot.data.docs.length - 1,
                    onLongPress: () => _showMessageOptions(message),
                  ),
                ),
              ],
            );
          }),
        );
      }),
    );
  }

  bool _shouldShowDate(DateTime current, DateTime previous) {
    return !DateUtils.isSameDay(current, previous);
  }

  Widget _buildDateDivider(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[300])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _formatDate(date),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[300])),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    if (DateUtils.isSameDay(date, now)) {
      return 'Today';
    } else if (DateUtils.isSameDay(date, yesterday)) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  void _showMessageOptions(Map<String, dynamic> message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: message['message']));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message copied to clipboard')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.forward),
              title: const Text('Forward'),
              onTap: () {},
            ),
            if (widget.currentUserName == message['messageSender'])
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {},
              ),
          ],
        ),
      ),
    );
  }

  void sendMessages() {
    if (currentMessage.text.trim().isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": currentMessage.text.trim(),
        "messageSender": widget.currentUserName,
        "messageTime": DateTime.now().millisecondsSinceEpoch
      };
      DatabaseService().sendMessage(widget.chatId, messageMap);
      setState(() {
        currentMessage.clear();
      });
    }
  }
}
