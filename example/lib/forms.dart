import 'dart:async';

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'app_icon.dart';

final _passwordRules = [
  CamoRules.required<String>('Password is required'),
  CamoRules.minLength(8, 'Use at least 8 characters'),
];

/// The base note's sign-up form: rules as objects, validated on submit and then on each edit.
class SignUpForm extends StatefulWidget {
  /// Creates the form.
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _form = CamoFormController();
  bool _hidden = true;
  String? _result;

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  void _submit() => setState(() {
    if (_form.validate()) {
      _form.save();
      _result = 'Account created for ${_form.value<String>('email')}';
    } else {
      _result = null;
    }
  });

  @override
  Widget build(BuildContext context) {
    final spacing = Camouflage.spacingOf(context);
    return CamoForm(
      controller: _form,
      validateMode: ValidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.m,
        children: [
          CamoTextFormField(
            fieldKey: 'email',
            label: 'Email',
            placeholder: 'you@example.com',
            supportingText: 'We never share it',
            prefixIcon: const AppIcon.search(),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            rules: [
              CamoRules.required('Email is required'),
              CamoRules.email('Enter a valid email'),
            ],
          ),
          CamoTextFormField(
            fieldKey: 'password',
            label: 'Password',
            secure: _hidden,
            rules: _passwordRules,
            autofillHints: const [AutofillHints.newPassword],
            suffixIcon: CamoFieldAction(
              icon: _hidden
                  ? const AppIcon.starOutline()
                  : const AppIcon.star(),
              semanticLabel: _hidden ? 'Show password' : 'Hide password',
              onPressed: () => setState(() => _hidden = !_hidden),
            ),
          ),
          CamoTextFormField(
            fieldKey: 'confirm',
            label: 'Confirm password',
            secure: true,
            rules: [CamoRules.matches('password', "Passwords don't match")],
          ),
          CamoTextFormField(
            fieldKey: 'phone',
            label: 'Phone',
            prefixText: '+62',
            keyboardType: TextInputType.phone,
            inputFilter: CamoInputFilter.digitsOnly(maxLength: 13),
            displayFormat: CamoDisplayFormat.pattern('####-####-#####'),
          ),
          CamoDateFormField(
            fieldKey: 'birthDate',
            label: 'Birth date',
            lastDate: DateTime.now(),
            rules: [CamoRules.required('Enter your birth date')],
          ),
          CamoTextFormField(
            fieldKey: 'budget',
            label: 'Monthly budget',
            prefixText: 'Rp',
            keyboardType: TextInputType.number,
            inputFilter: CamoInputFilter.digitsOnly(maxLength: 12),
            displayFormat: CamoDisplayFormat.grouping(),
          ),
          const CamoTextFormField(
            fieldKey: 'company',
            label: 'Company',
            initialValue: 'Srctool',
            enabled: false,
          ),
          CamoRadioGroupFormField<String>(
            fieldKey: 'plan',
            label: 'Plan',
            options: const [
              RadioOption('free', 'Free'),
              RadioOption('pro', 'Pro', description: '€ 8 a month'),
            ],
            rules: [CamoRules.required('Pick a plan')],
          ),
          const CamoStepperFormField(
            fieldKey: 'seats',
            semanticLabel: 'Seats',
            initialValue: 1,
            min: 1,
            max: 50,
          ),
          CamoCheckboxFormField(
            fieldKey: 'consent',
            labelSpans: [
              const CamoSpan('I agree to the '),
              CamoSpan('Terms', onTap: () {}),
            ],
            rules: [CamoRules.requiredTrue('Please accept the terms')],
          ),
          CamoButton(text: 'Create account', onPressed: _submit),
          CamoButton(
            text: 'Pretend the server says the email is taken',
            appearance: Appearance.ghost,
            onPressed: () =>
                _form.setErrors({'email': 'This email already has an account'}),
          ),
          if (_result != null)
            CamoText(_result!, color: Camouflage.colorsOf(context).success),
        ],
      ),
    );
  }
}

const _countries = [
  'Argentina', 'Australia', 'Brazil', 'Canada', 'Denmark', 'Egypt', //
  'Finland', 'France', 'Germany', 'India', 'Indonesia', 'Japan', //
  'Kenya', 'Mexico', 'Netherlands', 'Norway', 'Peru', 'Portugal', //
  'Singapore', 'Spain',
];

/// A country search: the app debounces the query (500 ms) and lists the matches below the field.
class CountrySearch extends StatefulWidget {
  /// Creates the search.
  const CountrySearch({super.key});

  @override
  State<CountrySearch> createState() => _CountrySearchState();
}

class _CountrySearchState extends State<CountrySearch> {
  String _query = '';
  String _settled = '';
  String? _searched;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _changed(String query) {
    setState(() => _query = query);
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => setState(() => _settled = query),
    );
  }

  @override
  Widget build(BuildContext context) {
    final muted = Camouflage.colorsOf(context).onSurfaceVariant;
    final matches = _countries
        .where((c) => c.toLowerCase().contains(_settled.toLowerCase()))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Camouflage.spacingOf(context).s,
      children: [
        CamoSearchField(
          query: _query,
          onChanged: _changed,
          onSubmitted: (q) => setState(() => _searched = q),
          placeholder: 'Search countries',
        ),
        CamoText('${matches.length} results', color: muted),
        for (final c in matches.take(6)) CamoText(c),
        if (_searched != null)
          CamoText('Searched for "$_searched"', color: muted),
      ],
    );
  }
}
