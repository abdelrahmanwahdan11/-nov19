import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/controllers/app_scope.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final controllers = AppScope.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color?.withOpacity(0.95),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    localization.t('welcomeBack'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: localization.t('email'),
                      prefixIcon: const Icon(IconlyLight.message),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? localization.t('requiredField') : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: localization.t('password'),
                      prefixIcon: const Icon(IconlyLight.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? IconlyLight.show : IconlyLight.hide),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (value) =>
                        value == null || value.length < 4 ? localization.t('tooShort') : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pushNamed('/auth/forgot_password'),
                      child: Text(localization.t('forgotPassword')),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: localization.t('login'),
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        await controllers.authController.login(_emailController.text);
                        if (!mounted) return;
                        Navigator.of(context).pushReplacementNamed('/home');
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () async {
                      await controllers.authController.continueAsGuest();
                      if (!mounted) return;
                      Navigator.of(context).pushReplacementNamed('/home');
                    },
                    child: Text(localization.t('continueGuest')),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/auth/register'),
                    child: Text(localization.t('register')),
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
