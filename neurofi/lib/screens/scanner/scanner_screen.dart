import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../router/route_names.dart';
import 'dart:async';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});
  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double>   _scanAnim;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _scanAnim = Tween<double>(begin: 0, end: 1).animate(_animCtrl);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() => _isScanning = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isScanning = false);
    Navigator.pushNamed(context, RouteNames.receiptPreview);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg0,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg0, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGrey, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Scan Receipt',
            style: AppTextStyles.headingSmall.copyWith(color: AppColors.lightGrey)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.darkBg1.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.darkBorder),
                        ),
                      ),
                      _cornerBrackets(),
                      if (_isScanning)
                        AnimatedBuilder(
                          animation: _scanAnim,
                          builder: (_, __) => Positioned(
                            top: _scanAnim.value * 300,
                            left: 0, right: 0,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.green.withOpacity(0.7),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isScanning ? Icons.camera_alt_rounded : Icons.receipt_long_rounded,
                              color: AppColors.darkText3.withOpacity(0.5),
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _isScanning ? 'Scanning...' : 'Position receipt in frame',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkText3),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity, height: 48,
                decoration: BoxDecoration(
                  color: AppColors.darkBg1,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.photo_library_outlined, color: AppColors.darkText2, size: 18),
                  const SizedBox(width: 8),
                  Text('Upload from Gallery',
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.darkText2)),
                ]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
            child: GestureDetector(
              onTap: _isScanning ? null : _startScan,
              child: Container(
                width: double.infinity, height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.forest, AppColors.green]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(
                      color: AppColors.green.withOpacity(0.3),
                      blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Center(child: _isScanning
                    ? const SizedBox(width: 24, height: 24,
                        child: CircularProgressIndicator(color: AppColors.lightGrey, strokeWidth: 2))
                    : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.camera_alt_rounded, color: AppColors.lightGrey, size: 20),
                        const SizedBox(width: 8),
                        Text('Take Photo',
                            style: AppTextStyles.buttonText.copyWith(color: AppColors.lightGrey)),
                      ])),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cornerBrackets() {
    const size = 24.0, thick = 3.0;
    final color = AppColors.green;
    return Stack(children: [
      Positioned(top: 12, left: 12, child: _bracket(color, size, thick, top: true, left: true)),
      Positioned(top: 12, right: 12, child: _bracket(color, size, thick, top: true, left: false)),
      Positioned(bottom: 12, left: 12, child: _bracket(color, size, thick, top: false, left: true)),
      Positioned(bottom: 12, right: 12, child: _bracket(color, size, thick, top: false, left: false)),
    ]);
  }

  Widget _bracket(Color c, double s, double t, {required bool top, required bool left}) {
    return SizedBox(width: s, height: s,
        child: CustomPaint(painter: _BracketPainter(c, t, top, left)));
  }
}

class _BracketPainter extends CustomPainter {
  final Color color;
  final double thick;
  final bool top, left;
  const _BracketPainter(this.color, this.thick, this.top, this.left);
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color..strokeWidth = thick..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    if (left) {
      canvas.drawLine(Offset(0, 0), Offset(s.width, 0), p);
      canvas.drawLine(Offset(0, 0), Offset(0, s.height), p);
    } else {
      canvas.drawLine(Offset(0, 0), Offset(s.width, 0), p);
      canvas.drawLine(Offset(s.width, 0), Offset(s.width, s.height), p);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}
