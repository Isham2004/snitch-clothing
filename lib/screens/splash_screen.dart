import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../providers/user_provider.dart';
import 'auth/login_screen.dart';
import 'main_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainCtrl;
  late AnimationController _shimmerCtrl;
  late AnimationController _loadCtrl;

  // Logo circle
  late Animation<double> _circleScale;
  late Animation<double> _circleFade;
  // S letter
  late Animation<double> _sScale;
  late Animation<double> _sFade;
  // Brand name slide up
  late Animation<Offset> _nameSlide;
  late Animation<double> _nameFade;
  // Tagline
  late Animation<double> _tagFade;
  // Shimmer on circle
  late Animation<double> _shimmer;
  // Progress bar
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    _mainCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _shimmerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
    _loadCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));

    _circleScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.0, 0.45, curve: Curves.elasticOut)),
    );
    _circleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.0, 0.3, curve: Curves.easeOut)),
    );
    _sScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.2, 0.6, curve: Curves.elasticOut)),
    );
    _sFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.2, 0.5, curve: Curves.easeOut)),
    );
    _nameSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.45, 0.75, curve: Curves.easeOutCubic)),
    );
    _nameFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.45, 0.75, curve: Curves.easeOut)),
    );
    _tagFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.65, 0.9, curve: Curves.easeOut)),
    );
    _shimmer = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut),
    );
    _progress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadCtrl, curve: Curves.easeInOut),
    );

    _mainCtrl.forward();
    _loadCtrl.forward();

    Future.delayed(const Duration(milliseconds: 3200), () async {
      if (!mounted) return;
      final user = context.read<UserProvider>();
      for (int i = 0; i < 20 && !user.initialized; i++) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      if (!mounted) return;
      final Widget next =
          user.isLoggedIn ? const MainScaffold() : const LoginScreen();
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => next,
          transitionDuration: const Duration(milliseconds: 700),
          transitionsBuilder: (_, anim, _, child) {
            return FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
                    .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                child: child,
              ),
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _shimmerCtrl.dispose();
    _loadCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D47A1),
                  Color(0xFF1565C0),
                  Color(0xFF1976D2),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Decorative circles background
          Positioned(
            top: -size.width * 0.3,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
              ),
            ),
          ),
          Positioned(
            bottom: -size.width * 0.2,
            left: -size.width * 0.15,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.15,
            left: -size.width * 0.25,
            child: Container(
              width: size.width * 0.55,
              height: size.width * 0.55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),

          // Main content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Logo circle with S
              AnimatedBuilder(
                animation: _mainCtrl,
                builder: (_, _) {
                  return FadeTransition(
                    opacity: _circleFade,
                    child: ScaleTransition(
                      scale: _circleScale,
                      child: AnimatedBuilder(
                        animation: _shimmerCtrl,
                        builder: (_, _) {
                          return Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.25),
                                  Colors.white.withOpacity(0.08),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: -5,
                                ),
                              ],
                            ),
                            child: ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  begin: Alignment(_shimmer.value - 1, 0),
                                  end: Alignment(_shimmer.value, 0),
                                  colors: [
                                    Colors.white.withOpacity(0.0),
                                    Colors.white.withOpacity(0.4),
                                    Colors.white.withOpacity(0.0),
                                  ],
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.srcATop,
                              child: Center(
                                child: FadeTransition(
                                  opacity: _sFade,
                                  child: ScaleTransition(
                                    scale: _sScale,
                                    child: const Text(
                                      'S',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 88,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -2,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 36),

              // Brand name
              AnimatedBuilder(
                animation: _mainCtrl,
                builder: (_, _) => FadeTransition(
                  opacity: _nameFade,
                  child: SlideTransition(
                    position: _nameSlide,
                    child: Column(
                      children: [
                        const Text(
                          'SNITCH',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 30, height: 1, color: Colors.white.withOpacity(0.5)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'C L O T H I N G',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 6,
                                ),
                              ),
                            ),
                            Container(width: 30, height: 1, color: Colors.white.withOpacity(0.5)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tagline
              AnimatedBuilder(
                animation: _mainCtrl,
                builder: (_, _) => FadeTransition(
                  opacity: _tagFade,
                  child: Text(
                    'WEAR YOUR STORY',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 5,
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _loadCtrl,
                      builder: (_, _) => ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _progress.value,
                          backgroundColor: Colors.white.withOpacity(0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Loading collection...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 10,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }
}
