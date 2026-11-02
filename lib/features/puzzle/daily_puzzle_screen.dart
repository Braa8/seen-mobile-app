
import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/seen_theme.dart';

enum PuzzleDifficulty { easy, medium, hard }

class DailyPuzzle {
  const DailyPuzzle({
    required this.date,
    required this.size,
    required this.difficulty,
    required this.numbers,
    required this.solution,
  });

  final String date;
  final int size;
  final PuzzleDifficulty difficulty;
  final Map<int, int> numbers;
  final List<int> solution;

  int get total => size * size;

  String get difficultyLabel {
    switch (difficulty) {
      case PuzzleDifficulty.easy:
        return 'سهل';
      case PuzzleDifficulty.medium:
        return 'متوسط';
      case PuzzleDifficulty.hard:
        return 'صعب';
    }
  }
}

const int _mask32 = 0xffffffff;
const int _dayMs = 86400000;

int _hashString(String value) {
  var hash = 2166136261;

  for (final unit in value.codeUnits) {
    hash ^= unit;
    hash = (hash * 16777619) & _mask32;
  }

  return hash;
}

class _RandomGenerator {
  _RandomGenerator(int seed) : _state = seed == 0 ? 1 : seed;

  int _state;

  double next() {
    _state ^= (_state << 13) & _mask32;
    _state &= _mask32;

    _state ^= _state >> 17;
    _state &= _mask32;

    _state ^= (_state << 5) & _mask32;
    _state &= _mask32;

    return _state / 4294967296.0;
  }
}

List<int> _makeSnake(int size) {
  final cells = <int>[];

  for (var row = 0; row < size; row++) {
    if (row.isEven) {
      for (var col = 0; col < size; col++) {
        cells.add(row * size + col);
      }
    } else {
      for (var col = size - 1; col >= 0; col--) {
        cells.add(row * size + col);
      }
    }
  }

  return cells;
}

DailyPuzzle _makePuzzle(String date) {
  final day = DateTime.parse('${date}T00:00:00Z')
          .millisecondsSinceEpoch ~/
      _dayMs;

  final difficultyIndex = _hashString('difficulty:$day') % 3;

  final difficulty = PuzzleDifficulty.values[difficultyIndex];

  final size = switch (difficulty) {
    PuzzleDifficulty.easy => 5,
    PuzzleDifficulty.medium => 6,
    PuzzleDifficulty.hard => 7,
  };

  final clues = switch (difficulty) {
    PuzzleDifficulty.easy => 8,
    PuzzleDifficulty.medium => 9,
    PuzzleDifficulty.hard => 10,
  };

  final random = _RandomGenerator(_hashString('puzzle:$date'));

  var solution = _makeSnake(size);

  final rotation = (random.next() * 4).floor();
  final flip = random.next() < 0.5;

  solution = solution.map((cell) {
    var row = cell ~/ size;
    var col = cell % size;

    if (flip) {
      col = size - 1 - col;
    }

    for (var i = 0; i < rotation; i++) {
      final oldRow = row;
      row = col;
      col = size - 1 - oldRow;
    }

    return row * size + col;
  }).toList();

  if (random.next() < 0.5) {
    solution = solution.reversed.toList();
  }

  final positions = <int>{0, solution.length - 1};

  final spacing = (solution.length - 1) / (clues - 1);

  for (var i = 1; i < clues - 1; i++) {
    final target =
        (i * spacing + (random.next() - 0.5) * spacing * 0.55).round();

    positions.add(target.clamp(1, solution.length - 2));
  }

  for (var i = 1;
      positions.length < clues && i < solution.length - 1;
      i++) {
    positions.add(i);
  }

  final sortedPositions = positions.toList()..sort();

  final numbers = <int, int>{};

  for (var i = 0; i < sortedPositions.length; i++) {
    numbers[solution[sortedPositions[i]]] = i + 1;
  }

  return DailyPuzzle(
    date: date,
    size: size,
    difficulty: difficulty,
    numbers: numbers,
    solution: solution,
  );
}

String _utcDate() {
  final now = DateTime.now().toUtc();

  return '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
}

List<int> _neighbors(int cell, int size) {
  final row = cell ~/ size;
  final col = cell % size;

  return [
    if (row > 0) cell - size,
    if (col < size - 1) cell + 1,
    if (row < size - 1) cell + size,
    if (col > 0) cell - 1,
  ];
}

class DailyPuzzleScreen extends StatefulWidget {
  const DailyPuzzleScreen({super.key});

  @override
  State<DailyPuzzleScreen> createState() => _DailyPuzzleScreenState();
}

class _DailyPuzzleScreenState extends State<DailyPuzzleScreen> {
  late DailyPuzzle _puzzle;

  List<int> _path = [];

  int _seconds = 0;
  int _hints = 0;

  String _notice = '';

  Timer? _timer;

  bool get _completed =>
      _path.length == _puzzle.total &&
      _isValidPath(_path);

  int get _visitedNumbers =>
      _path.where((cell) => _puzzle.numbers.containsKey(cell)).length;

  int get _progress =>
      (_path.length * 100 / _puzzle.total).round();

  int get _maxNumber => _puzzle.numbers.length;

  @override
  void initState() {
    super.initState();

    _puzzle = _makePuzzle(_utcDate());
    _path = [_puzzle.solution.first];

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted && !_completed && _path.length > 1) {
          setState(() => _seconds++);
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool _isValidPath(List<int> path) {
    if (path.isEmpty ||
        path.length > _puzzle.total ||
        path.first != _puzzle.solution.first) {
      return false;
    }

    final seen = <int>{};
    var expected = 1;

    for (var i = 0; i < path.length; i++) {
      final cell = path[i];

      if (cell < 0 ||
          cell >= _puzzle.total ||
          !seen.add(cell)) {
        return false;
      }

      if (i > 0 &&
          !_neighbors(path[i - 1], _puzzle.size).contains(cell)) {
        return false;
      }

      final clue = _puzzle.numbers[cell];

      if (clue != null) {
        if (clue != expected) return false;
        expected++;
      }
    }

    return true;
  }

  void _moveTo(int cell) {
    if (_completed) return;

    final next = List<int>.from(_path);

    if (next.isEmpty) {
      next.add(_puzzle.solution.first);
    }

    final last = next.last;

    if (cell == last) return;

    final previousIndex = next.indexOf(cell);

    if (previousIndex >= 0) {
      if (previousIndex == next.length - 2) {
        next.removeLast();

        setState(() {
          _path = next;
          _notice = '';
        });
      }

      return;
    }

    if (!_neighbors(last, _puzzle.size).contains(cell)) return;

    final clue = _puzzle.numbers[cell];

    final expected = next
            .where((value) => _puzzle.numbers.containsKey(value))
            .length +
        1;

    if (clue != null && clue != expected) return;

    setState(() {
      _path = [...next, cell];
      _notice = '';
    });

    if (_completed) {
      _showVictory();
    }
  }

  void _undo() {
    if (_path.length <= 1 || _completed) return;

    setState(() {
      _path.removeLast();
      _notice = '';
    });
  }

  void _reset() {
    setState(() {
      _path = [_puzzle.solution.first];
      _seconds = 0;
      _hints = 0;
      _notice = '';
    });
  }

  void _hint() {
    if (_completed) return;

    final index = _path.length;

    final followingCorrectly = List.generate(
      _path.length,
      (i) => _path[i] == _puzzle.solution[i],
    ).every((value) => value);

    if (followingCorrectly && index < _puzzle.solution.length) {
      _moveTo(_puzzle.solution[index]);

      setState(() {
        _hints++;
        _notice = 'أضفنا الخانة التالية إلى المسار.';
      });
    } else {
      setState(() {
        _notice =
            'تراجع حتى تعود إلى المسار الصحيح، أو أعد المحاولة.';
      });
    }
  }

  void _showVictory() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_completed) return;

      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          icon: const Icon(
            Icons.emoji_events_rounded,
            color: Colors.amber,
            size: 54,
          ),
          title: const Text(
            'مبروك! 🎉',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'أكملت مسار اليوم وملأت جميع الخانات بنجاح!',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Text('الوقت: ${_timeLabel(_seconds)}'),
              Text('التلميحات: $_hints'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('رائع!'),
            ),
          ],
        ),
      );
    });
  }

  String _timeLabel(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remaining = (seconds % 60).toString().padLeft(2, '0');

    return '$minutes:$remaining';
  }

  String _formattedDate() {
    final date = DateTime.parse('${_puzzle.date}T00:00:00Z');

    return '${date.year}/${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final size = _puzzle.size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('لغز اليوم'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: SeenColors.tealDark,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'تحديات سين اليومية ✦',
                      style: TextStyle(
                        color: SeenColors.gold,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'مسار اليوم',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'ارسم طريقك من الرقم 1 إلى النهاية، '
                      'واملأ كل خانة لتفوز بالتحدي!',
                      style: TextStyle(
                        color: Colors.white,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _infoChip(_formattedDate()),
                        _infoChip(
                          '${_puzzle.difficultyLabel} · $size×$size',
                        ),
                        _infoChip(_timeLabel(_seconds)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'اصنع المسار',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '$_progress%',
                    style: const TextStyle(
                      color: SeenColors.teal,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'اختر الخانات المتجاورة بالترتيب',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF2F1),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: size,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                        ),
                        itemCount: _puzzle.total,
                        itemBuilder: (context, cell) {
                          final clue = _puzzle.numbers[cell];
                          final active = _path.contains(cell);
                          final endpoint =
                              active && cell == _path.last;

                          final pathIndex = _path.indexOf(cell);

                          final previous = pathIndex > 0
                              ? _path[pathIndex - 1]
                              : -1;

                          final next = pathIndex >= 0 &&
                                  pathIndex < _path.length - 1
                              ? _path[pathIndex + 1]
                              : -1;

                          final row = cell ~/ size;
                          final col = cell % size;

                          final connected = <int>[
                            previous,
                            next,
                          ];

                          final top = connected.contains(cell - size) &&
                              row > 0;

                          final bottom =
                              connected.contains(cell + size) &&
                                  row < size - 1;

                          final left =
                              connected.contains(cell - 1) && col > 0;

                          final right =
                              connected.contains(cell + 1) &&
                                  col < size - 1;

                          return GestureDetector(
                            onTap: () => _moveTo(cell),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 140),
                              decoration: BoxDecoration(
                                color: active
                                    ? const Color(0xFFBDECE2)
                                    : SeenColors.card,
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(
                                  color: active
                                      ? SeenColors.teal
                                      : SeenColors.line,
                                  width: active ? 1.5 : 1,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  if (active)
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: _PathPainter(
                                          top: top,
                                          bottom: bottom,
                                          left: left,
                                          right: right,
                                          endpoint: endpoint,
                                        ),
                                      ),
                                    ),
                                  Center(
                                    child: clue != null
                                        ? Container(
                                            width: size == 7 ? 25 : 31,
                                            height: size == 7 ? 25 : 31,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: active
                                                  ? SeenColors.teal
                                                  : const Color(0xFF263B48),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              '$clue',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          )
                                        : endpoint
                                            ? const Icon(
                                                Icons.circle,
                                                color: Colors.amber,
                                                size: 13,
                                              )
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$_visitedNumbers من $_maxNumber أرقام',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${_path.length} / ${_puzzle.total} خانة',
                    style: const TextStyle(
                      color: SeenColors.teal,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: _path.length / _puzzle.total,
                  minHeight: 8,
                  backgroundColor: Colors.black12,
                  color: SeenColors.teal,
                ),
              ),
              if (_notice.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _notice,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _path.length > 1 && !_completed
                          ? _undo
                          : null,
                      icon: const Icon(Icons.undo),
                      label: const Text('تراجع'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _completed ? null : _hint,
                      icon: const Icon(Icons.lightbulb_outline),
                      label: const Text('تلميح'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  const _PathPainter({
    required this.top,
    required this.bottom,
    required this.left,
    required this.right,
    required this.endpoint,
  });

  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  final bool endpoint;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SeenColors.teal
      ..strokeWidth = size.width * 0.22
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);

    if (top) {
      canvas.drawLine(
        center,
        Offset(center.dx, 0),
        paint,
      );
    }

    if (bottom) {
      canvas.drawLine(
        center,
        Offset(center.dx, size.height),
        paint,
      );
    }

    if (left) {
      canvas.drawLine(
        center,
        Offset(0, center.dy),
        paint,
      );
    }

    if (right) {
      canvas.drawLine(
        center,
        Offset(size.width, center.dy),
        paint,
      );
    }

    canvas.drawCircle(
      center,
      size.width * 0.10,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) {
    return top != oldDelegate.top ||
        bottom != oldDelegate.bottom ||
        left != oldDelegate.left ||
        right != oldDelegate.right ||
        endpoint != oldDelegate.endpoint;
  }
}
