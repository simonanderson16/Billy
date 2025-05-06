import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:billy/core/theme/app_theme.dart';
import 'package:billy/features/auth/controllers/auth_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _displayNameController;
  late final TextEditingController _venmoHandleController;

  File? _newProfileImage;
  final _imagePicker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authControllerProvider);
    _displayNameController = TextEditingController(text: authState.displayName);
    _venmoHandleController = TextEditingController(text: authState.venmoHandle);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _venmoHandleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _newProfileImage = File(pickedFile.path);
      });
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        Uint8List? imageBytes;
        String? fileName;

        if (_newProfileImage != null) {
          imageBytes = await _newProfileImage!.readAsBytes();
          fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        }

        final authStateBeforeUpdate = ref.read(authControllerProvider);

        await ref
            .read(authControllerProvider.notifier)
            .updateUserProfile(
              displayName: _displayNameController.text.trim(),
              venmoHandle: _venmoHandleController.text.trim(),
              profileImage: imageBytes,
              fileName: fileName,
            );

        final authStateAfterUpdate = ref.read(authControllerProvider);
        if (authStateAfterUpdate.errorMessage != null) {
          throw Exception(authStateAfterUpdate.errorMessage);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating profile: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child:
                _isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  // Profile image
                  Hero(
                    tag: 'profile-image',
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              color: AppTheme.lightGrayColor,
                              shape: BoxShape.circle,
                              image:
                                  _newProfileImage != null
                                      ? DecorationImage(
                                        image: FileImage(_newProfileImage!),
                                        fit: BoxFit.cover,
                                      )
                                      : (authState.profileImageUrl != null
                                          ? DecorationImage(
                                            image: CachedNetworkImageProvider(
                                              authState.profileImageUrl!,
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                          : null),
                            ),
                            child:
                                (_newProfileImage == null &&
                                        authState.profileImageUrl == null)
                                    ? const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: AppTheme.mediumGrayColor,
                                    )
                                    : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              height: 36,
                              width: 36,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _pickImage,
                    child: const Text('Change Profile Picture'),
                  ),
                  const SizedBox(height: 24),
                  // Display name
                  TextFormField(
                    controller: _displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your display name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Venmo handle
                  TextFormField(
                    controller: _venmoHandleController,
                    decoration: const InputDecoration(
                      labelText: 'Venmo Handle (e.g., @username)',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Venmo handle';
                      }
                      if (!value.startsWith('@')) {
                        return 'Venmo handle should start with @';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Email (non-editable)
                  TextFormField(
                    initialValue: authState.email,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Email (Non-editable)',
                      prefixIcon: Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: AppTheme.lightGrayColor,
                    ),
                  ),
                  // Add a prominent save button at the bottom
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text(
                                'Save Profile',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
