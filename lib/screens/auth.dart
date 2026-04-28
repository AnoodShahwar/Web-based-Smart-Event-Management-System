import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'package:flutter/gestures.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  bool isLogin = true;
  bool isLoading = false;
  bool obscurePassword = true;
  int _currentSlide = 0;
  final AuthService _authService = AuthService();

  final List<String> _carouselImages = [
    'assets/14aug.jpeg',
    'assets/kubf.jpeg',
    'assets/conf.jpg',
    'assets/icisct.jpg',
    'assets/ubit.jpg',
  ];

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    String? error;
    if (isLogin) {
      error = await _authService.login(
        emailController.text,
        passwordController.text,
      );
    } else {
      error = await _authService.register(
        nameController.text,
        emailController.text,
        passwordController.text,
      );
    }
    setState(() => isLoading = false);
    if (error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red.shade600),
        );
      }
    } else {
      final user = _authService.currentUser;
      if (user != null && mounted) {
        final role = await _authService.getUserRole(user.uid);
        if (role == 'admin') {
          context.go('/admin');
        } else {
          context.go('/student');
        }
      }
    }
  }

  // Colors
  static const Color navyColor = Color(0xFF1A1A2E);
  static const Color goldColor = Color(0xFFFFD700);
  static const Color tealColor = Color(0xFF0D9488);
  static const Color warmWhite = Color(0xFFFFFEF5);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;
    return Scaffold(
      body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(flex: 55, child: _buildLeftPanel()),
        Expanded(flex: 45, child: _buildRightPanel()),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Container(
      color: navyColor,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildLogoRow(),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: warmWhite,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(24),
                child: _buildForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Carousel
        CarouselSlider(
          options: CarouselOptions(
            height: double.infinity,
            viewportFraction: 1.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 1000),
            autoPlayCurve: Curves.easeInOut,
            onPageChanged: (index, reason) =>
                setState(() => _currentSlide = index),
          ),
          items: _carouselImages.map((path) {
            return SizedBox.expand(
              child: Image.asset(
                path,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: navyColor),
              ),
            );
          }).toList(),
        ),

        // Dark overlay — stronger at bottom
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.35, 1.0],
              colors: [
                Colors.black.withOpacity(0.25),
                Colors.black.withOpacity(0.5),
                Colors.black.withOpacity(0.88),
              ],
            ),
          ),
        ),

        // Geometric accent circles
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: goldColor.withOpacity(0.12), width: 1),
            ),
          ),
        ),
        Positioned(
          top: -40,
          right: -40,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: goldColor.withOpacity(0.2), width: 1),
            ),
          ),
        ),

        // Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo row at top
                _buildLogoRow(),

                const Spacer(),

                // Tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: navyColor.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: goldColor.withOpacity(0.4)),
                  ),
                  child: const Text(
                    'Designed for University of Karachi',
                    style: TextStyle(
                      color: goldColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Big headline
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      fontFamily: 'Poppins',
                    ),
                    children: [
                      TextSpan(
                        text: 'Your campus,\n',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: 'your events.',
                        style: TextStyle(color: goldColor),
                      ),
                      TextSpan(
                        text: '\nAll in one place.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Description
                Text(
                  'Never miss a seminar, festival, or opportunity again.\nWSEMS connects every student to every event\nhappening across all 58+ departments.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.75),
                    height: 1.65,
                  ),
                ),
                const SizedBox(height: 20),

                // Stats row
                Row(
                  children: [
                    _statBox('58+', 'Departments'),
                    const SizedBox(width: 10),
                    _statBox('250+', 'Events/Year'),
                    const SizedBox(width: 10),
                    _statBox('2', 'User Roles'),
                  ],
                ),
                const SizedBox(height: 20),

                // Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip('Discover Events'),
                    _chip('Join & Participate'),
                    _chip('Volunteer'),
                    _chip('Suggest Ideas'),
                    _chip('Give Feedback'),
                  ],
                ),
                const SizedBox(height: 20),

                // Slide dots
                Row(
                  children: List.generate(
                    _carouselImages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 6),
                      width: _currentSlide == index ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentSlide == index
                            ? goldColor
                            : Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRightPanel() {
    return Container(
      color: warmWhite,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Column(
              children: [
                Text(
                  isLogin ? 'Welcome Back! 👋' : 'Join WSEMS 🎉',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: navyColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isLogin
                      ? 'Sign in to your account'
                      : 'Create your free account',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Name (register only)
          if (!isLogin) ...[
            _fieldLabel('Full Name'),
            const SizedBox(height: 8),
            TextFormField(
              controller: nameController,
              decoration: _inputDecoration(
                'Enter your full name',
                Icons.person_outline,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                if (value.trim().length < 3) {
                  return 'Name must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
          ],

          // Email
          _fieldLabel('Email'),
          const SizedBox(height: 8),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration(
              'Enter your email',
              Icons.email_outlined,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password
          _fieldLabel('Password'),
          const SizedBox(height: 8),
          TextFormField(
            controller: passwordController,
            obscureText: obscurePassword,
            decoration:
                _inputDecoration(
                  'Enter your password',
                  Icons.lock_outline,
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => obscurePassword = !obscurePassword),
                  ),
                ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),

          // Submit button — gold CTA
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: goldColor,
                foregroundColor: navyColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: navyColor)
                  : Text(
                      isLogin ? 'Sign In' : 'Create Account',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: navyColor,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),
          const SizedBox(height: 16),

          // Toggle
          Center(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13),
                children: [
                  TextSpan(
                    text: isLogin
                        ? "Don't have an account? "
                        : 'Already have an account? ',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  TextSpan(
                    text: isLogin ? 'Register' : 'Sign In',
                    style: const TextStyle(
                      color: tealColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        setState(() {
                          isLogin = !isLogin;
                          _formKey.currentState?.reset();
                        });
                      },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // LOGO
  Widget _buildLogoRow() {
    return Image.asset(
      'assets/wsems1.png',
      height: 80,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: goldColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.confirmation_number_rounded,
          color: navyColor,
          size: 22,
        ),
      ),
    );
  }

  // STAT BOX
  Widget _statBox(String number, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Column(
          children: [
            Text(
              number,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: goldColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.55),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // CHIP
  Widget _chip(String label, {bool gold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: gold
            ? goldColor.withOpacity(0.2)
            : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: gold
              ? goldColor.withOpacity(0.5)
              : Colors.white.withOpacity(0.15),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: gold ? goldColor : Colors.white.withOpacity(0.8),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // FIELD LABEL
  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: navyColor,
      ),
    );
  }

  // INPUT DECORATION
  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade700, fontSize: 13),
      prefixIcon: Icon(icon, color: tealColor, size: 20),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: tealColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
