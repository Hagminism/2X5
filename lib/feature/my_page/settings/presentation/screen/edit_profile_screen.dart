import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nicknameController;
  final firebase.User? _user = firebase.FirebaseAuth.instance.currentUser;
  String? _phone;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(
      text: _user?.displayName ?? '',
    );
    _fetchPhone();
  }

  Future<void> _fetchPhone() async {
    final uid = _user?.uid;
    if (uid == null) return;
    final response = await Supabase.instance.client
        .from('users')
        .select('phone')
        .eq('id', uid)
        .maybeSingle();
    if (mounted) {
      setState(() => _phone = response?['phone'] as String?);
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nickname = _nicknameController.text.trim();

    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('닉네임을 입력해 주세요.')),
        );
      return;
    }

    await _user?.updateDisplayName(nickname);
    await firebase.FirebaseAuth.instance.currentUser?.reload();
    await Supabase.instance.client
        .from('users')
        .update({'name': nickname})
        .eq('id', _user?.uid ?? '');

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('프로필 수정이 완료되었습니다.')),
      );

    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    context.go(Routes.myPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F0F172A),
                      blurRadius: 20,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context.go(Routes.myPage),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          ),
                          const SizedBox(width: 4),
                          const Text('프로필 수정', style: AppTextStyles.headline),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '닉네임만 변경할 수 있어요.',
                        style: AppTextStyles.subtitle,
                      ),
                      const SizedBox(height: 24),
                      const Text('이름', style: AppTextStyles.label),
                      const SizedBox(height: 8),
                      _ReadOnlyField(
                        value: _user?.displayName ?? '-',
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 16),
                      const Text('이메일', style: AppTextStyles.label),
                      const SizedBox(height: 8),
                      _ReadOnlyField(
                        value: _user?.email ?? '-',
                        icon: Icons.alternate_email_rounded,
                      ),
                      const SizedBox(height: 16),
                      const Text('전화번호', style: AppTextStyles.label),
                      const SizedBox(height: 8),
                      _ReadOnlyField(
                        value: _phone ?? '-',
                        icon: Icons.phone_outlined,
                      ),
                      const SizedBox(height: 16),
                      const Text('닉네임', style: AppTextStyles.label),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nicknameController,
                        decoration: _inputDecoration(
                          hintText: '닉네임을 입력해 주세요.',
                          icon: Icons.badge_outlined,
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            '수정 완료',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
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
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surfaceMuted,
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String value;
  final IconData icon;

  const _ReadOnlyField({required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 22),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
