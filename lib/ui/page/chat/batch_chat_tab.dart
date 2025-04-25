import 'dart:io';
import 'dart:convert'; // <-- Add this import
import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/model/batch_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:gyansagar_frontend/helper/constants.dart'; // <-- Add this import

class BatchChatTab extends StatefulWidget {
  final BatchModel batchModel;
  const BatchChatTab({super.key, required this.batchModel});

  @override
  State<BatchChatTab> createState() => _BatchChatTabState();
}

class _BatchChatTabState extends State<BatchChatTab> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> messages = [];
  String? conversationId;

  @override
  void initState() {
    super.initState();
    _initConversation();
  }

  Future<void> _initConversation() async {
    final response = await http.post(
      Uri.parse('${Constants.productionBaseUrl}chat/conversation'),
      headers: {
        'Authorization': 'Bearer YOUR_TOKEN',
        'Content-Type': 'application/json',
      },
      body: '{"isGroup": true, "batchId": "${widget.batchModel.id}"}',
    );
    final data = response.statusCode == 200 ? (response.body) : null;
    if (data != null) {
      final conv = (jsonDecode(data))['conversation'];
      setState(() {
        conversationId = conv['_id'];
      });
      _fetchMessages();
    }
  }

  Future<void> _fetchMessages() async {
    if (conversationId == null) return;
    final response = await http.get(
      Uri.parse(
        '${Constants.productionBaseUrl}chat/conversation/$conversationId/messages',
      ),
      headers: {'Authorization': 'Bearer YOUR_TOKEN'},
    );
    if (response.statusCode == 200) {
      setState(() {
        messages = (jsonDecode(response.body))['messages'];
      });
    }
  }

  Future<void> _sendMessage({
    String? text,
    File? file,
    String? fileType,
  }) async {
    if (conversationId == null) return;
    var uri = Uri.parse(
      '${Constants.productionBaseUrl}chat/conversation/$conversationId/message',
    );
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer YOUR_TOKEN';
    if (text != null) {
      request.fields['content'] = text;
      request.fields['type'] = 'text';
    }
    if (file != null && fileType != null) {
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      request.fields['type'] = fileType;
    }
    await request.send();
    _controller.clear();
    _fetchMessages();
  }

  Future<void> _pickMedia(String type) async {
    File? file;
    if (type == 'image') {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) file = File(picked.path);
    } else if (type == 'video') {
      final picked = await ImagePicker().pickVideo(source: ImageSource.gallery);
      if (picked != null) file = File(picked.path);
    } else if (type == 'audio') {
      final result = await FilePicker.platform.pickFiles(type: FileType.audio);
      if (result != null && result.files.single.path != null) {
        file = File(result.files.single.path!);
      }
    }
    if (file != null) {
      await _sendMessage(file: file, fileType: type);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, idx) {
              final msg = messages[idx];
              // Display text, image, video, or audio based on msg['type']
              if (msg['type'] == 'image') {
                return Image.network('YOUR_API_BASE_URL${msg['fileUrl']}');
              } else if (msg['type'] == 'video') {
                return ListTile(
                  title: Text('Video message'),
                  subtitle: Text(msg['fileUrl']),
                );
              } else if (msg['type'] == 'audio') {
                return ListTile(
                  title: Text('Audio message'),
                  subtitle: Text(msg['fileUrl']),
                );
              } else {
                return ListTile(title: Text(msg['content'] ?? ''));
              }
            },
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.image),
              onPressed: () => _pickMedia('image'),
            ),
            IconButton(
              icon: Icon(Icons.videocam),
              onPressed: () => _pickMedia('video'),
            ),
            IconButton(
              icon: Icon(Icons.mic),
              onPressed: () => _pickMedia('audio'),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(hintText: 'Type a message...'),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                if (_controller.text.trim().isNotEmpty) {
                  _sendMessage(text: _controller.text.trim());
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
