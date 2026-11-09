import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/services/api_client.dart';
import '../../core/services/session_service.dart';
import '../../core/theme/seen_theme.dart';
import '../../core/widgets/seen_brand.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  final _api = ApiClient();

  bool _busy = false;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;

    if (!SessionService.instance.firebaseAvailable) {
      _message('لم يتم إعداد في نسخة Android بعد.');
      return;
    }

    setState(() => _busy = true);

    try {
      await _api.post(
        '/api/auth/register',
        body: {
          'displayName': _name.text.trim(),
          'email': _email.text.trim(),
          'password': _password.text,
        },
      );

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );

      if (!mounted) return;

      _message('تم إنشاء حسابك بنجاح.');
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      _message(e.message);
    } on FirebaseAuthException catch (e) {
      _message(
        e.code == 'email-already-in-use'
            ? 'البريد الإلكتروني مستخدم بالفعل.'
            : 'أُنشئ الحساب، لكن تعذر تسجيل الدخول تلقائياً. جرّب تسجيل الدخول.',
      );
    } catch (_) {
      _message('تعذر إنشاء الحساب. تحقق من الإنترنت وحاول مجدداً.');
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
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: SeenBrand()),
                const SizedBox(height: 30),
                Text(
                  'ابدأ رحلتك مع سين',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'أنشئ حساباً واحداً تستخدمه في التطبيق والموقع.',
                  style: TextStyle(
                    color: SeenColors.muted,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الظاهر',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 2) {
                      return 'أدخل اسماً من حرفين على الأقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
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
                const SizedBox(height: 12),
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
                    if (value == null || value.length < 6) {
                      return 'كلمة المرور يجب أن تكون 6 محارف على الأقل';
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
                        : const Text('إنشاء الحساب'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}