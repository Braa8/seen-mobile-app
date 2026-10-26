import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/services/session_service.dart';
import '../../core/theme/seen_theme.dart';
import '../../core/widgets/seen_brand.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _busy = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;

    if (!SessionService.instance.firebaseAvailable) {
      _message('لم يتم إعداد Firebase في نسخة Android بعد.');
      return;
    }

    setState(() => _busy = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } on FirebaseAuthException catch (e) {
      _message(
        switch (e.code) {
          'invalid-credential' ||
          'wrong-password' ||
          'user-not-found' =>
            'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
          'too-many-requests' =>
            'محاولات كثيرة. انتظر قليلاً ثم حاول مجدداً.',
          'network-request-failed' => 'تحقق من اتصال الإنترنت.',
          _ => 'تعذر تسجيل الدخول. تحقق من البيانات وحاول مجدداً.',
        },
      );
    } catch (_) {
      _message('حدث خطأ غير متوقع أثناء تسجيل الدخول.');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  void _message(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: SeenBrand()),
                const SizedBox(height: 35),
                Text(
                  'أهلاً بعودتك',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'ادخل إلى حسابك لتبقى مكتبتك ومفضّلتك معك.',
                  style: TextStyle(
                    color: SeenColors.muted,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 26),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'أدخل بريداً إلكترونياً صحيحاً';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() => _obscure = !_obscure);
                      },
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'أدخل كلمة المرور';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: Padding(
                    padding: const EdgeInsets.all(13),
                    child: _busy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('تسجيل الدخول'),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                  child: const Text('ليس لديك حساب؟ أنشئ حساباً'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}