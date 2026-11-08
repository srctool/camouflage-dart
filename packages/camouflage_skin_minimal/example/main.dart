import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(const MyApp());

/// A Minimal-skinned app on [WidgetsApp]: no Material app needed.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => WidgetsApp(
    color: const Color(0xFF0B57D0),
    pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, _, _) => builder(context),
    ),
    builder: (context, child) {
      final dark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
      return CamouflageProvider(
        skin: minimalSkin,
        theme: dark
            ? minimalTheme(brightness: Brightness.dark)
            : minimalTheme(),
        child: child!,
      );
    },
    home: const SignUp(),
  );
}

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String _email = '';
  bool _terms = false;

  @override
  Widget build(BuildContext context) {
    final spacing = Camouflage.themeOf(context).spacing;
    return CamoSurface(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(spacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: spacing.m,
            children: [
              const CamoText('Create your account'),
              CamoTextField(
                value: _email,
                onChanged: (value) => setState(() => _email = value),
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              CamoCheckbox(
                checked: _terms,
                onChanged: (value) => setState(() => _terms = value),
                label: 'I agree to the terms',
              ),
              CamoButton(
                text: 'Sign up',
                onPressed: _terms && _email.isNotEmpty ? () {} : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
