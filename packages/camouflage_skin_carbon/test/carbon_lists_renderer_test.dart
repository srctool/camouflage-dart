import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_carbon/camouflage_skin_carbon.dart';
import 'package:camouflage_skin_testing/camouflage_skin_testing.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The M10 data table and tree renderers against the contract: theme fields honored.
void main() {
  const skin = carbonSkin;
  final theme = carbonLight;

  testWidgets('a table honors its header and row heights', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoTableTheme(headerHeight: 53, rowHeight: 67),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(dataTable: o),
        child: Builder(
          builder: (context) {
            final t = Camouflage.themeOf(context);
            final style = skin.dataTable
                .defaults(t)
                .merge(t.components.dataTable);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                skin.dataTable.renderHeaderRow(context, t, style, [
                  const SizedBox(width: 100),
                ]),
                skin.dataTable.renderRow(
                  context,
                  RowState(
                    index: 0,
                    selected: false,
                    striped: false,
                    interaction: InteractionState.none,
                    controller: CamoInteractionController(),
                  ),
                  t,
                  style,
                  [const SizedBox(width: 100)],
                ),
              ],
            );
          },
        ),
      ),
      measure: (size) => size.height == 53 + 67,
    );
  });

  testWidgets('a tree row honors its height', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoTreeTheme(rowHeight: 59),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(tree: o),
        child: Builder(
          builder: (context) {
            final t = Camouflage.themeOf(context);
            final style = skin.tree.defaults(t).merge(t.components.tree);
            return skin.tree.renderNode(
              context,
              TreeNodeState(
                level: 0,
                expanded: false,
                hasChildren: false,
                loading: false,
                selected: false,
                interaction: InteractionState.none,
                controller: CamoInteractionController(),
              ),
              TreeNodeSlots(label: 'A', wrapToggle: (c) => c),
              t,
              style,
            );
          },
        ),
      ),
      measure: (size) => size.height == 59,
    );
  });
}
