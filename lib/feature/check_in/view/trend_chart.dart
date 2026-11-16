import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';

class TrendPoint {
  const TrendPoint(this.at, this.values, {this.isSample = false});

  final DateTime at;
  final List<int> values;
  final bool isSample;
}

class TrendChart extends StatelessWidget {
  const TrendChart({super.key, required this.points, required this.labels});

  final List<TrendPoint> points;
  final List<String> labels;

  static const _colors = [AppColors.green, AppColors.purple];

  @override
  Widget build(BuildContext context) {
    final (low, high) = _range();
    final formats = MaterialLocalizations.of(context);
    final sorted = points.indexed.toList()
      ..sort((a, b) {
        final byDate = a.$2.at.compareTo(b.$2.at);
        return byDate == 0 ? a.$1.compareTo(b.$1) : byDate;
      });
    final timeOrder = sorted.map((entry) => entry.$2).toList();
    final start = formats.formatShortDate(timeOrder.first.at);
    final end = formats.formatShortDate(timeOrder.last.at);
    final axisText = Theme.of(context).textTheme.labelSmall
        ?.copyWith(color: AppColors.muted);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                SizedBox(
                  height: 146,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2, right: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (final tick in [high, (high + low) ~/ 2, low])
                          Text(formats.formatDecimal(tick), style: axisText),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 146,
                    child: CustomPaint(
                      painter: _LinePainter(timeOrder, low, high),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          start == end ? start : '$start – $end',
          textAlign: TextAlign.center,
          style: axisText,
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 14,
          runSpacing: 4,
          children: [
            for (final (index, label) in labels.indexed)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    index == 0 ? Icons.circle : Icons.square,
                    size: 9,
                    color: _colors[index],
                  ),
                  const SizedBox(width: 5),
                  Flexible(child: Text(label, style: axisText)),
                ],
              ),
          ],
        ),
      ],
    );
  }

  (int, int) _range() {
    final values = points.expand((point) => point.values);
    final low = values.reduce(math.min);
    final high = values.reduce(math.max);
    return (math.max(0, (low ~/ 10) * 10 - 10), ((high + 9) ~/ 10) * 10 + 10);
  }
}

class _LinePainter extends CustomPainter {
  const _LinePainter(this.points, this.low, this.high);

  final List<TrendPoint> points;
  final int low;
  final int high;

  @override
  void paint(Canvas canvas, Size size) {
    const inset = 7.0;
    final width = math.max(0.0, size.width - inset * 2);
    final height = size.height - inset * 2;
    final grid = Paint()..color = AppColors.line;
    for (var i = 0; i < 3; i++) {
      final y = inset + height * i / 2;
      canvas.drawLine(Offset(inset, y), Offset(inset + width, y), grid);
    }
    final first = points.first.at;
    final span = points.last.at.difference(first).inMilliseconds;
    for (var series = 0; series < points.first.values.length; series++) {
      final color = TrendChart._colors[series];
      final path = Path();
      final offsets = <Offset>[];
      for (final (index, point) in points.indexed) {
        final position = points.length == 1
            ? .5
            : span == 0
            ? index / (points.length - 1)
            : point.at.difference(first).inMilliseconds / span;
        final level = (point.values[series] - low) / (high - low);
        final offset = Offset(
          inset + width * position,
          inset + height * (1 - level),
        );
        offsets.add(offset);
        if (index == 0) {
          path.moveTo(offset.dx, offset.dy);
        } else {
          path.lineTo(offset.dx, offset.dy);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeJoin = StrokeJoin.round,
      );
      for (final (index, offset) in offsets.indexed) {
        final marker = Paint()..color = color;
        if (series == 0) {
          canvas.drawCircle(offset, 3.5, marker);
          if (points[index].isSample) {
            canvas.drawCircle(offset, 1.7, Paint()..color = AppColors.surface);
          }
        } else {
          canvas.drawRect(
            Rect.fromCenter(center: offset, width: 6, height: 6),
            marker,
          );
          if (points[index].isSample) {
            canvas.drawRect(
              Rect.fromCenter(center: offset, width: 3, height: 3),
              Paint()..color = AppColors.surface,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.low != low ||
      oldDelegate.high != high;
}
