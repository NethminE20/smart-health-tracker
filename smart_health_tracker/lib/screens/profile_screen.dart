import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rive/rive.dart' as rive;
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? profile;
  bool loading = true;
  bool editing = false;

  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _bioController;
  File? _selectedImage;

  late final AnimationController _controller;
  late final Animation<Color?> _color1;
  late final Animation<Color?> _color2;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _bioController = TextEditingController();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _color1 = ColorTween(
      begin: Colors.blue.shade400,
      end: Colors.purple.shade400,
    ).animate(_controller);

    _color2 = ColorTween(
      begin: Colors.teal.shade400,
      end: Colors.indigo.shade400,
    ).animate(_controller);

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await ApiService.getProfile();
    setState(() {
      profile = data;
      loading = false;
      _nameController.text = data?['name'] ?? '';
      _ageController.text = data?['age']?.toString() ?? '';
      _bioController.text = data?['bio'] ?? '';
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() => loading = true);
    final success = await ApiService.updateProfile(
      name: _nameController.text,
      age: int.tryParse(_ageController.text),
      bio: _bioController.text,
      file: _selectedImage,
    );
    setState(() => loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
      setState(() => editing = false);
      _loadProfile();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update profile")),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            "My Profile",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        body: Stack(
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _color1.value ?? Colors.blue,
                    _color2.value ?? Colors.teal,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Animated Rive character in the background
            Positioned.fill(
              child: Opacity(
                opacity: 0.25,
                child: rive.RiveAnimation.asset(
                  "assets/character.riv", // make sure to add in pubspec.yaml
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Profile Content
            loading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(
                        top: 120, left: 16, right: 16, bottom: 24),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            width: double.infinity,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Avatar
                                GestureDetector(
                                  onTap: editing ? _pickImage : null,
                                  child: CircleAvatar(
                                    radius: 56,
                                    backgroundColor:
                                        Colors.white.withOpacity(0.3),
                                    backgroundImage: _selectedImage != null
                                        ? FileImage(_selectedImage!)
                                        : null,
                                    child: _selectedImage == null
                                        ? const Icon(Icons.person,
                                            size: 60, color: Colors.white)
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // Name
                                editing
                                    ? TextField(
                                        controller: _nameController,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.white),
                                        decoration: InputDecoration(
                                          labelText: "Name",
                                          labelStyle: const TextStyle(
                                              color: Colors.white70),
                                          filled: true,
                                          fillColor:
                                              Colors.white.withOpacity(0.2),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        profile?['name'] ?? 'No name',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                const SizedBox(height: 12),

                                // Email
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.email,
                                        color: Colors.white70),
                                    const SizedBox(width: 8),
                                    Text(
                                      profile?['email'] ?? 'N/A',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Age
                                editing
                                    ? TextField(
                                        controller: _ageController,
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(
                                            color: Colors.white),
                                        decoration: InputDecoration(
                                          labelText: "Age",
                                          labelStyle: const TextStyle(
                                              color: Colors.white70),
                                          filled: true,
                                          fillColor:
                                              Colors.white.withOpacity(0.2),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        "Age: ${profile?['age']?.toString() ?? 'N/A'}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                const SizedBox(height: 12),

                                // Bio
                                editing
                                    ? TextField(
                                        controller: _bioController,
                                        maxLines: 3,
                                        style: const TextStyle(
                                            color: Colors.white),
                                        decoration: InputDecoration(
                                          labelText: "Bio",
                                          labelStyle: const TextStyle(
                                              color: Colors.white70),
                                          filled: true,
                                          fillColor:
                                              Colors.white.withOpacity(0.2),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        "Bio: ${profile?['bio'] ?? 'No bio'}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                const SizedBox(height: 22),

                                // Save/Edit button
                                ElevatedButton.icon(
                                  onPressed: () {
                                    if (editing) {
                                      _updateProfile();
                                    } else {
                                      setState(() => editing = true);
                                    }
                                  },
                                  icon: Icon(
                                    editing ? Icons.save : Icons.edit,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    editing ? "Save Changes" : "Edit Profile",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.blueAccent.withOpacity(0.8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 35, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
