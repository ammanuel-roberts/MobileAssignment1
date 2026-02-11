import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const ValentineApp());

class ValentineApp extends StatelessWidget {
  const ValentineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ValentineHome(),
      theme: ThemeData(useMaterial3: true),
    );
  }
}

class ValentineHome extends StatefulWidget {
  const ValentineHome({super.key});

  @override
  State<ValentineHome> createState() => _ValentineHomeState();
}

class _ValentineHomeState extends State<ValentineHome>
    with SingleTickerProviderStateMixin {
  final List<String> emojiOptions = ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';

  late AnimationController _controller;
  bool celebrate = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cupid\'s Canvas')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Colors.pinkAccent, Colors.pink],

            radius: 1.2,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedEmoji,
              items: emojiOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => selectedEmoji = value ?? selectedEmoji),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => setState(() => celebrate = !celebrate),
              child: const Text('🎈 Celebrate'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) {
                    return CustomPaint(
                      size: const Size(300, 300),
                      painter: HeartEmojiPainter(
                        type: selectedEmoji,
                        animationValue: _controller.value,
                        celebrate: celebrate,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeartEmojiPainter extends CustomPainter {
  HeartEmojiPainter({
    required this.type,
    required this.animationValue,
    required this.celebrate,
  });

  final String type;
  final double animationValue;
  final bool celebrate;
  final Random rand = Random();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Part 2: Love trail
    final auraPaint = Paint()
      ..color = Colors.pinkAccent.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    final auraPath = Path()
      ..moveTo(center.dx, center.dy + 70)
      ..cubicTo(
        center.dx + 120,
        center.dy - 20,
        center.dx + 70,
        center.dy - 140,
        center.dx,
        center.dy - 50,
      )
      ..cubicTo(
        center.dx - 70,
        center.dy - 140,
        center.dx - 120,
        center.dy - 20,
        center.dx,
        center.dy + 70,
      )
      ..close();

    canvas.drawPath(auraPath, auraPaint);

    // Part 2: Heart with gradient
    final heartPath = Path()
      ..moveTo(center.dx, center.dy + 60)
      ..cubicTo(
        center.dx + 110,
        center.dy - 10,
        center.dx + 60,
        center.dy - 120,
        center.dx,
        center.dy - 40,
      )
      ..cubicTo(
        center.dx - 60,
        center.dy - 120,
        center.dx - 110,
        center.dy - 10,
        center.dx,
        center.dy + 60,
      )
      ..close();

    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.pinkAccent, Colors.pink],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCenter(center: center, width: 220, height: 220));

    canvas.drawPath(heartPath, paint);

    // Face
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 10, eyePaint);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 10, eyePaint);

    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy + 20), radius: 30),
      0,
      pi,
      false,
      mouthPaint,
    );
    // Part 2: added festive decorations and accents
    // Sparkles
    for (int i = 0; i < 10; i++) {
      final angle = (2 * pi * i / 10) + animationValue * 2 * pi;
      final sparkleOffset = Offset(
        center.dx + cos(angle) * 110,
        center.dy + sin(angle) * 110,
      );
      canvas.drawCircle(sparkleOffset, 3, Paint()..color = Colors.yellowAccent);
    }

    // Party celebration
    if (celebrate) {
      for (int i = 0; i < 12; i++) {
        final x = rand.nextDouble() * size.width;
        final y = size.height * (1 - animationValue) + rand.nextInt(40);
        final confettiPaint = Paint()
          ..color = Colors.primaries[rand.nextInt(Colors.primaries.length)];

        // Balloon
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x, y), width: 20, height: 28),
          confettiPaint,
        );

        // Confetti shapes
        if (i.isEven) {
          canvas.drawCircle(Offset(x, y + 35), 4, confettiPaint);
        } else {
          final triangle = Path()
            ..moveTo(x, y + 35)
            ..lineTo(x - 5, y + 45)
            ..lineTo(x + 5, y + 45)
            ..close();
          canvas.drawPath(triangle, confettiPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) => true;
}
