import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:matebakhna/theme/app_theme.dart';

class CustomAppBar {


static PreferredSizeWidget homeAppBar({
  required VoidCallback onSurpriseMe,
}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(100),
    child: Stack(
      children: [
        Positioned.fill(
          child: RealSeaWave(color: AppTheme.primary),
        ),
        AppBar(
          toolbarHeight: 100,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 16,
          title: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'assets/images/logo.jpg',
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
                    width: 48,
                    height: 48,
                    color: Colors.white24,
                    child: const Icon(
                      Icons.restaurant,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'طبختنا 🍳',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'دليلك الذكي لميزانية ومطبخ بيتك',
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 15),
                  ],
                ),
              ),
              IconButton(
                onPressed: onSurpriseMe,
                icon: const Icon(
                  Icons.casino_rounded,
                  color: Colors.white,
                  size: 27,
                ),
                tooltip: 'اقترح لي أكلة عشوائية!',
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  static PreferredSizeWidget batbakhnaBar({
    String title = "",
    Widget? wid,
    VoidCallback? onBack,
    BuildContext? context
  }) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Stack(
        children: [
        Positioned.fill(
                      child: RealSeaWave(color: AppTheme.primary),),

          
          AppBar(
            leading:  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: onBack ?? () => Navigator.pop(context!),
                  ),
            actions: wid != null
                ? [
                    Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 12),
                        child: wid)
                  ]
                : null,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              title,
              style: GoogleFonts.tajawal(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
        ],
      ),
    );
  }

}


class RealSeaWave extends StatefulWidget {
  final Color color;

  const RealSeaWave({
    super.key,
    this.color = const Color(0xff502418),
  });

  @override
  State<RealSeaWave> createState() => _RealSeaWaveState();
}

class _RealSeaWaveState extends State<RealSeaWave>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: SeaPainter(
            animationValue: controller.value,
            color: widget.color,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class SeaPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  SeaPainter({
    required this.animationValue,
    required this.color,
  });
  Path _buildWavePath(
    Size size,
    double time,
    double seaLevel, {
    required double amp1,
    required double freq1,
    required int speed1,
    required double amp2,
    required double freq2,
    required int speed2,
    required double amp3,
    required double freq3,
    required int speed3,
    required double verticalOffset,
  }) {
    final Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, seaLevel);

    for (double x = size.width; x >= 0; x -= 2) {
      final double wave1 = math.sin((x / freq1) + time * speed1) * amp1;
      final double wave2 = math.sin((x / freq2) + time * speed2) * amp2;
      final double wave3 = math.sin((x / freq3) + time * speed3) * amp3;

      final double y = seaLevel + verticalOffset + wave1 + wave2 + wave3;
      path.lineTo(x, y);
    }

    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double time = animationValue * 2 * math.pi;
    final double seaLevel = size.height * 0.90;

    // الطبقة الخلفية (أبعد، أفتح شوية، حركتها أهدى)
    final Paint backPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withValues(alpha: 0.55);

    final Path backPath = _buildWavePath(
      size,
      time,
      seaLevel,
      amp1: 10,
      freq1: 60,
      speed1: 1,
      amp2: 4,
      freq2: 90,
      speed2: -2,
      amp3: 3,
      freq3: 20,
      speed3: 1,
      verticalOffset: 6,
    );
    canvas.drawPath(backPath, backPaint);

    // الطبقة الأمامية (أقرب، أغمق، حركتها أسرع شوية)
    final Paint frontPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final Path frontPath = _buildWavePath(
      size,
      time,
      seaLevel,
      amp1: 14,
      freq1: 55,
      speed1: 2,
      amp2: 5,
      freq2: 110,
      speed2: 1,
      amp3: 2.5,
      freq3: 22,
      speed3: -3,
      verticalOffset: 3,
    );
    canvas.drawPath(frontPath, frontPaint);

    // خط رغوة فوق الموجة الأمامية عشان لمعة واقعية
    // final Paint foamPaint = Paint()
    //     ..style = PaintingStyle.stroke
    //     ..strokeWidth = 2
    //     ..color = Colors.white.withOpacity(0.35);

    //   final Path foamPath = Path();
    //   bool started = false;
    //   for (double x = size.width; x >= 0; x -= 2) {
    //     final double wave1 = math.sin((x / 55) + time * 2) * 14;
    //     final double wave2 = math.sin((x / 110) + time * 1) * 5;
    //     final double wave3 = math.sin((x / 22) + time * -3) * 2.5;
    //     final double y = seaLevel + 4 + wave1 + wave2 + wave3;

    //     if (!started) {
    //       foamPath.moveTo(x, y);
    //       started = true;
    //     } else {
    //       foamPath.lineTo(x, y);
    //     }
    //   }
    //   canvas.drawPath(foamPath, foamPaint);
  }

  @override
  bool shouldRepaint(covariant SeaPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}







// class SeaPainter extends CustomPainter {
//   final double animationValue;
//   final Color color;

//   SeaPainter({
//     required this.animationValue,
//     required this.color,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint paint = Paint()
//       ..color = color
//       ..style = PaintingStyle.fill;

//     final Path path = Path();

//     // ============================
//     // FIXED TOP
//     // ============================

//     path.moveTo(0, 0);
//     path.lineTo(size.width, 0);

//     path.lineTo(size.width, size.height);

//     // ============================
//     // WAVE POSITION
//     // ============================

//     final double seaLevel = size.height * 0.94;

//     path.lineTo(size.width, seaLevel);

//     // ============================
//     // SEAMLESS MOVING WAVES
//     // ============================

//     final double time = animationValue * 2 * math.pi;

//     for (double x = size.width; x >= 0; x -= 1) {
//       // Big wave
//       final double wave1 =
//           math.sin((x / 60) + time) * 15;

//       // Medium wave
//       final double wave2 =
//           math.sin((x / 30) - time * 2) * 6;

//       // Small wave
//       final double wave3 =
//           math.sin((x / 15) + time * 3) * 2;

//       final double y =
//           seaLevel +
//           wave1 +
//           wave2 +
//           wave3;

//       path.lineTo(x, y);
//     }

//     path.lineTo(0, size.height);
//     path.close();

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant SeaPainter oldDelegate) {
//     return oldDelegate.animationValue != animationValue;
//   }
// }
