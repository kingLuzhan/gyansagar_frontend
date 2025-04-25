import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gyansagar_frontend/admin/utils/admin_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';

class CourseManagement extends StatefulWidget {
  const CourseManagement({Key? key}) : super(key: key);

  @override
  _CourseManagementState createState() => _CourseManagementState();
}

class _CourseManagementState extends State<CourseManagement> {
  List<dynamic> courses = [];
  List<dynamic> teachers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCourses();
    fetchTeachers();
  }

  Future<void> fetchTeachers() async {
    try {
      final token = await AdminPreferences.getAdminToken();
      print('Admin Token: $token'); // Debug token

      final response = await http.get(
        Uri.parse('http://localhost:3000/api/admin/teachers'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Teachers Response Status: ${response.statusCode}');
      print('Teachers Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          teachers = data['teachers'];
        });
      } else {
        throw Exception('Failed to fetch teachers: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchTeachers: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching teachers: $e')));
    }
  }

  Future<void> fetchCourses() async {
    try {
      final token = await AdminPreferences.getAdminToken();
      print('Admin Token: $token'); // Debug token

      final response = await http.get(
        Uri.parse('http://localhost:3000/api/admin/courses'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Courses Response Status: ${response.statusCode}');
      print('Courses Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          courses = data['courses'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch courses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchCourses: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching courses: $e')));
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/api/admin/courses/$courseId'),
        headers: {
          'Authorization': 'Bearer ${await AdminPreferences.getAdminToken()}',
        },
      );

      if (response.statusCode == 200) {
        fetchCourses(); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course deleted successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting course: $e')));
    }
  }

  XFile? thumbnailFile;
  XFile? teacherPhotoFile;

  Future<void> _showAddEditCourseDialog([Map<String, dynamic>? course]) {
    final titleController = TextEditingController(text: course?['title'] ?? '');
    final descriptionController = TextEditingController(
      text: course?['description'] ?? '',
    );
    final priceController = TextEditingController(
      text: course?['price']?.toString() ?? '',
    );
    String? selectedTeacherId = course?['teacher']?['_id'];

    return showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(course == null ? 'Add Course' : 'Edit Course'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Course Title',
                          ),
                        ),
                        TextField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                          maxLines: 3,
                        ),
                        TextField(
                          controller: priceController,
                          decoration: const InputDecoration(labelText: 'Price'),
                          keyboardType: TextInputType.number,
                        ),
                        DropdownButtonFormField<String>(
                          value: selectedTeacherId,
                          hint: const Text('Select Teacher'),
                          items:
                              teachers.map<DropdownMenuItem<String>>((teacher) {
                                return DropdownMenuItem<String>(
                                  value: teacher['_id'] as String,
                                  child: Text(
                                    '${teacher['name']} (${teacher['email']})',
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedTeacherId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        // Thumbnail Image Picker
                        ListTile(
                          title: const Text('Course Thumbnail'),
                          trailing: IconButton(
                            icon: const Icon(Icons.upload),
                            onPressed: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (image != null) {
                                setState(() {
                                  thumbnailFile = image;
                                });
                              }
                            },
                          ),
                          subtitle:
                              thumbnailFile != null
                                  ? Text('Selected: ${thumbnailFile!.name}')
                                  : null,
                        ),
                        // Teacher Photo Picker
                        ListTile(
                          title: const Text('Teacher Photo'),
                          trailing: IconButton(
                            icon: const Icon(Icons.upload),
                            onPressed: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (image != null) {
                                setState(() {
                                  teacherPhotoFile = image;
                                });
                              }
                            },
                          ),
                          subtitle:
                              teacherPhotoFile != null
                                  ? Text('Selected: ${teacherPhotoFile!.name}')
                                  : null,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        try {
                          final url =
                              course == null
                                  ? 'http://localhost:3000/api/admin/courses'
                                  : 'http://localhost:3000/api/admin/courses/${course['_id']}';

                          // Inside _showAddEditCourseDialog method, modify the request creation part:
                          final request = http.MultipartRequest(
                            course == null ? 'POST' : 'PUT',
                            Uri.parse(url),
                          );

                          // Add text fields
                          request.fields['title'] = titleController.text;
                          request.fields['description'] =
                              descriptionController.text;
                          request.fields['price'] = priceController.text;
                          request.fields['teacherId'] = selectedTeacherId ?? '';

                          // Add files if selected
                          if (thumbnailFile != null) {
                            final bytes = await thumbnailFile!.readAsBytes();
                            final multipartFile = http.MultipartFile.fromBytes(
                              'thumbnail',
                              bytes,
                              filename: thumbnailFile!.name,
                              contentType: MediaType('image', 'jpeg'),
                            );
                            request.files.add(multipartFile);
                          }

                          if (teacherPhotoFile != null) {
                            final bytes = await teacherPhotoFile!.readAsBytes();
                            final multipartFile = http.MultipartFile.fromBytes(
                              'teacherPhoto',
                              bytes,
                              filename: teacherPhotoFile!.name,
                              contentType: MediaType('image', 'jpeg'),
                            );
                            request.files.add(multipartFile);
                          }

                          // Add headers
                          request.headers.addAll({
                            'Authorization':
                                'Bearer ${await AdminPreferences.getAdminToken()}',
                            'Content-Type': 'multipart/form-data',
                          });

                          try {
                            final streamedResponse = await request.send();
                            final response = await http.Response.fromStream(
                              streamedResponse,
                            );

                            if (response.statusCode == 200 ||
                                response.statusCode == 201) {
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              fetchCourses(); // Refresh the list
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    course == null
                                        ? 'Course created successfully'
                                        : 'Course updated successfully',
                                  ),
                                ),
                              );
                            } else {
                              throw Exception(
                                'Failed to ${course == null ? 'create' : 'update'} course: ${response.body}',
                              );
                            }
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      },
                      child: Text(course == null ? 'Create' : 'Update'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _showAddVideoDialog(String courseId) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    XFile? videoFile;

    return showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Add Video'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Video Title',
                          ),
                        ),
                        TextField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          title: const Text('Video File'),
                          trailing: IconButton(
                            icon: const Icon(Icons.upload),
                            onPressed: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? video = await picker.pickVideo(
                                source: ImageSource.gallery,
                              );
                              if (video != null) {
                                setState(() {
                                  videoFile = video;
                                });
                              }
                            },
                          ),
                          subtitle:
                              videoFile != null
                                  ? Text('Selected: ${videoFile!.name}')
                                  : null,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (videoFile == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a video file'),
                            ),
                          );
                          return;
                        }

                        final request = http.MultipartRequest(
                          'POST',
                          Uri.parse(
                            'http://localhost:3000/api/course/$courseId/video',
                          ),
                        );

                        request.fields['title'] = titleController.text;
                        request.fields['description'] =
                            descriptionController.text;

                        final bytes = await videoFile!.readAsBytes();
                        final multipartFile = http.MultipartFile.fromBytes(
                          'video',
                          bytes,
                          filename: videoFile!.name,
                        );
                        request.files.add(multipartFile);

                        request.headers['Authorization'] =
                            'Bearer ${await AdminPreferences.getAdminToken()}';

                        try {
                          final streamedResponse = await request.send();
                          final response = await http.Response.fromStream(
                            streamedResponse,
                          );

                          if (response.statusCode == 200 ||
                              response.statusCode == 201) {
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Video uploaded successfully'),
                              ),
                            );
                          } else {
                            throw Exception(
                              'Failed to upload video: ${response.body}',
                            );
                          }
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      },
                      child: const Text('Upload'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _showAddMaterialDialog(String courseId) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    PlatformFile? materialFile;

    return showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Add Material'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Material Title',
                          ),
                        ),
                        TextField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          title: const Text('Material File'),
                          trailing: IconButton(
                            icon: const Icon(Icons.upload),
                            onPressed: () async {
                              try {
                                final result = await FilePicker.platform
                                    .pickFiles(
                                      type: FileType.any,
                                      allowMultiple: false,
                                    );
                                if (result != null && result.files.isNotEmpty) {
                                  setState(() {
                                    materialFile = result.files.first;
                                  });
                                }
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error picking file: $e'),
                                  ),
                                );
                              }
                            },
                          ),
                          subtitle:
                              materialFile != null
                                  ? Text('Selected: ${materialFile!.name}')
                                  : null,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (materialFile == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a material file'),
                            ),
                          );
                          return;
                        }

                        try {
                          final request = http.MultipartRequest(
                            'POST',
                            Uri.parse(
                              'http://localhost:3000/api/course/$courseId/material',
                            ),
                          );

                          request.fields['title'] = titleController.text;
                          request.fields['description'] =
                              descriptionController.text;

                          // Handle file upload based on platform
                          if (kIsWeb) {
                            // For web platform
                            request.files.add(
                              http.MultipartFile.fromBytes(
                                'material',
                                materialFile!.bytes!,
                                filename: materialFile!.name,
                              ),
                            );
                          } else {
                            // For mobile/desktop platforms
                            final file = File(materialFile!.path!);
                            request.files.add(
                              await http.MultipartFile.fromPath(
                                'material',
                                file.path,
                                filename: materialFile!.name,
                              ),
                            );
                          }

                          request.headers['Authorization'] =
                              'Bearer ${await AdminPreferences.getAdminToken()}';

                          final streamedResponse = await request.send();
                          final response = await http.Response.fromStream(
                            streamedResponse,
                          );

                          if (response.statusCode == 200 ||
                              response.statusCode == 201) {
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Material uploaded successfully'),
                              ),
                            );
                          } else {
                            throw Exception(
                              'Failed to upload material: ${response.body}',
                            );
                          }
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error uploading material: $e'),
                            ),
                          );
                        }
                      },
                      child: const Text('Upload'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _viewCourseDetails(String courseId) async {
    try {
      final token = await AdminPreferences.getAdminToken();
      print('Fetching course details for ID: $courseId'); // Debug log

      final response = await http.get(
        Uri.parse('http://localhost:3000/api/course/$courseId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        _showCourseDetailsDialog(data['course']);
      } else {
        throw Exception('Failed to fetch course details');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showCourseDetailsDialog(Map<String, dynamic> course) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Course Details: ${course['title']}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          labelColor: Colors.blue,
                          tabs: [Tab(text: 'Videos'), Tab(text: 'Materials')],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // Videos Tab
                              _buildVideosList(course['videos'] ?? []),
                              // Materials Tab
                              _buildMaterialsList(course['materials'] ?? []),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideosList(List<dynamic> videos) {
    return videos.isEmpty
        ? const Center(child: Text('No videos available'))
        : ListView.builder(
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: const Icon(Icons.video_library),
                title: Text(video['title'] ?? 'Untitled Video'),
                subtitle: Text(video['description'] ?? 'No description'),
                trailing: IconButton(
                  icon: const Icon(Icons.play_circle_outline),
                  onPressed: () {
                    // Handle video playback
                    _playVideo(video['videoUrl']);
                  },
                ),
              ),
            );
          },
        );
  }

  Widget _buildMaterialsList(List<dynamic> materials) {
    return materials.isEmpty
        ? const Center(child: Text('No materials available'))
        : ListView.builder(
          itemCount: materials.length,
          itemBuilder: (context, index) {
            final material = materials[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: const Icon(Icons.article),
                title: Text(material['title'] ?? 'Untitled Material'),
                subtitle: Text(material['description'] ?? 'No description'),
                trailing: IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    // Handle material download
                    _downloadMaterial(material['fileUrl']);
                  },
                ),
              ),
            );
          },
        );
  }

  void _playVideo(String? videoUrl) {
    if (videoUrl == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Video URL not available')));
      return;
    }

    // Construct the full URL using the backend's file structure
    final String fullUrl =
        videoUrl.startsWith('http')
            ? videoUrl
            : 'http://localhost:3000/$videoUrl';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Video Player',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.play_circle_outline),
                      label: const Text('Open Video'),
                      onPressed: () async {
                        final Uri url = Uri.parse(fullUrl);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not launch video player'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _downloadMaterial(String? fileUrl) {
    if (fileUrl == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('File URL not available')));
      return;
    }
    // Implement file download functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Downloading file: $fileUrl')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Management')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(course['title'] ?? 'No Title'),
                      subtitle: Text(course['description'] ?? 'No Description'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility),
                            onPressed: () => _viewCourseDetails(course['_id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.video_library),
                            onPressed: () => _showAddVideoDialog(course['_id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.attach_file),
                            onPressed:
                                () => _showAddMaterialDialog(course['_id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showAddEditCourseDialog(course),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => deleteCourse(course['_id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditCourseDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
