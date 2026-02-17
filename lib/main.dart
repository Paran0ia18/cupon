import 'package:cupon/constants/app_colors.dart';
import 'package:cupon/models/brand.dart';
import 'package:cupon/screens/auth_flow_screen.dart';
import 'package:cupon/screens/main_shell.dart';
import 'package:cupon/screens/splash_screen.dart';
import 'package:cupon/services/auth_store.dart';
import 'package:cupon/services/brand_service.dart';
import 'package:cupon/services/redeem_store.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KurukshetraDemoApp());
}

class KurukshetraDemoApp extends StatelessWidget {
  const KurukshetraDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    const base = ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimary,
    );

    final textTheme = GoogleFonts.poppinsTextTheme();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kurukshetra Local Dealz',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.surfaceSoftNeutral,
        colorScheme: base,
        textTheme: textTheme,
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          titleTextStyle: textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: AppColors.dividerSoft,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceSoftBlue,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.dividerSoft),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.dividerSoft),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceSoftBlue,
          selectedColor: AppColors.primary.withValues(alpha: 0.18),
          disabledColor: AppColors.dividerSoft,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: const BorderSide(color: AppColors.dividerSoft),
          ),
          labelStyle: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          secondaryLabelStyle: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          type: BottomNavigationBarType.fixed,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.primary,
          contentTextStyle: textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const AppBootstrapScreen(),
    );
  }
}

class AppBootstrapScreen extends StatefulWidget {
  const AppBootstrapScreen({super.key});

  @override
  State<AppBootstrapScreen> createState() => _AppBootstrapScreenState();
}

class _AppBootstrapScreenState extends State<AppBootstrapScreen> {
  late Future<_BootstrapData> _bootstrapFuture;

  @override
  void initState() {
    super.initState();
    _bootstrapFuture = _bootstrap();
  }

  Future<_BootstrapData> _bootstrap() async {
    final brandService = BrandService();
    final redeemStore = RedeemStore();
    final authStore = AuthStore();

    final brandsFuture = brandService.loadBrands();
    final redeemFuture = redeemStore.load();
    final authFuture = authStore.load();

    await Future.wait<dynamic>([
      brandsFuture,
      redeemFuture,
      authFuture,
      Future<void>.delayed(const Duration(milliseconds: 1100)),
    ]);

    return _BootstrapData(
      brands: await brandsFuture,
      redeemStore: redeemStore,
      authStore: authStore,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_BootstrapData>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SplashScreen();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.secondary),
                    const SizedBox(height: 10),
                    const Text(
                      'No se pudieron cargar los datos.',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _bootstrapFuture = _bootstrap();
                        });
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        return _AppSessionGate(data: data);
      },
    );
  }
}

class _AppSessionGate extends StatelessWidget {
  const _AppSessionGate({required this.data});

  final _BootstrapData data;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: data.authStore,
      builder: (context, child) {
        if (!data.authStore.isLoggedIn) {
          return AuthFlowScreen(authStore: data.authStore);
        }

        return MainShell(
          brands: data.brands,
          redeemStore: data.redeemStore,
          authStore: data.authStore,
        );
      },
    );
  }
}

class _BootstrapData {
  const _BootstrapData({
    required this.brands,
    required this.redeemStore,
    required this.authStore,
  });

  final List<Brand> brands;
  final RedeemStore redeemStore;
  final AuthStore authStore;
}
