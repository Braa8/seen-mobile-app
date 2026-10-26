import 'package:flutter/material.dart';
import '../theme/seen_theme.dart';

class SeenBrand extends StatelessWidget {
  const SeenBrand({super.key, this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: compact ? 34 : 42, height: compact ? 34 : 42,
        decoration: BoxDecoration(color: SeenColors.teal, borderRadius: BorderRadius.circular(13)),
        child: Center(child: Text('س', style: TextStyle(color: Colors.white, fontSize: compact ? 22 : 27, fontWeight: FontWeight.w900))),
      ),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text('سين', style: TextStyle(fontSize: compact ? 19 : 23, fontWeight: FontWeight.w900, height: 1)),
        if (!compact) const SizedBox(height: 4),
        if (!compact) const Text('صحافة تُقرأ بعمق', style: TextStyle(fontSize: 10, color: SeenColors.muted)),
      ]),
    ],
  );
}
