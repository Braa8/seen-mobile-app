import 'package:flutter/material.dart';
import '../theme/seen_theme.dart';

class SeenBrand extends StatelessWidget {
  const SeenBrand({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final logoSize = compact ? 36.0 : 44.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: SeenColors.teal,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(
              Icons.image_not_supported_outlined,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'سين',
              style: TextStyle(
                fontSize: compact ? 19 : 23,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            if (!compact) ...[
              const SizedBox(height: 4),
              const Text(
                'صحافة تُقرأ بعمق',
                style: TextStyle(
                  fontSize: 10,
                  color: SeenColors.muted,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}