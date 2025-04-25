import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gyansagar_frontend/helper/constants.dart';
import 'package:gyansagar_frontend/helper/shared_preference_helper.dart';
import 'package:gyansagar_frontend/ui/page/chat/chat_detail_page.dart';
import 'package:gyansagar_frontend/ui/page/chat/new_chat_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<dynamic> conversations = [];
  bool isLoading = true;
  String? token;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    token = await SharedPreferenceHelper.getToken();
    userId = await SharedPreferenceHelper.getUserId();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${Constants.productionBaseUrl}chat/conversations'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          conversations = data['conversations'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorSnackBar('Failed to load conversations');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Error: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _createNewChat() async {
    // Show dialog to choose between direct message and group chat
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('New Conversation'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Direct Message'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToUserSelection(false);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.group),
                  title: const Text('Batch Chat'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToUserSelection(true);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _navigateToUserSelection(bool isGroup) async {
    // Navigate to user selection page
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewChatPage(isGroup: isGroup)),
    );

    if (result == true) {
      // Refresh conversations if a new one was created
      _fetchConversations();
    }
  }

  String _getDirectChatName(dynamic conversation) {
    if (conversation['members'] == null || userId == null) {
      return 'Direct Chat';
    }

    // Find the other user in the conversation
    final otherMember = (conversation['members'] as List).firstWhere(
      (member) => member['_id'] != userId,
      orElse: () => {'name': 'Unknown User'},
    );

    return otherMember['name'] ?? 'Direct Chat';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment),
            onPressed: _createNewChat,
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : conversations.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No conversations yet'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _createNewChat,
                      child: const Text('Start a new chat'),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (context, idx) {
                  final conv = conversations[idx];
                  final bool isGroup = conv['isGroup'] ?? false;
                  final String title =
                      isGroup
                          ? (conv['batch']?['name'] ?? 'Group Chat')
                          : _getDirectChatName(conv);

                  // Get last message if available
                  final lastMessage =
                      conv['lastMessage']?['content'] ?? 'No messages yet';
                  final lastMessageTime =
                      conv['lastMessage']?['createdAt'] != null
                          ? DateTime.parse(conv['lastMessage']['createdAt'])
                          : null;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isGroup ? Colors.green : Colors.blue,
                      child: Icon(
                        isGroup ? Icons.group : Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing:
                        lastMessageTime != null
                            ? Text(
                              _formatTime(lastMessageTime),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            )
                            : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ChatDetailPage(
                                conversationId: conv['_id'],
                                title: title,
                                isGroup: isGroup,
                              ),
                        ),
                      ).then((_) => _fetchConversations());
                    },
                  );
                },
              ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day) {
      // Today, show time
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day - 1) {
      // Yesterday
      return 'Yesterday';
    } else {
      // Show date
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}
