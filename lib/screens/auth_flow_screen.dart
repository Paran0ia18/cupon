import 'package:cupon/constants/app_colors.dart';
import 'package:cupon/services/auth_store.dart';
import 'package:flutter/material.dart';

class AuthFlowScreen extends StatefulWidget {
  const AuthFlowScreen({
    super.key,
    required this.authStore,
  });

  final AuthStore authStore;

  @override
  State<AuthFlowScreen> createState() => _AuthFlowScreenState();
}

class _AuthFlowScreenState extends State<AuthFlowScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final PageController _introController = PageController();

  int _step = 0;
  int _introIndex = 0;
  bool _submitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final wide = screenWidth > 920;

    return Scaffold(
      backgroundColor: AppColors.surfaceSoftNeutral,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 44,
              width: double.infinity,
              color: AppColors.warning,
              alignment: Alignment.center,
              child: const Text(
                'Local deals. Real shops. One-tap coupons.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: wide
                        ? Row(
                            children: [
                              Expanded(child: _buildBrandPanel()),
                              const SizedBox(width: 18),
                              SizedBox(width: 420, child: _buildAuthCard()),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 250, child: _buildBrandPanel()),
                              const SizedBox(height: 14),
                              _buildAuthCard(),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -18,
            bottom: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.violet.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kurukshetra\nLocal Dealz',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  height: 1.02,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Discover nearby offers and redeem instantly.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  _Tag(label: '60+ Brands'),
                  _Tag(label: '5 Coupons Each'),
                  _Tag(label: 'One Tap Redeem'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuthCard() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      child: switch (_step) {
        0 => _buildIntroCard(),
        1 => _buildLoginCard(),
        _ => _buildOtpCard(),
      },
    );
  }

  Widget _buildIntroCard() {
    final slides = [
      const _IntroSlide(
        icon: Icons.local_offer_rounded,
        title: 'Exclusive Coupons',
        text: 'Get fresh local deals from trusted businesses near you.',
      ),
      const _IntroSlide(
        icon: Icons.verified_rounded,
        title: 'Instant Redemption',
        text: 'Redeem in one tap and keep all your used coupons in profile.',
      ),
      const _IntroSlide(
        icon: Icons.search_rounded,
        title: 'Smart Discovery',
        text: 'Search brands fast and browse categories in seconds.',
      ),
    ];

    return _CardShell(
      title: 'Welcome',
      subtitle: 'Preview the app flow before login.',
      child: Column(
        children: [
          SizedBox(
            height: 190,
            child: PageView(
              controller: _introController,
              onPageChanged: (value) => setState(() => _introIndex = value),
              children: slides,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              slides.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _introIndex == index ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _introIndex == index
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _step = 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Start Login',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard() {
    return _CardShell(
      title: 'Login',
      subtitle: 'Use your mobile number to receive OTP.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mobile Number',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: '+91 9XXXXXXXXX',
              prefixIcon: const Icon(Icons.phone_rounded),
              filled: true,
              fillColor: AppColors.surfaceSoftNeutral,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _onRequestOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Send OTP',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => setState(() => _step = 0),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpCard() {
    return _CardShell(
      title: 'OTP Verification',
      subtitle: 'Enter the 4-digit code sent to your number.',
      child: Column(
        children: [
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              letterSpacing: 10,
              fontWeight: FontWeight.w800,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: '----',
              filled: true,
              fillColor: AppColors.surfaceSoftNeutral,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _onVerifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Verify & Continue',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => setState(() => _step = 1),
            child: const Text('Change Number'),
          ),
        ],
      ),
    );
  }

  Future<void> _onRequestOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 8) {
      _showMsg('Please enter a valid phone number.');
      return;
    }

    setState(() => _submitting = true);
    final otp = await widget.authStore.requestOtp(phone);
    if (!mounted) {
      return;
    }
    setState(() {
      _submitting = false;
      _step = 2;
    });
    _showMsg('Demo OTP: $otp');
  }

  Future<void> _onVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 4) {
      _showMsg('Enter the 4-digit OTP.');
      return;
    }

    setState(() => _submitting = true);
    final ok = await widget.authStore.verifyOtp(otp);
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    if (!ok) {
      _showMsg('Invalid OTP. Please try again.');
      return;
    }
    _showMsg('Login successful.');
  }

  void _showMsg(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey<String>(title),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dividerSoft),
        boxShadow: const [
          BoxShadow(
            color: Color(0x17000000),
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _IntroSlide extends StatelessWidget {
  const _IntroSlide({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoftBlue,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dividerSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 19,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
