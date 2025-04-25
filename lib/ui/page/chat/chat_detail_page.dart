import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:gyansagar_frontend/helper/constants.dart';
import 'package:gyansagar_frontend/helper/shared_preference_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChatDetailPage extends StatefulWidget {
  final String conversationId;
  final String title;
  final bool isGroup;

  const ChatDetailPage({
    super.key,
    required this.conversationId,
    required this.title,
    required this.isGroup,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  List<dynamic> messages = [];
  bool isLoading = true;
  String? token;
  String? userId;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    token = await SharedPreferenceHelper.getToken();
    userId = await SharedPreferenceHelper.getUserId();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          '${Constants.productionBaseUrl}chat/conversation/${widget.conversationId}/messages',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Message data: $data'); // Add this line
        setState(() {
          messages = data['messages'] ?? [];
          // Add this debug block
          for (var message in messages) {
            if (message['type'] == 'image') {
              print('Image URL: ${message['fileUrl']}');
            }
          }
          isLoading = false;
        });

        // Scroll to bottom after messages load
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorSnackBar('Failed to load messages');
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

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    _messageController.clear();
    final tempImage = _selectedImage;
    setState(() {
      _selectedImage = null;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          '${Constants.productionBaseUrl}chat/conversation/${widget.conversationId}/message',
        ),
      );

      request.headers['Authorization'] = 'Bearer $token';

      if (text.isNotEmpty) {
        request.fields['content'] = text;
        request.fields['type'] = 'text';
      }

      if (tempImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('file', tempImage.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        _fetchMessages();
      } else {
        _showErrorSnackBar('Failed to send message');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (widget.isGroup)
            IconButton(
              icon: const Icon(Icons.group),
              onPressed: () {
                // Show group members
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : messages.isEmpty
                    ? const Center(child: Text('No messages yet'))
                    : ListView.builder(
                      controller: _scrollController,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final bool isMe = message['sender']['_id'] == userId;
                        final messageType = message['type'] ?? 'text';

                        return _buildMessageBubble(
                          message,
                          isMe,
                          messageType,
                          index > 0 ? messages[index - 1] : null,
                        );
                      },
                    ),
          ),
          if (_selectedImage != null)
            Container(
              height: 70,
              color: Colors.grey[200],
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      border: InputBorder.none,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    dynamic message,
    bool isMe,
    String messageType,
    dynamic previousMessage,
  ) {
    final time = DateTime.parse(message['createdAt']);
    final formattedTime = DateFormat('h:mm a').format(time);

    // Check if we need to show the date header
    bool showDateHeader = false;
    if (previousMessage == null) {
      showDateHeader = true;
    } else {
      final previousTime = DateTime.parse(previousMessage['createdAt']);
      if (time.day != previousTime.day ||
          time.month != previousTime.month ||
          time.year != previousTime.year) {
        showDateHeader = true;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showDateHeader)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  DateFormat('MMMM d, yyyy').format(time),
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            ),
          ),
        Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMe && widget.isGroup)
                  Text(
                    message['sender']['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                if (messageType == 'text') Text(message['content'] ?? ''),
                if (messageType == 'file' && message['fileUrl'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      message['fileUrl'].startsWith('http')
                          ? message['fileUrl']
                          : '${Constants.productionBaseUrl.replaceAll('/api/', '')}/uploads/${message['fileUrl'].split('/').last}',
                      headers: {'Authorization': 'Bearer $token'},
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error');
                        print('Attempted URL: ${message['fileUrl']}');
                        return Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 40,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Failed to load image',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  formattedTime,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
