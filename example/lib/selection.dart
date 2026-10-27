import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

enum _Period { day, week, month }

/// The M5 selection controls: a settings list, a shipping choice, a period switch, sliders and steppers.
class SelectionControls extends StatefulWidget {
  /// Creates the section.
  const SelectionControls({super.key});

  @override
  State<SelectionControls> createState() => _SelectionControlsState();
}

class _SelectionControlsState extends State<SelectionControls> {
  bool _wifi = true;
  bool _bluetooth = false;
  bool _rememberMe = true;
  bool _terms = false;
  int _termsOpened = 0;
  String? _speed = 'standard';
  _Period _period = _Period.week;
  double _volume = 0.4;
  double _rating = 3;
  int _quantity = 1;
  int _nights = 2;
  CamoDecimal _weight = CamoDecimal.parse('1.5');

  @override
  Widget build(BuildContext context) {
    final spacing = Camouflage.spacingOf(context).s;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing,
      children: [
        CamoSwitch(
          checked: _wifi,
          onChanged: (v) => setState(() => _wifi = v),
          label: 'Wi-Fi',
          description: 'Uses more battery',
        ),
        CamoSwitch(
          checked: _bluetooth,
          onChanged: (v) => setState(() => _bluetooth = v),
          label: 'Bluetooth',
        ),
        CamoSwitch(
          checked: true,
          onChanged: (_) {},
          label: 'Location (managed by your organization)',
          enabled: false,
        ),
        CamoCheckbox(
          checked: _rememberMe,
          onChanged: (v) => setState(() => _rememberMe = v),
          label: 'Remember me',
        ),
        CamoCheckbox(
          checked: _terms,
          onChanged: (v) => setState(() => _terms = v),
          labelSpans: [
            const CamoSpan('I agree to the '),
            CamoSpan('Terms', onTap: () => setState(() => _termsOpened++)),
          ],
          error: _terms ? null : 'Please accept the terms',
        ),
        if (_termsOpened > 0)
          CamoText(
            'Terms opened $_termsOpened×',
            color: Camouflage.colorsOf(context).onSurfaceVariant,
          ),
        CamoRadioGroup<String>(
          value: _speed,
          onChanged: (v) => setState(() => _speed = v),
          label: 'Shipping speed',
          options: const [
            RadioOption(
              'standard',
              'Standard',
              description: '3 to 5 days, free',
            ),
            RadioOption('express', 'Express', description: 'Tomorrow, € 9'),
            RadioOption(
              'pickup',
              'Pick up in store',
              description: 'Not available near you',
              enabled: false,
            ),
          ],
        ),
        CamoSegmentedControl<_Period>(
          options: const [
            Segment(_Period.day, label: 'Day'),
            Segment(_Period.week, label: 'Week'),
            Segment(_Period.month, label: 'Month'),
          ],
          selected: _period,
          onChanged: (v) => setState(() => _period = v),
        ),
        CamoSlider(
          value: _volume,
          onChanged: (v) => setState(() => _volume = v),
          semanticLabel: 'Volume',
          valueLabel: (v) => '${(v * 100).round()}%',
        ),
        CamoSlider(
          value: _rating,
          onChanged: (v) => setState(() => _rating = v),
          min: 1,
          max: 5,
          divisions: 4,
          semanticLabel: 'Rating',
          valueLabel: (v) => '${v.round()} stars',
        ),
        Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            CamoStepper(
              value: _quantity,
              onChanged: (v) => setState(() => _quantity = v),
              min: 1,
              max: 10,
              semanticLabel: 'Quantity',
            ),
            CamoStepper(
              value: _nights,
              onChanged: (v) => setState(() => _nights = v),
              min: 1,
              max: 14,
              semanticLabel: 'Nights',
              allowTyping: false,
              valueText: (v) => v == 1 ? '1 night' : '$v nights',
            ),
            CamoStepper.decimal(
              value: _weight,
              onChanged: (v) => setState(() => _weight = v),
              min: CamoDecimal.parse('0.5'),
              max: CamoDecimal.parse('5'),
              step: CamoDecimal.parse('0.25'),
              decimals: 2,
              semanticLabel: 'Weight in kg',
            ),
          ],
        ),
      ],
    );
  }
}
