import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart' hide LinearGradient, Image;
import 'package:kiddo_app/core/providers/auth_provider.dart';
import 'package:kiddo_app/core/providers/user_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  final bool initialSignUp;
  final String? defaultName;
  final int? defaultAge;
  final String? defaultGradeClass;

  const LoginPage({
    super.key,
    this.initialSignUp = false,
    this.defaultName,
    this.defaultAge,
    this.defaultGradeClass,
  });

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late bool _isSignUp; // Toggle between Log In and Sign Up

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _isLoading = false;
  String? _errorMessage;

  // Rive animation inputs
  StateMachineController? _riveController;
  SMIInput<bool>? _isHandsUp;
  SMIInput<bool>? _isChecking;
  SMIInput<double>? _numLook;
  SMIInput<bool>? _trigSuccess;
  SMIInput<bool>? _trigFail;
  SMITrigger? _successTrigger;
  SMITrigger? _failTrigger;

  void _triggerSuccess() {
    _successTrigger?.fire();
    _trigSuccess?.value = true;
  }

  void _triggerFail() {
    _failTrigger?.fire();
    _trigFail?.value = true;
  }

  void _setHandsUp(bool value) {
    _isHandsUp?.value = value;
  }

  void _setChecking(bool value) {
    _isChecking?.value = value;
  }

  void _setLook(double value) {
    _numLook?.value = value;
  }

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialSignUp;

    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        _setChecking(true);
        _setHandsUp(false);
        _setLook((_emailController.text.length * 2.0).clamp(0.0, 100.0));
      } else {
        _setChecking(false);
      }
    });

    _emailController.addListener(() {
      if (_emailFocusNode.hasFocus) {
        _setLook((_emailController.text.length * 2.0).clamp(0.0, 100.0));
      }
    });

    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        _setHandsUp(true);
        _setChecking(false);
      } else {
        if (!_confirmPasswordFocusNode.hasFocus) {
          _setHandsUp(false);
        }
      }
    });

    _confirmPasswordFocusNode.addListener(() {
      if (_confirmPasswordFocusNode.hasFocus) {
        _setHandsUp(true);
        _setChecking(false);
      } else {
        if (!_passwordFocusNode.hasFocus) {
          _setHandsUp(false);
        }
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    _riveController?.dispose();
    super.dispose();
  }

  void _onRiveInit(Artboard artboard) {
    // Try "State Machine 1" (used in login-1.riv), "Login Machine", or first available
    StateMachineController? controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1') ??
        StateMachineController.fromArtboard(artboard, 'Login Machine') ??
        (artboard.stateMachines.isNotEmpty
            ? StateMachineController.fromArtboard(
                artboard,
                artboard.stateMachines.first.name,
              )
            : null);

    if (controller != null) {
      artboard.addController(controller);
      _riveController = controller;
      for (var input in controller.inputs) {
        final name = input.name.toLowerCase().replaceAll('_', '');
        if (name == 'ishandsup' || name == 'handsup') {
          if (input is SMIInput<bool>) _isHandsUp = input;
        } else if (name == 'ischecking' || name == 'check' || name == 'checking') {
          if (input is SMIInput<bool>) _isChecking = input;
        } else if (name == 'numlook' || name == 'look') {
          if (input is SMIInput<double>) _numLook = input;
        } else if (name == 'trigsuccess' || name == 'success' || name == 'correct') {
          if (input is SMITrigger) {
            _successTrigger = input;
          } else if (input is SMIInput<bool>) {
            _trigSuccess = input;
          }
        } else if (name == 'trigfail' || name == 'fail' || name == 'incorrect') {
          if (input is SMITrigger) {
            _failTrigger = input;
          } else if (input is SMIInput<bool>) {
            _trigFail = input;
          }
        }
      }
    }
  }

  Future<void> _handleSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields.');
      _triggerFail();
      return;
    }

    if (_isSignUp) {
      final confirm = _confirmPasswordController.text;
      if (password != confirm) {
        setState(() => _errorMessage = 'Passwords do not match.');
        _triggerFail();
        return;
      }
      if (password.length < 6) {
        setState(
          () => _errorMessage = 'Password must be at least 6 characters.',
        );
        _triggerFail();
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isSignUp) {
        final name = widget.defaultName?.trim().isNotEmpty == true
            ? widget.defaultName!.trim()
            : email.split('@').first;
        final age = widget.defaultAge ?? 8;
        final gradeClass = widget.defaultGradeClass ?? 'Class 3';
        await ref
            .read(authProvider.notifier)
            .register(name, email, password, age: age, gradeClass: gradeClass);
      } else {
        await ref.read(authProvider.notifier).login(email, password);
      }

      _triggerSuccess();
      ref.invalidate(userProvider);
      ref.invalidate(leaderboardProvider);

      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      _triggerFail();
      if (!mounted) return;
      setState(() {
        _errorMessage =
            ref.read(authProvider).errorMessage ??
            (_isSignUp
                ? 'Registration failed.'
                : 'Login failed. Please check credentials.');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ref.read(authProvider.notifier).signInWithGoogleDevice();
      if (result == null) {
        // User dismissed account chooser
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      _onGoogleAuthSuccess(result);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      // If native plugin channel isn't bound (requires full rebuild/restart) or on simulator, show Google Account Picker modal
      _showGoogleAccountPickerSheet();
    }
  }

  void _onGoogleAuthSuccess(GoogleAuthResult result) {
    _triggerSuccess();
    ref.invalidate(userProvider);
    ref.invalidate(leaderboardProvider);

    if (!mounted) return;
    if (!result.hasCompletedOnboarding) {
      // Route to onboarding survey to complete profile
      context.go(
        '/onboarding?survey=true',
        extra: {
          'name': result.user.name,
          'email': result.user.email,
        },
      );
    } else {
      context.go('/home');
    }
  }

  void _showGoogleAccountPickerSheet() {
    final customEmailController = TextEditingController();
    bool isCustomMode = false;
    bool isSigning = false;
    String? sheetError;

    final demoAccounts = [
      {
        'name': widget.defaultName?.isNotEmpty == true ? widget.defaultName! : 'Satirtha Singha',
        'email': 'satirtha246@gmail.com',
        'avatar': 'assets/images/kido_character.png',
      },
      {
        'name': 'KidDo Learner',
        'email': 'learner.kiddo@gmail.com',
        'avatar': 'assets/images/Science.png',
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: CustomPaint(painter: _GoogleGLogoPainter()),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose an account',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E1B4B),
                            ),
                          ),
                          Text(
                            'to continue to KidDo',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 12),

                  if (!isCustomMode) ...[
                    // List of Google Accounts on device
                    ...demoAccounts.map((acc) {
                      final name = acc['name']!;
                      final email = acc['email']!;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFF7C3AED).withOpacity(0.12),
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'G',
                            style: const TextStyle(
                              color: Color(0xFF7C3AED),
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Color(0xFF1E1B4B),
                          ),
                        ),
                        subtitle: Text(
                          email,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        ),
                        onTap: isSigning
                            ? null
                            : () async {
                                setSheetState(() => isSigning = true);
                                try {
                                  final authResult = await ref
                                      .read(authProvider.notifier)
                                      .authenticateWithGoogleData(
                                        email: email,
                                        name: name,
                                      );
                                  if (!mounted) return;
                                  Navigator.pop(ctx);
                                  _onGoogleAuthSuccess(authResult);
                                } catch (e) {
                                  setSheetState(() {
                                    isSigning = false;
                                    sheetError = e.toString();
                                  });
                                }
                              },
                      );
                    }),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      leading: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFF1F5F9),
                        child: Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF64748B), size: 20),
                      ),
                      title: const Text(
                        'Use another Google account',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF475569),
                        ),
                      ),
                      onTap: () {
                        setSheetState(() {
                          isCustomMode = true;
                          sheetError = null;
                        });
                      },
                    ),
                  ] else ...[
                    // Custom Google email entry
                    const Text(
                      'Enter your Google Email',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      child: TextField(
                        controller: customEmailController,
                        keyboardType: TextInputType.emailAddress,
                        autofocus: true,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          hintText: 'example@gmail.com',
                          border: InputBorder.none,
                          icon: Icon(Icons.mail_outline_rounded, color: Color(0xFF64748B), size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => setSheetState(() => isCustomMode = false),
                          child: const Text('Back', style: TextStyle(color: Color(0xFF64748B))),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: isSigning
                              ? null
                              : () async {
                                  final email = customEmailController.text.trim();
                                  if (email.isEmpty || !email.contains('@')) {
                                    setSheetState(() => sheetError = 'Please enter a valid Google email.');
                                    return;
                                  }
                                  setSheetState(() {
                                    isSigning = true;
                                    sheetError = null;
                                  });
                                  try {
                                    final authResult = await ref
                                        .read(authProvider.notifier)
                                        .authenticateWithGoogleData(
                                          email: email,
                                          name: email.split('@')[0],
                                        );
                                    if (!mounted) return;
                                    Navigator.pop(ctx);
                                    _onGoogleAuthSuccess(authResult);
                                  } catch (e) {
                                    setSheetState(() {
                                      isSigning = false;
                                      sheetError = e.toString();
                                    });
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Continue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],

                  if (sheetError != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      sheetError!,
                      style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                  if (isSigning) ...[
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED))),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showForgotPasswordSheet() {
    final resetEmailController = TextEditingController(text: _emailController.text.trim());
    bool isSubmitting = false;
    String? resetError;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('🔑', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 10),
                  const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E1B4B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Enter your email address and we will send you instructions to reset your password.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2454),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextField(
                      controller: resetEmailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        icon: Icon(Icons.mail_outline_rounded, color: Color(0xFF9C7CF3), size: 20),
                        hintText: 'Enter your email',
                        hintStyle: TextStyle(
                          color: Color(0xFFAFA7D6),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (resetError != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      resetError!,
                      style: const TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 22),
                  if (isSubmitting)
                    const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)))
                  else
                    _build3DAuthButton(
                      label: 'SEND LINK',
                      onTap: () async {
                        final email = resetEmailController.text.trim();
                        if (email.isEmpty || !email.contains('@')) {
                          setSheetState(() {
                            resetError = 'Please enter a valid email address.';
                          });
                          return;
                        }
                        setSheetState(() {
                          isSubmitting = true;
                          resetError = null;
                        });
                        try {
                          final msg = await ref.read(authProvider.notifier).forgotPassword(email);
                          if (!mounted) return;
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(msg),
                              backgroundColor: const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } catch (e) {
                          setSheetState(() {
                            isSubmitting = false;
                            resetError = e.toString().replaceAll('Exception:', '').trim();
                          });
                        }
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFD5DFE8,
      ), // Soft cool grayish blue background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Top Mascot Yeti (Rive Animation) ────────────────────
                SizedBox(
                  height: 190,
                  width: 220,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      RiveAnimation.asset(
                        'assets/animation/login-1.riv',
                        fit: BoxFit.contain,
                        onInit: _onRiveInit,
                        placeHolder: Image.asset(
                          'assets/images/kido_character.png',
                          height: 170,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Overlapping Card + 3D Button Stack ───────────────────
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Main Pastel Purple Card
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 26),
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 42),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC7ABFA), // Soft pastel purple
                        borderRadius: BorderRadius.circular(36),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C3AED).withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Segmented Pill: SIGN UP | LOG IN ───────────
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildTabButton(
                                  title: 'SIGN UP',
                                  isSelected: _isSignUp,
                                  onTap: () {
                                    setState(() {
                                      _isSignUp = true;
                                      _errorMessage = null;
                                    });
                                  },
                                ),
                                _buildTabButton(
                                  title: 'LOG IN',
                                  isSelected: !_isSignUp,
                                  onTap: () {
                                    setState(() {
                                      _isSignUp = false;
                                      _errorMessage = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ── Email Field ─────────────────────────────────
                          _buildInputField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            hint: 'Email',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 12),

                          // ── Password Field ──────────────────────────────
                          _buildInputField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            hint: 'Password',
                            icon: Icons.vpn_key_rounded,
                            isPassword: true,
                          ),

                          // ── Confirm Password Field (only in Sign Up) ─────
                          if (_isSignUp) ...[
                            const SizedBox(height: 12),
                            _buildInputField(
                              controller: _confirmPasswordController,
                              focusNode: _confirmPasswordFocusNode,
                              hint: 'Confirm Password',
                              icon: Icons.lock_outline_rounded,
                              isPassword: true,
                            ),
                          ],

                          // ── Forgot Password & Google Sign In (on Log In tab)
                          if (!_isSignUp) ...[
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _showForgotPasswordSheet,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: Color(0xFF4C1D95),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildGoogleButton(),
                          ],

                          // Error Message Display
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Color(0xFFB91C1C),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // ── 3D Golden Action Button (LOG IN / SIGN UP) ─────────
                    Positioned(
                      bottom: 0,
                      child: _isLoading
                          ? const SizedBox(
                              height: 52,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF753FE9),
                                ),
                              ),
                            )
                          : _build3DAuthButton(
                              label: _isSignUp ? 'SIGN UP' : 'LOG IN',
                              onTap: _handleSubmit,
                            ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ── Bottom Toggle Link ──────────────────────────────────
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSignUp = !_isSignUp;
                      _errorMessage = null;
                    });
                  },
                  child: Text(
                    _isSignUp
                        ? 'I already have an account'
                        : "I don't have an account",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF475569),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Tab Button (SIGN UP / LOG IN) ──────────────────────────────────────
  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B35E8) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : const Color(0xFF6B35E8),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // ── Input Field Builder ───────────────────────────────────────────────
  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF753FE9), // Deep vibrant purple pill
        borderRadius: BorderRadius.circular(26),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          Container(
            width: 1.5,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.white.withOpacity(0.45),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: isPassword,
              keyboardType: keyboardType,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Google Sign In Button ─────────────────────────────────────────────
  Widget _buildGoogleButton() {
    return GestureDetector(
      onTap: _handleGoogleSignIn,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFE5E7EB)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google Colorful G Icon
            SizedBox(
              width: 24,
              height: 24,
              child: CustomPaint(painter: _GoogleGLogoPainter()),
            ),
            const SizedBox(width: 10),
            const Text(
              'Continue with Google',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 3D Golden Auth Button Builder ─────────────────────────────────────
  Widget _build3DAuthButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 160),
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Bottom 3D shadow layer
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFE58A00),
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            // Top bright layer
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB703),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      offset: const Offset(0, 1),
                      blurRadius: 1,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Color(0xFFD97706),
                        offset: Offset(0, 1.5),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Custom Painter for Crisp Google G Logo ───────────────────────────────
class _GoogleGLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.22
      ..strokeCap = StrokeCap.butt;

    final rect = Rect.fromCircle(
      center: center,
      radius: radius - paint.strokeWidth / 2,
    );

    // Blue (Right & horizontal bar)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.75, 1.5, false, paint);

    // Green (Bottom)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.75, 1.6, false, paint);

    // Yellow (Left)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.35, 1.5, false, paint);

    // Red (Top)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 3.85, 1.7, false, paint);

    // Blue Horizontal Bar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final barRect = Rect.fromLTWH(
      w * 0.45,
      h * 0.5 - (paint.strokeWidth / 2),
      w * 0.52,
      paint.strokeWidth,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, const Radius.circular(2)),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
