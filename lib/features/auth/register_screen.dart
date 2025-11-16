import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/controllers/app_scope.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/quick_settings_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;

  String get strength {
    final text = _password.text;
    if (text.length > 10) return 'strong';
    if (text.length > 6) return 'medium';
    return 'weak';
  }

  Color strengthColor(BuildContext context) {
    switch (strength) {
      case 'strong':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final controllers = AppScope.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(localization.t('register')),
        actions: const [QuickSettingsButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: InputDecoration(labelText: localization.t('name'), prefixIcon: const Icon(IconlyLight.user_1)),
                validator: (value) =>
                    value == null || value.isEmpty ? localization.t('requiredField') : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                decoration: InputDecoration(labelText: localization.t('email'), prefixIcon: const Icon(IconlyLight.message)),
                validator: (value) =>
                    value == null || !value.contains('@') ? localization.t('invalidEmail') : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                obscureText: _obscure,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: localization.t('password'),
                  prefixIcon: const Icon(IconlyLight.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? IconlyLight.show : IconlyLight.hide),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (value) =>
                    value != null && value.length >= 6 ? null : localization.t('tooShort'),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${localization.t('passwordStrength')}: ${localization.t(strength)}'),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 6,
                      width: strength == 'strong'
                          ? 160
                          : strength == 'medium'
                              ? 120
                              : 80,
                      decoration: BoxDecoration(
                        color: strengthColor(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirm,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: localization.t('confirmPassword'),
                  prefixIcon: const Icon(IconlyLight.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? IconlyLight.show : IconlyLight.hide),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (value) => value == _password.text ? null : localization.t('passwordMismatch'),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: localization.t('register'),
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    await controllers.authController.login(_email.text);
                    if (!mounted) return;
                    Navigator.of(context).pushReplacementNamed('/home');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
