import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double startAngle = 90;
  double endAngle = 90;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() => endAngle += 60);
          Future.delayed(
            Duration(milliseconds: 1000),
            () => startAngle = endAngle,
          );
        },
        onDoubleTap: () {
          setState(() => endAngle -= 60);
          Future.delayed(
            Duration(milliseconds: 1000),
            () => startAngle = endAngle,
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              child: TweenAnimationBuilder(
                curve: Curves.easeInOut,
                duration: Duration(milliseconds: 1000),
                tween: Tween(begin: startAngle, end: endAngle),
                builder: (context, value, child) {
                  return CustomPaint(painter: Painter(angle: value));
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class Painter extends CustomPainter {
  final double angle;
  Painter({this.angle});

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset(0, 0) & size;
    final center = bounds.center;
    final radius = size.width / 2;
    final knobThickness = size.width / 10;
    final knobPadding = knobThickness / 8;
    final angleOffset = -angle.radians;

    canvas.drawCircle(center, radius, Paint()..color = Colors.black);

    final clockRadius = radius - (knobPadding * 1) - knobThickness;
    final tickLength = knobThickness / 1.8;
    final tickPadding = clockRadius / 16;
    final tickRadius = clockRadius - tickPadding;
    final tickDivisions = 1;
    final tickTextFontSize = tickLength * .2;
    final tickColor = Colors.white;

    final crossLength = size.width / 12;

    canvas.drawLine(
      Offset(center.dx - crossLength, center.dy),
      Offset(center.dx + crossLength, center.dy),
      Paint()
        ..color = tickColor
        ..strokeWidth = tickLength / 28,
    );

    canvas.drawLine(
      Offset(center.dx, center.dy - crossLength),
      Offset(center.dx, center.dy + crossLength),
      Paint()
        ..color = tickColor
        ..strokeWidth = tickLength / 28,
    );

    for (int i = 0; i < (360 / tickDivisions); i++) {
      final index = i * tickDivisions;
      final strokeRadius = tickLength;
      final angle = index.radians + angleOffset;

      if (i % 2 == 0)
        canvas.drawLine(
          toPolar(center, angle, i == 0 ? tickRadius + 10 : tickRadius),
          toPolar(center, angle, tickRadius - strokeRadius),
          Paint()
            ..color = i == 0 ? Colors.red : tickColor
            ..strokeWidth = i % 30 == 0 ? (tickLength / 12) : tickLength / 32,
        );

      if (i % 30 == 0) {
        _drawParagraph(
          canvas,
          "$i",
          offset: toPolar(center, angle, tickRadius + 20),
          color: Colors.white,
          fontSize: tickTextFontSize * 2.2,
          fontWeight: FontWeight.w600,
        );
      }

      if (i % 90 == 0) {
        String cardinals = "";
        if ((i % 90) == 0) cardinals = "E";
        if ((i % (90 * 2)) == 0) cardinals = "S";
        if ((i % (90 * 3)) == 0) cardinals = "W";
        if ((i % (90 * 4)) == 0) cardinals = "N";
        _drawParagraph(
          canvas,
          "$cardinals",
          offset:
              toPolar(center, angle, tickRadius - (tickLength + strokeRadius)),
          color: Colors.white,
          fontSize: tickTextFontSize * 4,
          fontWeight: FontWeight.w600,
        );
      }
    }
  }
}

extension NumX<T extends num> on T {
  double get radians => (this * math.pi) / 180.0;
}

Offset toPolar(Offset center, double radians, double radius) {
  return center +
      Offset(radius * math.cos(radians), radius * math.sin(radians));
}

Rect _drawParagraph(
  Canvas canvas,
  String text, {
  @required Offset offset,
  @required Color color,
  @required double fontSize,
  String fontFamily,
  FontWeight fontWeight,
}) {
  final builder =
      ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: TextAlign.center))
        ..pushStyle(ui.TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: fontWeight,
          letterSpacing: 1.2,
          fontFamily: fontFamily,
        ))
        ..addText(text);
  final paragraph = builder.build();
  final constraints = ui.ParagraphConstraints(width: fontSize * text.length);
  final finalOffset = offset - Offset(constraints.width / 2, fontSize / 2);
  canvas.drawParagraph(paragraph..layout(constraints), finalOffset);
  return Rect.fromLTWH(
      finalOffset.dx, finalOffset.dy, paragraph.longestLine, paragraph.height);
}
