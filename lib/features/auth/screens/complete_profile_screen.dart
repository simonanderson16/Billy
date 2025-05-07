import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:billy/core/router/app_router.dart';
import 'package:billy/core/theme/app_theme.dart';
import 'package:billy/features/auth/controllers/auth_controller.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _venmoHandleController = TextEditingController();

  File? _profileImage;
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _completeProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        Uint8List? imageBytes;
        String? fileName;

        if (_profileImage != null) {
          imageBytes = await _profileImage!.readAsBytes();
          fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        }

        await ref
            .read(authControllerProvider.notifier)
            .updateUserProfile(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              venmoHandle: _venmoHandleController.text.trim(),
              profileImage: imageBytes,
              fileName: fileName,
            );

        final authState = ref.read(authControllerProvider);

        if (authState.errorMessage == null) {
          Navigator.of(context).pushReplacementNamed(AppRouter.homeRoute);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authState.errorMessage!),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error completing profile: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        automaticallyImplyLeading: false,
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
                  Text(
                    'Almost there!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.blackColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please complete your profile to continue',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.mediumGrayColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.lightGrayColor,
                        shape: BoxShape.circle,
                        image:
                            _profileImage != null
                                ? DecorationImage(
                                  image: FileImage(_profileImage!),
                                  fit: BoxFit.cover,
                                )
                                : null,
                      ),
                      child:
                          _profileImage == null
                              ? Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: AppTheme.mediumGrayColor,
                              )
                              : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _pickImage,
                    child: const Text('Add Profile Picture'),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 36),
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _completeProfile,
                    child:
                        authState.isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text('Complete Profile'),
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
