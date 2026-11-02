import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

// The M10 small data components together: a rating that changes, pages, a path and a wizard's steps.

const _path = ['Home', 'Projects', 'Camouflage', 'Design', 'Notes'];
const _wizard = ['Account', 'Shipping', 'Payment', 'Review'];
const _pages = 12;

/// A rating, pages, a breadcrumb path and a wizard's steps working together.
class SmallDataDemo extends StatefulWidget {
  /// Creates the demo.
  const SmallDataDemo({super.key});

  @override
  State<SmallDataDemo> createState() => _SmallDataDemoState();
}

class _SmallDataDemoState extends State<SmallDataDemo> {
  var _rating = 3.5;
  var _page = 0;
  var _depth = _path.length - 1;
  var _step = 1;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Camouflage.spacingOf(context).m,
    children: [
      Wrap(
        spacing: Camouflage.spacingOf(context).m,
        runSpacing: Camouflage.spacingOf(context).s,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const SizedBox.square(
            dimension: 64,
            child: CamoImage(
              source: ImageSource.loaded(ColoredBox(color: Color(0xFF6D8FB5))),
              semanticLabel: 'A blue square',
            ),
          ),
          const SizedBox.square(
            dimension: 64,
            child: CamoImage(
              source: ImageSource.failed(),
              semanticLabel: 'A picture that failed to load',
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CamoRating(
                value: _rating,
                label: 'Quality',
                step: RatingStep.half,
                onChanged: (v) => setState(() => _rating = v),
              ),
              CamoText('Quality: $_rating of 5'),
            ],
          ),
        ],
      ),
      SizedBox(
        height: 48,
        child: CamoBreadcrumb(
          items: [
            for (var i = 0; i <= _depth; i++)
              CamoBreadcrumbItem(
                id: _path[i],
                label: _path[i],
                onPressed: () => setState(() => _depth = i),
              ),
          ],
        ),
      ),
      // The numbered form needs room; on a narrow window the app picks the compact one.
      LayoutBuilder(
        builder: (context, constraints) => CamoPagination(
          pageCount: _pages,
          page: _page,
          variant: constraints.maxWidth < 420
              ? PaginationVariant.compact
              : PaginationVariant.numbered,
          onPageChanged: (p) => setState(() => _page = p),
        ),
      ),
      CamoText('Page ${_page + 1} of $_pages'),
      CamoProgressSteps(
        current: _step,
        steps: [
          for (final (i, name) in _wizard.indexed)
            CamoStep(
              id: name,
              label: name,
              onPressed: i < _step ? () => setState(() => _step = i) : null,
            ),
        ],
      ),
      Wrap(
        spacing: Camouflage.spacingOf(context).s,
        runSpacing: Camouflage.spacingOf(context).s,
        children: [
          CamoButton(
            text: 'Back',
            onPressed: _step > 0 ? () => setState(() => _step--) : null,
          ),
          CamoButton(
            text: 'Next',
            onPressed: _step < _wizard.length - 1
                ? () => setState(() => _step++)
                : null,
          ),
        ],
      ),
    ],
  );
}
