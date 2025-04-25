import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gyansagar_frontend/admin/utils/admin_preferences.dart'; // Add this import

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedRole = 'All';
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _teachers = [];
  List<dynamic> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final token = await AdminPreferences.getAdminToken();

      final teachersResponse = await http.get(
        Uri.parse('http://localhost:3000/api/admin/teachers'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final studentsResponse = await http.get(
        Uri.parse('http://localhost:3000/api/admin/students'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (teachersResponse.statusCode == 200 &&
          studentsResponse.statusCode == 200) {
        setState(() {
          _teachers = json.decode(teachersResponse.body)['teachers'];
          _students = json.decode(studentsResponse.body)['students'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading users: $e')));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addTeacher() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add New Teacher'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'Enter full name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter email address',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter password',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState?.validate() ?? false) {
                    try {
                      final token = await AdminPreferences.getAdminToken();
                      final response = await http.post(
                        Uri.parse('http://localhost:3000/api/admin/teachers'),
                        headers: {
                          'Authorization': 'Bearer $token',
                          'Content-Type': 'application/json',
                        },
                        body: jsonEncode({
                          'name': nameController.text.trim(),
                          'email': emailController.text.trim(),
                          'password': passwordController.text,
                        }),
                      );

                      if (!mounted) return;

                      if (response.statusCode == 200 ||
                          response.statusCode == 201) {
                        Navigator.pop(context);
                        await _fetchUsers(); // Wait for fetch to complete
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Teacher added successfully'),
                          ),
                        );
                      } else {
                        final responseBody = json.decode(response.body);
                        final errorMessage =
                            responseBody['email']?[0] ??
                            responseBody['message'] ??
                            'Failed to add teacher';
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(errorMessage)));
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  void _showEditUserDialog(BuildContext context, Map<String, dynamic> user) {
    final nameController = TextEditingController(text: user['name']);
    final emailController = TextEditingController(text: user['email']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final token = await AdminPreferences.getAdminToken();
                  final response = await http.put(
                    Uri.parse(
                      'http://localhost:3000/api/admin/users/${user['_id']}',
                    ),
                    headers: {
                      'Authorization': 'Bearer $token',
                      'Content-Type': 'application/json',
                    },
                    body: json.encode({
                      'name': nameController.text,
                      'email': emailController.text,
                    }),
                  );

                  if (!mounted) return;

                  if (response.statusCode == 200) {
                    await _fetchUsers(); // Wait for fetch to complete
                    if (!mounted) return;
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User updated successfully'),
                      ),
                    );
                  } else {
                    throw Exception('Failed to update user');
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating user: $e')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String userId, bool isTeacher) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete ${isTeacher ? 'Teacher' : 'Student'}'),
          content: Text('Are you sure you want to delete this ${isTeacher ? 'teacher' : 'student'}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final token = await AdminPreferences.getAdminToken();
                  final endpoint = isTeacher ? 'teachers' : 'students';
                  final response = await http.delete(
                    Uri.parse('http://localhost:3000/api/admin/$endpoint/$userId'),
                    headers: {'Authorization': 'Bearer $token'},
                  );

                  if (!mounted) return;

                  if (response.statusCode == 200) {
                    await _fetchUsers(); // Refresh the list
                    if (!mounted) return;
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${isTeacher ? 'Teacher' : 'Student'} deleted successfully')),
                    );
                  } else {
                    throw Exception('Failed to delete ${isTeacher ? 'teacher' : 'student'}');
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting ${isTeacher ? 'teacher' : 'student'}: $e')),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'User Management',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_tabController.index == 0) {
                      _addTeacher();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Teacher'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TabBar(
              controller: _tabController,
              tabs: const [Tab(text: 'Teachers'), Tab(text: 'Students')],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedRole,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'Active', child: Text('Active')),
                    DropdownMenuItem(
                      value: 'Inactive',
                      child: Text('Inactive'),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedRole = newValue;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUserList(isTeacher: true),
                  _buildUserList(isTeacher: false),
                ],
              ),
            ),
          ],
        ),
      ),
      // Remove the floatingActionButton
    );
  }

  Widget _buildUserList({required bool isTeacher}) {
    final users = isTeacher ? _teachers : _students;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            leading: CircleAvatar(child: Text(user['name'][0].toUpperCase())),
            title: Text(user['name']),
            subtitle: Text(user['email']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showEditUserDialog(context, user);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteConfirmationDialog(context, user['_id'], isTeacher);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String selectedRole = 'Student';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter user name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter email address',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Role'),
                  value: selectedRole,
                  items: const [
                    DropdownMenuItem(value: 'Student', child: Text('Student')),
                    DropdownMenuItem(value: 'Teacher', child: Text('Teacher')),
                  ],
                  onChanged: (String? value) {
                    if (value != null) {
                      selectedRole = value;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final response = await http.post(
                    Uri.parse('http://localhost:3000/api/admin/users'),
                    headers: {
                      'Authorization': 'Bearer YOUR_TOKEN_HERE',
                      'Content-Type': 'application/json',
                    },
                    body: json.encode({
                      'name': nameController.text,
                      'email': emailController.text,
                      'role': selectedRole,
                    }),
                  );

                  if (response.statusCode == 201) {
                    _fetchUsers(); // Refresh the list
                    Navigator.of(context).pop();
                  } else {
                    throw Exception('Failed to create user');
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error creating user: $e')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
