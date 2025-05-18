import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fotsd/main.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _stIdController;
  String? _department;
  late TextEditingController _degreeController;
  File? _profileImage; // Profile image file
  final ImagePicker _picker = ImagePicker();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _stIdController = TextEditingController();
    _degreeController = TextEditingController();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _nameController.text = userDoc['name'] ?? '';
          _emailController.text = userDoc['email'] ?? '';
          _stIdController.text = userDoc['stID'] ?? '';
          _department = userDoc['department'] ?? 'Information Technology';
          _degreeController.text = userDoc['degree'] ?? '';
          final imagePath = userDoc['pimage'] as String?;
          if (imagePath != null && imagePath.isNotEmpty) {
            _profileImage = File(imagePath);
          }
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      final user = _auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'pimage': pickedFile.path});
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final user = _auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'name': _nameController.text,
          'department': _department,
          'degree': _degreeController.text,
        });

        setState(() {
          _isEditing = false;
        });

        _showAlertDialog('Success', 'Profile updated successfully.');
      }
    }
  }

  void _showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _isEditing ? _pickImage : null,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : const NetworkImage(
                          'https://cdn2.iconfinder.com/data/icons/audio-16/96/user_avatar_profile_login_button_account_member-512.png',
                        ) as ImageProvider,
                  child: _isEditing
                      ? const Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(Icons.camera_alt,
                              color: Colors.white, size: 28),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 72, 237, 72),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Enrolled'),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'ID ',
                _stIdController,
                enabled: false,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                'Name',
                _nameController,
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              _buildTextField(
                'University Email',
                _emailController,
                enabled: false,
              ),
              const SizedBox(height: 10),
              _buildDropdownField(),
              const SizedBox(height: 10),
              _buildTextField(
                'Degree',
                _degreeController,
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your degree';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (_isEditing)
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Save Changes'),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _auth.signOut();
                  // ignore: use_build_context_synchronously
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FirstPage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Log Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        fillColor: enabled ? Colors.white : Colors.grey[200],
        filled: true,
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _department,
      decoration: InputDecoration(
        labelText: 'Department',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: const [
        DropdownMenuItem(
          value: 'Information Technology',
          child: Text('Information Technology'),
        ),
        DropdownMenuItem(
          value: 'Electronic And Electrical Technology',
          child: Text('Electronic And Electrical Technology'),
        ),
        DropdownMenuItem(
          value: 'Matterial Technology',
          child: Text('Matterial Technology'),
        ),
        DropdownMenuItem(
          value: 'Food Technology',
          child: Text('Food Technology'),
        ),
        DropdownMenuItem(
          value: 'Bio Process Technology',
          child: Text('Bio Process Technology'),
        ),
      ],
      onChanged: _isEditing
          ? (value) {
              setState(() {
                _department = value;
              });
            }
          : null,
    );
  }
}
