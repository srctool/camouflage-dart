import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_skins.dart';

// The batch-2 inputs' tests from their Flutter notes: the text field, the search field and the form.

Widget _app(Widget child, {CamoSkin skin = skinA}) => MediaQuery(
  data: const MediaQueryData(),
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: Shortcuts(
      shortcuts: WidgetsApp.defaultShortcuts,
      child: Actions(
        actions: WidgetsApp.defaultActions,
        child: FocusScope(
          autofocus: true,
          child: Overlay(
            key: UniqueKey(),
            initialEntries: [
              OverlayEntry(
                builder: (_) => CamouflageProvider(
                  skin: skin,
                  theme: themeT,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(width: 400, child: child),
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

class _Holder<T> extends StatefulWidget {
  const _Holder(this.initial, this.builder);

  final T initial;
  final Widget Function(T value, ValueChanged<T> set) builder;

  @override
  State<_Holder<T>> createState() => _HolderState<T>();
}

class _HolderState<T> extends State<_Holder<T>> {
  late T value = widget.initial;

  @override
  Widget build(BuildContext context) =>
      widget.builder(value, (v) => setState(() => value = v));
}

Finder _field(String label) => find.descendant(
  of: find.bySemanticsLabel(label),
  matching: find.byType(EditableText),
);

String _shown(WidgetTester tester, String label) =>
    tester.widget<EditableText>(_field(label)).controller.text;

String? _error(WidgetTester tester, String label) {
  final data = tester
      .getSemantics(find.bySemanticsLabel(label))
      .getSemanticsData();
  return data.validationResult == SemanticsValidationResult.invalid
      ? data.hint
      : null;
}

void main() {
  group('CamoTextField', () {
    testWidgets('typing reports the value; an ignored change keeps it', (
      tester,
    ) async {
      String? typed;
      var calls = 0;
      await tester.pumpWidget(
        _app(
          Column(
            children: [
              _Holder<String>(
                '',
                (v, set) => CamoTextField(
                  value: v,
                  onChanged: (n) {
                    typed = n;
                    set(n);
                  },
                  label: 'Name',
                ),
              ),
              CamoTextField(
                value: 'fixed',
                onChanged: (_) => calls++,
                label: 'Fixed',
              ),
            ],
          ),
        ),
      );
      await tester.enterText(_field('Name'), 'a');
      expect(typed, 'a');
      await tester.enterText(_field('Fixed'), 'x');
      await tester.pump();
      expect(calls, 1);
      expect(_shown(tester, 'Fixed'), 'fixed');
    });

    testWidgets('a filter rejects input before the app', (tester) async {
      String? value;
      var calls = 0;
      await tester.pumpWidget(
        _app(
          _Holder<String>(
            '',
            (v, set) => CamoTextField(
              value: v,
              onChanged: (n) {
                calls++;
                value = n;
                set(n);
              },
              label: 'Phone',
              inputFilter: CamoInputFilter.digitsOnly(),
            ),
          ),
        ),
      );
      await tester.enterText(_field('Phone'), 'a');
      await tester.pump();
      expect(calls, 0);
      await tester.enterText(_field('Phone'), '0812-3456-7890');
      await tester.pump();
      expect(value, '081234567890');
    });

    testWidgets('a format shows dashes, keeps the value raw and the cursor', (
      tester,
    ) async {
      String value = '08123';
      await tester.pumpWidget(
        _app(
          _Holder<String>(
            '08123',
            (v, set) => CamoTextField(
              value: v,
              onChanged: (n) {
                value = n;
                set(n);
              },
              label: 'Phone',
              inputFilter: CamoInputFilter.digitsOnly(),
              displayFormat: CamoDisplayFormat.pattern('####-####-#####'),
            ),
          ),
        ),
      );
      expect(_shown(tester, 'Phone'), '0812-3');
      await tester.showKeyboard(_field('Phone'));
      // Type 9 after the "8" (shown position 3).
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '0819-23',
          selection: TextSelection.collapsed(offset: 4),
        ),
      );
      await tester.pump();
      expect(value, '081923');
      final controller = tester
          .widget<EditableText>(_field('Phone'))
          .controller;
      expect(controller.text, '0819-23');
      expect(controller.selection.baseOffset, 4);
    });

    testWidgets('an error marks it invalid and replaces the supporting text', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          CamoTextField(
            value: '',
            onChanged: (_) {},
            label: 'Email',
            error: 'Enter an email',
            supportingText: 'Work email',
          ),
        ),
      );
      expect(_error(tester, 'Email'), 'Enter an email');
      expect(find.text('Work email'), findsNothing);
      handle.dispose();
    });

    testWidgets('switching the skin while typing keeps focus and text', (
      tester,
    ) async {
      var skin = skinA;
      late StateSetter setSkin;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) {
              setSkin = setState;
              return CamouflageProvider(
                skin: skin,
                child: _Holder<String>(
                  '',
                  (v, set) =>
                      CamoTextField(value: v, onChanged: set, label: 'Note'),
                ),
              );
            },
          ),
        ),
      );
      await tester.enterText(_field('Note'), 'hello');
      final node = tester.widget<EditableText>(_field('Note')).focusNode;
      expect(node.hasFocus, isTrue);
      setSkin(() => skin = skinB);
      await tester.pump();
      expect(_shown(tester, 'Note'), 'hello');
      expect(node.hasFocus, isTrue);
    });

    testWidgets('a field action keeps the field height and is a button', (
      tester,
    ) async {
      var shown = 0;
      await tester.pumpWidget(
        _app(
          Column(
            children: [
              CamoTextField(
                key: const Key('plain'),
                value: '',
                onChanged: (_) {},
                label: 'Plain',
              ),
              CamoTextField(
                key: const Key('action'),
                value: '',
                onChanged: (_) {},
                label: 'Action',
                suffixIcon: CamoFieldAction(
                  icon: const SizedBox.square(dimension: 8),
                  semanticLabel: 'Show password',
                  onPressed: () => shown++,
                ),
              ),
            ],
          ),
        ),
      );
      expect(
        tester.getSize(find.byKey(const Key('plain'))).height,
        tester.getSize(find.byKey(const Key('action'))).height,
      );
      await tester.tap(find.bySemanticsLabel('Show password'));
      expect(shown, 1);
    });
  });

  group('CamoSearchField', () {
    testWidgets('submitting calls onSubmitted', (tester) async {
      final searched = <String>[];
      await tester.pumpWidget(
        _app(
          _Holder<String>(
            '',
            (v, set) => CamoSearchField(
              query: v,
              onChanged: set,
              onSubmitted: searched.add,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(EditableText), 'tea');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      expect(searched, ['tea']);
    });

    testWidgets('a tap focuses the input', (tester) async {
      await tester.pumpWidget(
        _app(
          CamoSearchField(query: '', onChanged: (_) {}, onSubmitted: (_) {}),
        ),
      );
      await tester.tap(find.byType(CamoSearchField));
      await tester.pump();
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode
            .hasFocus,
        isTrue,
      );
    });

    testWidgets('disabled fields take no focus from a tap', (tester) async {
      await tester.pumpWidget(
        _app(
          Column(
            children: [
              CamoTextField(
                value: 'Srctool',
                onChanged: (_) {},
                label: 'Company',
                enabled: false,
              ),
              CamoSearchField(
                query: '',
                onChanged: (_) {},
                onSubmitted: (_) {},
                enabled: false,
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.byType(CamoTextField));
      await tester.tap(find.byType(CamoSearchField));
      await tester.pump();
      for (final e in tester.widgetList<EditableText>(
        find.byType(EditableText),
      )) {
        expect(e.focusNode.hasFocus, isFalse);
      }
    });

    testWidgets('clear shows with text, clears and keeps focus', (
      tester,
    ) async {
      var query = '';
      await tester.pumpWidget(
        _app(
          _Holder<String>(
            '',
            (v, set) => CamoSearchField(
              query: v,
              onChanged: (n) {
                query = n;
                set(n);
              },
              onSubmitted: (_) {},
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Clear search'), findsNothing);
      await tester.enterText(find.byType(EditableText), 'tea');
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Clear search'));
      await tester.pump();
      expect(query, '');
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode
            .hasFocus,
        isTrue,
      );
    });
  });

  group('CamoForm', () {
    Widget signUp(
      CamoFormController form,
      ValidateMode mode, [
      Map<String, Object?>? saved,
    ]) => CamoForm(
      controller: form,
      validateMode: mode,
      child: Column(
        children: [
          CamoTextFormField(
            fieldKey: 'email',
            label: 'Email',
            rules: [
              CamoRules.required('Email is required'),
              CamoRules.email('Enter an email'),
            ],
            onSaved: (v) => saved?['email'] = v,
          ),
          CamoTextFormField(
            fieldKey: 'password',
            label: 'Password',
            secure: true,
            rules: [CamoRules.minLength(8, 'Use at least 8 characters')],
          ),
          CamoTextFormField(
            fieldKey: 'confirm',
            label: 'Confirm',
            rules: [CamoRules.matches('password', "Passwords don't match")],
          ),
          CamoCheckboxFormField(
            fieldKey: 'consent',
            label: 'I agree',
            rules: [CamoRules.requiredTrue('Please accept')],
          ),
        ],
      ),
    );

    testWidgets('disabled mode validates on submit and focuses the first', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final form = CamoFormController();
      addTearDown(form.dispose);
      await tester.pumpWidget(_app(signUp(form, ValidateMode.disabled)));
      await tester.enterText(_field('Email'), 'not');
      await tester.pump();
      expect(_error(tester, 'Email'), isNull);
      expect(form.validate(), isFalse);
      await tester.pump();
      expect(_error(tester, 'Email'), 'Enter an email');
      expect(find.text('Please accept'), findsOneWidget);
      expect(
        tester.widget<EditableText>(_field('Email')).focusNode.hasFocus,
        isTrue,
      );
      handle.dispose();
    });

    testWidgets('onUserInteraction validates each edited field', (
      tester,
    ) async {
      final form = CamoFormController();
      addTearDown(form.dispose);
      await tester.pumpWidget(
        _app(signUp(form, ValidateMode.onUserInteraction)),
      );
      await tester.enterText(_field('Password'), 'short');
      await tester.pump();
      expect(find.text('Use at least 8 characters'), findsOneWidget);
      expect(find.text('Email is required'), findsNothing);
    });

    testWidgets('always validates before any edit', (tester) async {
      final form = CamoFormController();
      addTearDown(form.dispose);
      await tester.pumpWidget(_app(signUp(form, ValidateMode.always)));
      await tester.pump();
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('onUnfocus validates when focus leaves', (tester) async {
      final form = CamoFormController();
      addTearDown(form.dispose);
      await tester.pumpWidget(_app(signUp(form, ValidateMode.onUnfocus)));
      await tester.enterText(_field('Email'), 'not');
      await tester.pump();
      expect(find.text('Enter an email'), findsNothing);
      await tester.showKeyboard(_field('Password'));
      await tester.pump();
      expect(find.text('Enter an email'), findsOneWidget);
    });

    testWidgets('matches, save, server errors, dirty and reset', (
      tester,
    ) async {
      final form = CamoFormController();
      addTearDown(form.dispose);
      final saved = <String, Object?>{};
      await tester.pumpWidget(_app(signUp(form, ValidateMode.disabled, saved)));
      await tester.enterText(_field('Email'), 'a@b.co');
      await tester.enterText(_field('Password'), 'longenough');
      await tester.enterText(_field('Confirm'), 'different');
      await tester.tap(find.text('I agree'));
      await tester.pump();
      expect(form.isDirty, isTrue);
      expect(form.validate(), isFalse);
      await tester.pump();
      expect(find.text("Passwords don't match"), findsOneWidget);
      await tester.enterText(_field('Confirm'), 'longenough');
      expect(form.validate(), isTrue);
      form
        ..save()
        ..setErrors({'email': 'Already taken'});
      await tester.pump();
      expect(saved['email'], 'a@b.co');
      expect(find.text('Already taken'), findsOneWidget);
      await tester.enterText(_field('Email'), 'a@b.com');
      await tester.pump();
      expect(find.text('Already taken'), findsNothing);
      form.reset();
      await tester.pump();
      expect(form.isDirty, isFalse);
    });

    testWidgets('a hidden field keeps its value and is skipped', (
      tester,
    ) async {
      final form = CamoFormController();
      addTearDown(form.dispose);
      var shown = true;
      late StateSetter setShown;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) {
              setShown = setState;
              return CamoForm(
                controller: form,
                child: CamoTextFormField(
                  fieldKey: 'company',
                  label: 'Company',
                  visible: shown,
                  rules: [CamoRules.minLength(5, 'Too short')],
                ),
              );
            },
          ),
        ),
      );
      await tester.enterText(_field('Company'), 'abc');
      setShown(() => shown = false);
      await tester.pump();
      expect(form.validate(), isTrue);
      setShown(() => shown = true);
      await tester.pump();
      expect(form.value<String>('company'), 'abc');
    });

    testWidgets('a lazy form validates off-screen rows and reveals the first', (
      tester,
    ) async {
      final form = CamoFormController();
      final scroll = ScrollController();
      addTearDown(form.dispose);
      addTearDown(scroll.dispose);
      final keys = [for (var i = 0; i < 50; i++) 'row$i'];
      form.declare<String>(
        'row40',
        initialValue: '',
        rules: [CamoRules.required('Row 40 is required')],
      );
      await tester.pumpWidget(
        _app(
          SizedBox(
            height: 300,
            child: CamoForm.list(
              controller: form,
              scrollController: scroll,
              indexOfKey: keys.indexOf,
              itemExtent: 80,
              child: ListView.builder(
                controller: scroll,
                itemExtent: 80,
                itemCount: keys.length,
                itemBuilder: (context, i) => CamoTextFormField(
                  fieldKey: keys[i],
                  label: 'Row $i',
                  initialValue: i == 40 ? '' : 'ok',
                  rules: [CamoRules.required('Row $i is required')],
                ),
              ),
            ),
          ),
        ),
      );
      expect(form.validate(), isFalse);
      await tester.pumpAndSettle();
      expect(find.text('Row 40 is required'), findsOneWidget);
      expect(
        tester.widget<EditableText>(_field('Row 40')).focusNode.hasFocus,
        isTrue,
      );
    });

    test('toMap and restore keep values, errors and interaction', () {
      final form = CamoFormController()
        ..declare<String>(
          'email',
          initialValue: '',
          rules: [CamoRules.email('Enter an email')],
        );
      final again = CamoFormController()
        ..restore({
          'email': {'value': 'not', 'error': 'Enter an email', 'touched': true},
        });
      again.declare<String>('email', initialValue: '');
      expect(again.value<String>('email'), 'not');
      expect(form.toMap().containsKey('email'), isTrue);
      form.dispose();
      again.dispose();
    });

    test('rules check and pass empty text where they say', () {
      expect(CamoRules.required<String>('x').validate(' '), 'x');
      expect(CamoRules.requiredTrue('x').validate(false), 'x');
      expect(CamoRules.minLength(3, 'x').validate(''), isNull);
      expect(CamoRules.minLength(3, 'x').validate('ab'), 'x');
      expect(CamoRules.min(18, 'x').validate('17'), 'x');
      expect(CamoRules.max(5, 'x').validate('5,5'), 'x');
      expect(CamoRules.email('x').validate('a@b.co'), isNull);
      expect(CamoRules.email('x').validate('a@b'), 'x');
    });

    test('formats insert their literals and map the cursor', () {
      final phone = CamoDisplayFormat.pattern('####-####-#####');
      expect(phone.format('08123'), '0812-3');
      expect(phone.toRaw('0812-3'), '08123');
      expect(phone.rawToShown(5, '08123'), 6);
      expect(phone.shownToRaw(6, '0812-3'), 5);
      expect(CamoDisplayFormat.grouping().format('1250000'), '1.250.000');
      expect(CamoDisplayFormat.decimal().format('1250000,50'), '1.250.000,50');
      expect(CamoInputFilter.decimal().filter('12,50', '12,507'), '12,50');
    });
  });
}
