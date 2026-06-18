import 'package:capstone_2026/core/presentation/component/network/app_network_image.dart';
import 'dart:io';
import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nicknameController;
  final firebase.User? _user = firebase.FirebaseAuth.instance.currentUser;
  String? _phone;
  String? _imageUrl;
  File? _pickedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(
      text: _user?.displayName ?? '',
    );
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final uid = _user?.uid;
    if (uid == null) return;
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('phone, image_url')
          .eq('id', uid)
          .maybeSingle();
      if (mounted) {
        setState(() {
          _phone = response?['phone'] as String?;
          final raw = response?['image_url'] as String?;
          final supabaseImage = (raw != null && raw.isNotEmpty) ? raw : null;
          _imageUrl = supabaseImage ?? _user?.photoURL;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _imageUrl = _user?.photoURL);
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null && mounted) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<String?> _uploadImage(File file) async {
    final uid = _user?.uid;
    if (uid == null) return null;
    final ext = file.path.split('.').last.toLowerCase();
    final path = 'avatars/$uid.$ext';
    await Supabase.instance.client.storage
        .from('profiles')
        .upload(path, file, fileOptions: const FileOptions(upsert: true));
    return Supabase.instance.client.storage.from('profiles').getPublicUrl(path);
  }

  Future<void> _submit() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      AppSnackBar.showError(context, '닉네임을 입력해 주세요.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? newImageUrl;
      if (_pickedImage != null) {
        newImageUrl = await _uploadImage(_pickedImage!);
      }

      await _user?.updateDisplayName(nickname);
      await firebase.FirebaseAuth.instance.currentUser?.reload();

      final updateData = <String, dynamic>{'name': nickname};
      if (newImageUrl != null) updateData['image_url'] = newImageUrl;

      await Supabase.instance.client
          .from('users')
          .update(updateData)
          .eq('id', _user?.uid ?? '');

      if (!mounted) return;
      AppSnackBar.showSuccess(context, '프로필 수정이 완료되었습니다.');

      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      context.go(Routes.myPage);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        '프로필 저장에 실패했습니다. 잠시 후 다시 시도해 주세요.',
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '프로필 수정',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _submit,
                  child: const Text(
                    '저장',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDDDDDD),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: _pickedImage != null
                            ? Image.file(_pickedImage!, fit: BoxFit.cover)
                            : _imageUrl != null
                            ? AppNetworkImage(
                                _imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, e, st) => const Icon(
                                  Icons.person_rounded,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.person_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 36),
            const Text(
              '닉네임',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nicknameController,
              decoration: _inputDecoration(hintText: '닉네임을 입력해 주세요.'),
            ),
            const SizedBox(height: 20),
            const Text(
              '이메일',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _ReadOnlyField(value: '${_user?.email ?? '-'} (변경 불가)'),
            const SizedBox(height: 20),
            const Text(
              '휴대폰',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _ReadOnlyField(value: _phone ?? '-'),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surfaceMuted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String value;
  const _ReadOnlyField({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        value,
        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
    );
  }
}
