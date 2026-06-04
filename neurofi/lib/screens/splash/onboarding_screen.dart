import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../router/route_names.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      imagePath: 'assets/images/onboarding_logo_1.png',
      title: 'Smart Finance\nAt Your Fingertips',
      subtitle:
          'Track every rupee automatically. Know exactly where your money goes with zero effort.',
    ),
    _OnboardingData(
      imagePath: 'assets/images/onboarding_logo_2.png',
      title: 'AI That Works\nFor You',
      subtitle:
          'Get personalized insights, auto-categorize transactions, and receive budget predictions before you overspend.',
    ),
    _OnboardingData(
      imagePath: 'assets/images/onboarding_logo_3.png',
      title: 'Achieve Every\nFinancial Goal',
      subtitle:
          'Set savings goals, split expenses with friends, scan receipts, and grow your wealth intelligently.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, RouteNames.login);
    }
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03070E),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboarding_bg.avif',
              fit: BoxFit.cover,
            ),
          ),

          FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemBuilder: (context, index) {
                      return _OnboardingPage(data: _pages[index]);
                    },
                  ),

                  // Skip Button
                  Positioned(
                    top: 16,
                    right: 24,
                    child: GestureDetector(
                      onTap: _skip,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(
                                255,
                                40,
                                41,
                                41,
                              ).withValues(alpha: 0.2),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Text(
                          'Skip',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom Controls
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Page Dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _pages.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: _currentPage == i ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _currentPage == i
                                      ? Colors.white
                                      : const Color.fromARGB(255, 88, 85, 85),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: _currentPage == i
                                      ? [
                                          const BoxShadow(
                                            color: Color.fromARGB(
                                              255,
                                              118,
                                              119,
                                              119,
                                            ),
                                            blurRadius: 12,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),

                          // Continue / Get Started Button
                          GestureDetector(
                            onTap: _nextPage,
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromARGB(255, 22, 22, 22),
                                    blurRadius: 15,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  _currentPage < _pages.length - 1
                                      ? 'Continue →'
                                      : 'Get Started →',
                                  style: AppTextStyles.buttonText.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          if (_currentPage == _pages.length - 1) ...[
                            const SizedBox(height: 24),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacementNamed(
                                context,
                                RouteNames.register,
                              ),
                              child: Text(
                                'Create a new account',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: Colors.white,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 24),
                            // Invisible spacer to match height of the link
                            const Opacity(opacity: 0, child: Text('Spacer')),
                          ],
                        ],
                      ),
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
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // Central Image Graphic
          SizedBox(
            width: 250,
            height: 250,
            child: Image.asset(data.imagePath, fit: BoxFit.contain),
          ),

          const Spacer(flex: 1),

          // Metallic Text Heading
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFFFFF), Color(0xFFB0C4DE), Color(0xFF8FA3B8)],
            ).createShader(bounds),
            child: Text(
              data.title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headingLarge.copyWith(
                fontSize: 30,
                height: 1.2,
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontFamily:
                    'serif', // Gives that elegant look from the screenshot
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Subtitle
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: const Color.fromARGB(255, 255, 255, 255),
              height: 1.5,
              fontSize: 14,
            ),
          ),

          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final String imagePath;
  final String title;
  final String subtitle;

  const _OnboardingData({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });
}
