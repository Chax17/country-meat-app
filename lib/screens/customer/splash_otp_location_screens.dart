import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

// ─── SPLASH ──────────────────────────────────────────────────────────────────
// Design: Two distinct Figma splash states with a simple cross-fade transition
// State 1: Red background + native white logo
// State 2: White background + red logo (Fades in over State 1)
class CustSplashScreen extends StatefulWidget {
  final VoidCallback onDone;
  const CustSplashScreen({super.key, required this.onDone});

  @override
  State<CustSplashScreen> createState() => _CustSplashScreenState();
}

class _CustSplashScreenState extends State<CustSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  Timer? _timer1;
  Timer? _timer2;
  bool _isInitStarted = false;
  bool _isPrecached = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeInOut,
    );

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // State 2 hold (~600ms) -> Route to Home or Welcome
        _timer2 = Timer(const Duration(milliseconds: 600), () {
          if (mounted) {
            widget.onDone();
          }
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitStarted) {
      _isInitStarted = true;
      _initSplash();
    }
  }

  Future<void> _initSplash() async {
    // Precache both splash logo assets so they are fully decoded into GPU memory
    // before presenting the first splash frame.
    await Future.wait([
      precacheImage(const AssetImage('assets/images/logo_white.png'), context),
      precacheImage(const AssetImage('assets/images/logo_transp.png'), context),
    ]);

    if (!mounted) return;

    setState(() {
      _isPrecached = true;
    });

    // State 1 hold (~800ms) -> Start cross-fade to State 2
    _timer1 = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
        _ctrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _timer1?.cancel();
    _timer2?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPrecached) {
      return const SizedBox.shrink();
    }

    final logoWidth = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      body: Stack(
        children: [
          // ── STATE 1: Red background + dedicated white logo asset ─────────
          Container(
            color: AppColors.brandRed,
            child: Center(
              child: Image.asset(
                'assets/images/logo_white.png',
                width: logoWidth,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // ── STATE 2: White background + red logo (Cross-fades over State 1) ─
          FadeTransition(
            opacity: _fade,
            child: Container(
              color: Colors.white,
              child: Center(
                child: Image.asset(
                  'assets/images/logo_transp.png',
                  width: logoWidth,
                  fit: BoxFit.contain,
                  color: AppColors.brandRed,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ONBOARDING ──────────────────────────────────────────────────────────────
// Design: Solid red background with white logo at top, six circular value proposition
// illustrations centered in middle, and white bottom card with tagline + Get Started
class CustOnboardingScreen extends StatelessWidget {
  final VoidCallback onDone;
  const CustOnboardingScreen({super.key, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final logoWidth = mediaQuery.size.width * 0.7;

    return Scaffold(
      backgroundColor: AppColors.brandRed,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Section: Country Meat Logo + Value Circles ────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  children: [
                    // Country Meat logo (cropped asset without 68.7% vertical transparent padding)
                    Image.asset(
                      'assets/images/logo_white_cropped.png',
                      width: logoWidth,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/logo_white.png',
                        width: logoWidth,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Six circular illustrated value propositions
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          'assets/images/getStarted.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/images/ob_icon5.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── White bottom card ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                          fontSize: 14,
                          color: AppColors.gray500,
                          fontFamily: 'Inter'),
                      children: [
                        TextSpan(text: 'Welcome to '),
                        TextSpan(
                          text: 'Country Meat',
                          style: TextStyle(
                            color: AppColors.brandRed,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'A company by the meat lovers\nfor the meat lovers',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.gray900,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onDone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                      ),
                      child: const Text('Get Started'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── PHONE LOGIN ─────────────────────────────────────────────────────────────
class CustLoginScreen extends StatefulWidget {
  final void Function(String phone) onContinue;
  const CustLoginScreen({super.key, required this.onContinue});

  @override
  State<CustLoginScreen> createState() => _CustLoginScreenState();
}

class _CustLoginScreenState extends State<CustLoginScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final raw = _ctrl.text.trim();
    final phone = raw.isEmpty ? '9876543210' : raw;
    widget.onContinue(phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      // Logo small
                      Image.asset(
                        'assets/images/logo_transp.png',
                        height: 48,
                        fit: BoxFit.contain,
                        color: AppColors.brandRed,
                        colorBlendMode: BlendMode.srcIn,
                        errorBuilder: (_, __, ___) => Image.asset(
                            'assets/images/logo.png', height: 48),
                      ),
                      const SizedBox(height: 36),
                      const Text(
                        'Enter your\nphone number',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.gray900,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "We'll send you a verification code",
                        style: TextStyle(color: AppColors.gray500, fontSize: 14),
                      ),
                      const SizedBox(height: 32),
                      // Phone input
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.gray200, width: 1.5),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                            decoration: const BoxDecoration(
                              border: Border(
                                  right: BorderSide(color: AppColors.gray200, width: 1.5)),
                            ),
                            child: const Text('+91',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: AppColors.gray700)),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _ctrl,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: '9876543210',
                                hintStyle: TextStyle(color: AppColors.gray300),
                                contentPadding: EdgeInsets.symmetric(horizontal: 14),
                                counterText: '',
                              ),
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md)),
                            elevation: 0,
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          child: const Text('Send OTP'),
                        ),
                      ),
                      const Spacer(),
                      const Center(
                        child: Text(
                          'By continuing, you agree to our\nTerms of Service & Privacy Policy',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.gray400, fontSize: 12, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── OTP SCREEN ───────────────────────────────────────────────────────────────
class CustOtpScreen extends StatefulWidget {
  final String phone;
  final VoidCallback onContinue;
  const CustOtpScreen({super.key, required this.phone, required this.onContinue});

  @override
  State<CustOtpScreen> createState() => _CustOtpScreenState();
}

class _CustOtpScreenState extends State<CustOtpScreen> {
  final _controllers = List.generate(4, (_) => TextEditingController());
  final _focusNodes = List.generate(4, (_) => FocusNode());
  int _secondsLeft = 30;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayPhone = widget.phone.isNotEmpty ? widget.phone : '9876543210';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.gray700),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Image.asset(
              'assets/images/logo_transp.png',
              height: 44,
              color: AppColors.brandRed,
              colorBlendMode: BlendMode.srcIn,
              errorBuilder: (_, __, ___) =>
                  Image.asset('assets/images/logo.png', height: 44),
            ),
            const SizedBox(height: 32),
            const Text('Verify your number',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('Enter the 4-digit OTP sent to +91 $displayPhone',
                style: const TextStyle(color: AppColors.gray500, fontSize: 14)),
            const SizedBox(height: 36),
            // OTP boxes
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) => _OtpBox(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  onChanged: (v) {
                    if (v.length == 1 && i < 3) {
                      _focusNodes[i + 1].requestFocus();
                    } else if (v.isEmpty && i > 0) {
                      _focusNodes[i - 1].requestFocus();
                    }
                    // Auto verify when all filled
                    if (_controllers.every((c) => c.text.isNotEmpty)) {
                      Future.delayed(const Duration(milliseconds: 200), widget.onContinue);
                    }
                  },
                )),
              ),
            ),
            const SizedBox(height: 24),
            // Resend
            Center(
              child: _secondsLeft > 0
                  ? Text('Resend OTP in 0:${_secondsLeft.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: AppColors.gray500, fontSize: 13))
                  : GestureDetector(
                      onTap: () {
                        setState(() => _secondsLeft = 30);
                        _startTimer();
                      },
                      child: const Text('Resend OTP',
                          style: TextStyle(
                              color: AppColors.brandRed,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md)),
                  elevation: 0,
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                child: const Text('Verify & Continue'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray200, width: 2),
        borderRadius: BorderRadius.circular(AppRadius.md),
        color: AppColors.gray50,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
            fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.brandRed),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
      ),
    );
  }
}

// ─── LOCATION ─────────────────────────────────────────────────────────────────
class CustLocationScreen extends StatelessWidget {
  final VoidCallback onContinue;
  const CustLocationScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      Image.asset(
                        'assets/images/logo_transp.png',
                        height: 44,
                        color: AppColors.brandRed,
                        colorBlendMode: BlendMode.srcIn,
                        errorBuilder: (_, __, ___) =>
                            Image.asset('assets/images/logo.png', height: 44),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            // Location illustration
                            Container(
                              width: 140,
                              height: 140,
                              decoration: const BoxDecoration(
                                color: AppColors.brandRedBg,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                size: 70,
                                color: AppColors.brandRed,
                              ),
                            ),
                            const SizedBox(height: 28),
                            const Text(
                              'Set your\ndelivery location',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'We deliver fresh country meat every morning.\nTell us where to bring it.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: AppColors.gray500, fontSize: 14, height: 1.5),
                            ),
                            const SizedBox(height: 28),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: onContinue,
                                icon: const Icon(Icons.my_location_rounded),
                                label: const Text('Use Current Location'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.brandRed,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppRadius.md)),
                                  elevation: 0,
                                  textStyle: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: onContinue,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.brandRed,
                                  side: const BorderSide(color: AppColors.brandRed),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppRadius.md)),
                                  textStyle: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                child: const Text('Enter Address Manually'),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
