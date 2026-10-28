import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_fluent/camouflage_skin_fluent.dart';
import 'package:camouflage_skin_testing/camouflage_skin_testing.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The M6 structure renderers against the contract: behavior on the whole row, headers drawn, theme fields honored.
void main() {
  const skin = fluentSkinDefault;
  final theme = fluentTheme();

  testWidgets('a row takes taps across its whole box', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      camoTestApp(
        skin: skin,
        theme: theme,
        child: SizedBox(
          width: 300,
          child: CamoListItem(
            key: const Key('row'),
            headline: 'Wi-Fi',
            onPressed: () => taps++,
          ),
        ),
      ),
    );
    final row = tester.getRect(find.byKey(const Key('row')));
    await tester.tapAt(row.topLeft + const Offset(1, 1));
    await tester.tapAt(row.bottomRight - const Offset(1, 1));
    await tester.pump();
    expect(taps, 2);
  });

  testWidgets('the section and bar titles are headers', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      camoTestApp(
        skin: skin,
        theme: theme,
        child: const SizedBox(
          width: 360,
          child: Column(
            children: [
              CamoTopBar(title: 'Settings'),
              CamoListSection(
                title: 'Network',
                children: [CamoListItem(headline: 'Wi-Fi')],
              ),
            ],
          ),
        ),
      ),
    );
    expect(
      tester.getSemantics(find.text('Settings')).flagsCollection.isHeader,
      isTrue,
    );
    expect(
      tester.getSemantics(find.text('Network')).flagsCollection.isHeader,
      isTrue,
    );
    semantics.dispose();
  });

  testWidgets('a row honors its min height', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoListItemTheme(minHeightOneLine: 61),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(listItem: o),
        child: const CamoListItem(headline: 'Row'),
      ),
      measure: (size) => size.height == 61,
    );
  });

  testWidgets('the bar honors its height', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoTopBarTheme(height: 77),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(topBar: o),
        child: const SizedBox(width: 300, child: CamoTopBar(title: 'Title')),
      ),
      measure: (size) => size.height == 77,
    );
  });

  testWidgets('a closed accordion is its header height', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoAccordionTheme(headerMinHeight: 67),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(accordion: o),
        child: SizedBox(
          width: 300,
          child: CamoAccordion(
            title: 'Shipping',
            expanded: false,
            onExpansionChanged: (_) {},
            child: const CamoText('Hidden'),
          ),
        ),
      ),
      measure: (size) => size.height == 67,
    );
  });

  testWidgets('a card honors its padding', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoCardTheme(
        contentPadding: EdgeInsetsDirectional.all(13),
      ),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(card: o),
        child: const CamoCard(child: SizedBox.square(dimension: 10)),
      ),
      measure: (size) => size.width == 36,
    );
  });

  testWidgets('the close button shows only when dismissible and asked', (
    tester,
  ) async {
    var dismissed = 0;
    Widget dialog(bool dismissible) => camoTestApp(
      skin: skin,
      theme: theme,
      child: ProvideComponentThemes(
        components: const CamoComponentThemes(
          dialog: CamoDialogTheme(showCloseButton: true),
        ),
        child: CamoDialogFrame(
          dismissible: dismissible,
          onDismissRequest: () => dismissed++,
          child: CamoDialog(
            title: 'Done',
            message: 'Saved.',
            confirm: CamoButton(text: 'OK', onPressed: () {}),
          ),
        ),
      ),
    );
    await tester.pumpWidget(dialog(true));
    await tester.tap(find.bySemanticsLabel('Close'));
    expect(dismissed, 1);
    await tester.pumpWidget(dialog(false));
    expect(find.bySemanticsLabel('Close'), findsNothing);
  });
}
