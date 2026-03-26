import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Контроллеры анимации
  late AnimationController _revealController;
  late AnimationController _lockupController;

  // Анимации логотипа
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _logoShift;
  late Animation<double> _logoShiftBounce; // Пружина при сдвиге

  // Анимации текста
  late Animation<double> _textOpacity;
  late Animation<double> _textSlide;
  late Animation<double> _textBounce; // Пружина для текста

  // Лапки
  final List<_Paw> _paws = [];
  final List<AnimationController> _pawControllers = [];

  @override
  void initState() {
    super.initState();

    // Генерируем лапки - много и яркие
    final random = math.Random();
    for (int i = 0; i < 40; i++) {
      _paws.add(_Paw(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 28 + random.nextDouble() * 40,
        rotation: (random.nextInt(70) - 35) * math.pi / 180,
        scale: 0.7 + random.nextDouble() * 0.5,
        delay: i * 60 + random.nextInt(200),
      ));

      final controller = AnimationController(
        duration: const Duration(milliseconds: 2500),
        vsync: this,
      );
      _pawControllers.add(controller);
    }

    // === REVEAL: логотип появляется (700ms) - красивый scale ===
    _revealController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Scale с ПРУЖИНОЙ: 0 -> 1.15 -> 0.92 -> 1.05 -> 0.98 -> 1.0
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 0.92)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.92, end: 1.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 0.98)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 14,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.98, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 13,
      ),
    ]).animate(_revealController);

    // === LOCKUP: сдвиг лого + появление текста (800ms для пружины) ===
    _lockupController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Логотип сдвигается влево с ПРУЖИНОЙ: 0 -> -15 -> -8 -> -12 -> -10
    _logoShift = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -15.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -15.0, end: -8.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -8.0, end: -12.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -12.0, end: -10.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
    ]).animate(CurvedAnimation(
      parent: _lockupController,
      curve: const Interval(0.0, 0.5),
    ));

    // Bounce scale логотипа при сдвиге
    _logoShiftBounce = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.95),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.02),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.02, end: 1.0),
        weight: 30,
      ),
    ]).animate(CurvedAnimation(
      parent: _lockupController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));

    // Текст появляется с ПРУЖИНОЙ
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _lockupController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    // Текст выезжает с пружиной: 40 -> -5 -> 3 -> 0
    _textSlide = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 40.0, end: -5.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -5.0, end: 3.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 3.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
    ]).animate(CurvedAnimation(
      parent: _lockupController,
      curve: const Interval(0.4, 1.0),
    ));

    // Bounce scale текста при появлении
    _textBounce = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.05),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 0.97),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.97, end: 1.0),
        weight: 20,
      ),
    ]).animate(CurvedAnimation(
      parent: _lockupController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    // Запускаем лапки
    for (int i = 0; i < _paws.length; i++) {
      Future.delayed(Duration(milliseconds: _paws[i].delay), () {
        if (mounted) _animatePaw(i);
      });
    }

    // 1) Логотип появляется в центре
    await _revealController.forward();

    // 2) Пауза - смотрим на логотип
    await Future.delayed(const Duration(milliseconds: 700));

    // 3-4) Сдвиг + текст
    await _lockupController.forward();

    // 5) Финальная пауза
    await Future.delayed(const Duration(milliseconds: 1100));

    widget.onComplete();
  }

  void _animatePaw(int index) {
    if (!mounted) return;
    final controller = _pawControllers[index];

    controller.reset();
    controller.forward().then((_) {
      if (mounted) {
        Future.delayed(Duration(milliseconds: 500 + math.Random().nextInt(800)), () {
          _animatePaw(index);
        });
      }
    });
  }

  @override
  void dispose() {
    _revealController.dispose();
    _lockupController.dispose();
    for (final c in _pawControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // Фон с лапками
          ...List.generate(_paws.length, (i) {
            final paw = _paws[i];
            return Positioned(
              left: paw.x * size.width - paw.size / 2,
              top: paw.y * size.height - paw.size / 2,
              child: AnimatedBuilder(
                animation: _pawControllers[i],
                builder: (context, child) {
                  final progress = _pawControllers[i].value;

                  // Плавная анимация: появление -> дыхание -> исчезновение
                  double opacity;
                  if (progress < 0.2) {
                    // Fade in
                    opacity = progress / 0.2;
                  } else if (progress < 0.75) {
                    // Breathe: пульсация
                    final breathe = (progress - 0.2) / 0.55;
                    opacity = 0.7 + 0.3 * math.sin(breathe * math.pi * 2);
                  } else {
                    // Fade out
                    opacity = 1.0 - (progress - 0.75) / 0.25;
                  }

                  return Transform.rotate(
                    angle: paw.rotation,
                    child: Transform.scale(
                      scale: paw.scale,
                      child: Opacity(
                        opacity: (opacity * 0.25).clamp(0.0, 1.0), // Яркие лапки!
                        child: Icon(
                          Icons.pets,
                          size: paw.size,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),

          // Лого + текст
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_revealController, _lockupController]),
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Логотип с пружинной анимацией
                    Transform.translate(
                      offset: Offset(_logoShift.value, 0),
                      child: Transform.scale(
                        scale: _logoScale.value * _logoShiftBounce.value,
                        child: Opacity(
                          opacity: _logoOpacity.value,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 25,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.asset(
                                'assets/logo.png',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppTheme.primary,
                                        AppTheme.primary.withOpacity(0.8),
                                      ],
                                    ),
                                  ),
                                  child: const Icon(Icons.pets, color: Colors.white, size: 50),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Текст с пружинной анимацией
                    Transform.translate(
                      offset: Offset(_textSlide.value, 0),
                      child: Transform.scale(
                        scale: _textBounce.value,
                        child: Opacity(
                          opacity: _textOpacity.value,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 18),
                            child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PetPet',
                                style: const TextStyle(fontFamily: 'serif', 
                                  fontSize: 42,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0D0D0D),
                                  letterSpacing: 1,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'MARKETPLACE',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primary,
                                  letterSpacing: 5,
                                  height: 1.0,
                                ),
                              ),
                            ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Paw {
  final double x, y, size, rotation, scale;
  final int delay;

  _Paw({
    required this.x,
    required this.y,
    required this.size,
    required this.rotation,
    required this.scale,
    required this.delay,
  });
}
