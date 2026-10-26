import 'package:flutter/material.dart';

import '../../core/theme/seen_theme.dart';

class DailyPuzzleScreen extends StatefulWidget {
  const DailyPuzzleScreen({super.key});

  @override
  State<DailyPuzzleScreen> createState() => _DailyPuzzleScreenState();
}

class _DailyPuzzleScreenState extends State<DailyPuzzleScreen> {
  static const int size = 5;

  final List<int> _path = [0];

  bool _won = false;

  void _reset() {
    setState(() {
      _path
        ..clear()
        ..add(0);

      _won = false;
    });
  }

  void _tap(int cell) {
    if (_won) return;

    if (_path.contains(cell)) {
      if (_path.length > 1 && _path[_path.length - 2] == cell) {
        setState(() {
          _path.removeLast();
        });
      }

      return;
    }

    final last = _path.last;

    final adjacent =
        (last ~/ size == cell ~/ size &&
            (last % size - cell % size).abs() == 1) ||
        (last % size == cell % size &&
            (last ~/ size - cell ~/ size).abs() == 1);

    if (!adjacent) return;

    setState(() {
      _path.add(cell);

      if (_path.length == size * size) {
        _won = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لغز اليوم'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: SeenColors.tealDark,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مسار الأرقام',
                    style: TextStyle(
                      color: SeenColors.gold,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ارسم طريقاً يمرّ بكل الخانات مرة واحدة.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'ابدأ من 1، وتحرك أفقياً أو عمودياً فقط.',
                    style: TextStyle(
                      color: Color(0xFFD4E1DC),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _won
                        ? 'أحسنت! أكملت المسار.'
                        : 'الخانات: ${_path.length} من ${size * size}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: _reset,
                  child: const Text('إعادة'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: size,
                      crossAxisSpacing: 7,
                      mainAxisSpacing: 7,
                    ),
                    itemCount: size * size,
                    itemBuilder: (context, cell) {
                      final visited = _path.contains(cell);
                      final number = _path.indexOf(cell) + 1;

                      return InkWell(
                        onTap: () => _tap(cell),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 140),
                          decoration: BoxDecoration(
                            color: visited
                                ? SeenColors.teal
                                : SeenColors.card,
                            border: Border.all(
                              color: visited
                                  ? SeenColors.teal
                                  : SeenColors.line,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              visited ? '$number' : '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            if (_won)
              FilledButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.replay),
                label: const Text('العب مجدداً'),
              ),
          ],
        ),
      ),
    );
  }
}