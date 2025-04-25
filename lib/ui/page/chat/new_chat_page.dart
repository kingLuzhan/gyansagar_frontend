import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gyansagar_frontend/helper/constants.dart';
import 'package:gyansagar_frontend/helper/shared_preference_helper.dart';

class NewChatPage extends StatefulWidget {
  final bool isGroup;

  const NewChatPage({super.key, required this.isGroup});

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  bool isLoading = true;
  List<dynamic> users = [];
  List<dynamic> batches = [];
  List<String> selectedUserIds = [];
  String? selectedBatchId;
  String? token;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    token = await SharedPreferenceHelper.getToken();
    if (widget.isGroup) {
      await _loadBatches();
    } else {
      await _loadUsers();
    }
  }

  Future<void> _loadUsers() async {
    print('Loading users...');
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          '${Constants.productionBaseUrl}${Constants.getAllStudentList}',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Users API Response Status: ${response.statusCode}');
      print('Users API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed Users Data: $data');
        setState(() {
          users = data['students'] ?? [];
          print('Number of users loaded: ${users.length}');
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorSnackBar('Failed to load users');
      }
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Error: $e');
    }
  }

  Future<void> _loadBatches() async {
    print('Loading batches...');
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${Constants.productionBaseUrl}${Constants.batch}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Batches API Response Status: ${response.statusCode}');
      print('Batches API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed Batches Data: $data');
        setState(() {
          batches = data['batches'] ?? [];
          print('Number of batches loaded: ${batches.length}');
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorSnackBar('Failed to load batches');
      }
    } catch (e) {
      print('Error loading batches: $e');
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Error: $e');
    }
  }

  Future<void> _createConversation() async {
    print('Creating conversation...');
    print('Is Group Chat: ${widget.isGroup}');
    print('Selected Batch ID: $selectedBatchId');
    print('Selected User IDs: $selectedUserIds');

    if (widget.isGroup && selectedBatchId == null) {
      _showErrorSnackBar('Please select a batch');
      return;
    }

    if (!widget.isGroup && selectedUserIds.isEmpty) {
      _showErrorSnackBar('Please select a user');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final userId = await SharedPreferenceHelper.getUserId();
      print('Current User ID: $userId');

      final Map<String, dynamic> body =
          widget.isGroup
              ? {'isGroup': true, 'batchId': selectedBatchId}
              : {
                'isGroup': false,
                'userIds': [userId, ...selectedUserIds],
              };

      print('Request Body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse('${Constants.productionBaseUrl}chat/conversation'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('Create Conversation API Response Status: ${response.statusCode}');
      print('Create Conversation API Response Body: ${response.body}');

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        _showErrorSnackBar('Failed to create conversation');
      }
    } catch (e) {
      print('Error creating conversation: $e');
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Error: $e');
    }
  }

  Widget _buildUserList() {
    print('Building user list. Number of users: ${users.length}');
    if (users.isEmpty) {
      return const Center(child: Text('No users found'));
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final userId = user['id']; // Changed from '_id' to 'id'
        print('User at index $index: $user');
        print('User ID: $userId');

        final isSelected = userId != null && selectedUserIds.contains(userId);
        print('Is Selected: $isSelected');

        return ListTile(
          leading: CircleAvatar(child: Text(user['name'][0])),
          title: Text(user['name']),
          subtitle: Text(user['email'] ?? ''),
          trailing:
              isSelected
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
          onTap: () {
            if (userId != null) {
              print('User tile tapped. User ID: $userId');
              setState(() {
                if (isSelected) {
                  selectedUserIds.remove(userId);
                  print('Removed user ID from selection: $userId');
                } else {
                  selectedUserIds = [userId];
                  print('Added user ID to selection: $userId');
                }
                print('Updated selected user IDs: $selectedUserIds');
              });
            } else {
              print('Tapped user has null ID');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User ID is missing')),
              );
            }
          },
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isGroup ? 'Select Batch' : 'Select User'),
        actions: [
          if (!isLoading &&
              ((widget.isGroup && selectedBatchId != null) ||
                  (!widget.isGroup && selectedUserIds.isNotEmpty)))
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _createConversation,
            ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : widget.isGroup
              ? _buildBatchList()
              : _buildUserList(),
    );
  }

  Widget _buildBatchList() {
    if (batches.isEmpty) {
      return const Center(child: Text('No batches found'));
    }

    return ListView.builder(
      itemCount: batches.length,
      itemBuilder: (context, index) {
        final batch = batches[index];
        final batchId = batch['_id'];
        final isSelected = selectedBatchId == batchId;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green,
            child: const Icon(Icons.group, color: Colors.white),
          ),
          title: Text(batch['name']),
          subtitle: Text('${batch['students']?.length ?? 0} students'),
          trailing:
              isSelected
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
          onTap: () {
            setState(() {
              selectedBatchId = isSelected ? null : batchId;
            });
          },
        );
      },
    );
  }
}
