import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/weight_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _characterPointingInput =
      'assets/images/character_pointing_input.png';
  static const _cloudTop = 'assets/images/cloud_top.png';
  static const _cloudBottom = 'assets/images/cloud_bottom.png';

  final _controller = TextEditingController(text: '00.0');
  final _formKey = GlobalKey<FormState>();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(weightEntriesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFD),
      body: entriesAsync.when(
        data: (_) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _WeightInputHero(
                  formKey: _formKey,
                  controller: _controller,
                  focusNode: _focusNode,
                  characterAsset: _characterPointingInput,
                  cloudTopAsset: _cloudTop,
                  cloudBottomAsset: _cloudBottom,
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) =>
            Center(child: Text('読み込みに失敗しました: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _WeightInputHero extends StatelessWidget {
  const _WeightInputHero({
    required this.formKey,
    required this.controller,
    required this.focusNode,
    required this.characterAsset,
    required this.cloudTopAsset,
    required this.cloudBottomAsset,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String characterAsset;
  final String cloudTopAsset;
  final String cloudBottomAsset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mediaQuery = MediaQuery.of(context);

    return SizedBox(
      height: (mediaQuery.size.height - mediaQuery.padding.top).clamp(
        720.0,
        920.0,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _KawaiiBackgroundPainter(),
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFEEF8),
                      Color(0xFFFFFEFC),
                      Color(0xFFFFF7FC),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              cloudTopAsset,
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
              excludeFromSemantics: true,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(
              cloudBottomAsset,
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomCenter,
              excludeFromSemantics: true,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              mediaQuery.padding.top + 54,
              20,
              26,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  SizedBox(
                    height: 560,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomCenter,
                      children: [
                        Positioned(
                          bottom: 56,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 280),
                            child: Image.asset(
                              characterAsset,
                              key: ValueKey(characterAsset),
                              height: 470,
                              fit: BoxFit.contain,
                              semanticLabel: '体重入力キャラクター',
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: _WeightDisplayCard(
                            controller: controller,
                            focusNode: focusNode,
                            colorScheme: colorScheme,
                            inputBorder: _inputBorder,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: color, width: 2),
    );
  }
}

class _WeightDisplayCard extends StatelessWidget {
  const _WeightDisplayCard({
    required this.controller,
    required this.focusNode,
    required this.colorScheme,
    required this.inputBorder,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ColorScheme colorScheme;
  final OutlineInputBorder Function(Color color) inputBorder;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFF5A4CF), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE95BAA).withValues(alpha: 0.25),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: const Color(0xFF202633),
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.72),
            suffixText: 'kg',
            suffixStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: const Color(0xFF202633),
              fontWeight: FontWeight.w800,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 28,
            ),
            enabledBorder: inputBorder(const Color(0xFFF2B6D8)),
            focusedBorder: inputBorder(colorScheme.primary),
            errorBorder: inputBorder(colorScheme.error),
            focusedErrorBorder: inputBorder(colorScheme.error),
          ),
          validator: (value) {
            final weight = double.tryParse(value ?? '');
            if (weight == null || weight <= 0) return '有効な体重を入力してください';
            return null;
          },
        ),
      ),
    );
  }
}

class _KawaiiBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pinkStroke = Paint()
      ..color = const Color(0xFFEFA8D7).withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    final softFill = Paint()
      ..color = const Color(0xFFF9C6E4).withValues(alpha: 0.36)
      ..style = PaintingStyle.fill;
    final yellowFill = Paint()
      ..color = const Color(0xFFFFF2B8).withValues(alpha: 0.58)
      ..style = PaintingStyle.fill;

    _drawStar(
      canvas,
      Offset(size.width * 0.20, size.height * 0.52),
      17,
      yellowFill,
    );
    _drawStar(
      canvas,
      Offset(size.width * 0.76, size.height * 0.10),
      12,
      pinkStroke,
    );
    _drawStar(
      canvas,
      Offset(size.width * 0.90, size.height * 0.35),
      15,
      pinkStroke,
    );
    _drawStar(
      canvas,
      Offset(size.width * 0.43, size.height * 0.93),
      10,
      pinkStroke,
    );
    _drawHeart(
      canvas,
      Offset(size.width * 0.83, size.height * 0.25),
      18,
      Paint()..color = const Color(0xFFE886D5),
    );
    _drawHeart(
      canvas,
      Offset(size.width * 0.80, size.height * 0.94),
      13,
      Paint()..color = const Color(0xFFEFA8D7),
    );

    for (final dot in <Offset>[
      Offset(size.width * 0.10, size.height * 0.32),
      Offset(size.width * 0.18, size.height * 0.90),
      Offset(size.width * 0.56, size.height * 0.08),
      Offset(size.width * 0.90, size.height * 0.56),
    ]) {
      canvas.drawCircle(dot, 10, pinkStroke);
    }

    final stripePaint = Paint()
      ..color = const Color(0xFFF2B5DD).withValues(alpha: 0.32)
      ..strokeWidth = 3;
    for (double x = -40; x < 80; x += 12) {
      canvas.drawLine(
        Offset(x, size.height * 0.18),
        Offset(x + 90, size.height * 0.06),
        stripePaint,
      );
      canvas.drawLine(
        Offset(size.width - x, size.height * 0.72),
        Offset(size.width - x - 90, size.height * 0.84),
        stripePaint,
      );
    }
    canvas.drawCircle(
      Offset(size.width * 0.04, size.height * 0.80),
      58,
      softFill,
    );
    canvas.drawCircle(
      Offset(size.width * 0.98, size.height * 0.06),
      68,
      softFill,
    );
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final angle = -math.pi / 2 + i * math.pi / 4;
      final pointRadius = i.isEven ? radius : radius * 0.34;
      final point = Offset(
        center.dx + pointRadius * math.cos(angle),
        center.dy + pointRadius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy + size * 0.55)
      ..cubicTo(
        center.dx - size * 1.55,
        center.dy - size * 0.25,
        center.dx - size * 0.70,
        center.dy - size * 1.15,
        center.dx,
        center.dy - size * 0.48,
      )
      ..cubicTo(
        center.dx + size * 0.70,
        center.dy - size * 1.15,
        center.dx + size * 1.55,
        center.dy - size * 0.25,
        center.dx,
        center.dy + size * 0.55,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _KawaiiBackgroundPainter oldDelegate) => false;
}
