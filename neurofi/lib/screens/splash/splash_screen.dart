import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../router/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 1900));
    _navigate();
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = await authProvider.checkLoginStatus();
    if (!mounted) return;
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, RouteNames.dashboard);
    } else {
      Navigator.pushReplacementNamed(context, RouteNames.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03070E),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Metallic Text Heading
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black,
                          Colors.white,
                          Colors.transparent,
                        ],
                      ).createShader(bounds),
                      child: Text(
                        'NeuroFi',
                        style: AppTextStyles.displayLarge.copyWith(
                          fontSize: 64,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          fontFamily: 'serif',
                          letterSpacing: 2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'AI-POWERED FINANCE',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        letterSpacing: 4,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
