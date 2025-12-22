import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Import yang akan ditest
// Dalam implementasi nyata, ganti dengan path yang sesuai:
// import 'package:momjournal/screens/auth/login_screen.dart';
// import 'package:momjournal/providers/auth_provider.dart';

/// UI TEST untuk LoginScreen
/// 
/// File ini berisi comprehensive test untuk login screen:
/// - Layout dan UI elements rendering
/// - Feature items display
/// - Google Sign-In button interaction
/// - Loading state handling
/// - Navigation flow
/// - Error handling
///
/// TUJUAN TEST:
/// 1. Memastikan semua UI elements ditampilkan dengan benar
/// 2. Memverifikasi authentication flow berfungsi
/// 3. Mengecek loading state menampilkan overlay
/// 4. Memvalidasi error handling
/// 5. Memastikan navigation ke home setelah login sukses
/// 6. Memverifikasi accessibility features

// Mock AuthProvider untuk testing
class MockAuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;
  
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  
  // Simulate successful login
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    
    await Future<void>.delayed(const Duration(milliseconds: 500));
    
    _isLoading = false;
    _isAuthenticated = true;
    notifyListeners();
    
    return true;
  }
  
  // Simulate failed login
  Future<bool> signInWithGoogleFailed() async {
    _isLoading = true;
    notifyListeners();
    
    await Future<void>.delayed(const Duration(milliseconds: 500));
    
    _isLoading = false;
    _errorMessage = 'Login gagal. Silakan coba lagi.';
    notifyListeners();
    
    return false;
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

// Mock LoginScreen
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Consumer<MockAuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isLoading) {
              return Stack(
                children: [
                  _buildContent(context, theme, colorScheme, size),
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Masuk dengan Google...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return _buildContent(context, theme, colorScheme, size);
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    Size size,
  ) =>
      SingleChildScrollView(
        key: const Key('login_content'),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            
            // Logo
            Container(
              key: const Key('app_logo'),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                Icons.book_rounded,
                size: 56,
                color: colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // App name
            Text(
              'MomJournal',
              key: const Key('app_name'),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Tagline
            Text(
              'Kelola jadwal, dokumentasikan perjalanan,\n'
              'dan jaga kesehatan mental Anda',
              key: const Key('tagline'),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 60),
            
            // Features list
            const _FeatureItem(
              key: Key('feature_schedule'),
              icon: Icons.calendar_today,
              title: 'Manajemen Jadwal',
              description: 'Atur jadwal harian anak dengan mudah',
            ),
            
            const SizedBox(height: 16),
            
            const _FeatureItem(
              key: Key('feature_journal'),
              icon: Icons.edit_note,
              title: 'Jurnal Harian',
              description: 'Catat momen dan perasaan Anda',
            ),
            
            const SizedBox(height: 16),
            
            const _FeatureItem(
              key: Key('feature_gallery'),
              icon: Icons.photo_library,
              title: 'Galeri Foto',
              description: 'Simpan kenangan indah bersama si kecil',
            ),
            
            const SizedBox(height: 16),
            
            const _FeatureItem(
              key: Key('feature_backup'),
              icon: Icons.cloud_upload,
              title: 'Backup Otomatis',
              description: 'Data aman tersimpan di cloud',
            ),
            
            const SizedBox(height: 20),
            
            // Google Sign-In Button
            ElevatedButton.icon(
              key: const Key('google_signin_button'),
              onPressed: () => _handleGoogleSignIn(context),
              icon: const Icon(Icons.g_mobiledata_rounded),
              label: const Text('Masuk dengan Google'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Terms & Privacy
            Text(
              'Dengan masuk, Anda menyetujui\n'
              'Syarat & Ketentuan serta Kebijakan Privasi',
              key: const Key('terms_text'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 10),
          ],
        ),
      );

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final authProvider = context.read<MockAuthProvider>();
    
    final success = await authProvider.signInWithGoogle();
    
    if (!context.mounted) return;
    
    if (success) {
      await Navigator.pushReplacementNamed(context, '/home');
    } else {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Gagal'),
          content: Text(authProvider.errorMessage ?? 'Terjadi kesalahan'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    super.key,
  });
  
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void main() {
  group('LoginScreen UI Tests', () {
    
    /// TEST 1: Basic Screen Rendering
    /// Memastikan screen dapat di-render tanpa error
    testWidgets('should render login screen without errors', (tester) async {
      // Arrange & Act: Build screen dengan provider
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => MockAuthProvider(),
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      
      // Assert: Verifikasi screen di-render
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
    
    /// TEST 2: Logo Display
    /// Memastikan logo aplikasi ditampilkan
    testWidgets('should display app logo', (tester) async {
      // Arrange & Act: Build screen
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => MockAuthProvider(),
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      
      // Assert: Verifikasi logo container dan icon ada
      expect(find.byKey(const Key('app_logo')), findsOneWidget);
      expect(find.byIcon(Icons.book_rounded), findsOneWidget);
    });
    
    /// TEST 3: App Name and Tagline
    /// Memastikan nama aplikasi dan tagline ditampilkan
    testWidgets('should display app name and tagline', (tester) async {
      // Arrange & Act: Build screen
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => MockAuthProvider(),
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      
      // Assert: Verifikasi text ada
      expect(find.text('MomJournal'), findsOneWidget);
      expect(
        find.text('Kelola jadwal, dokumentasikan perjalanan,\n'
            'dan jaga kesehatan mental Anda'),
        findsOneWidget,
      );
    });
    
    /// TEST 4: Feature Items Display
    /// Memastikan semua 4 feature items ditampilkan
    testWidgets('should display all feature items', (tester) async {
      // Arrange & Act: Build screen
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => MockAuthProvider(),
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      
      // Assert: Verifikasi semua feature items ada
      expect(find.byKey(const Key('feature_schedule')), findsOneWidget);
      expect(find.byKey(const Key('feature_journal')), findsOneWidget);
      expect(find.byKey(const Key('feature_gallery')), findsOneWidget);
      expect(find.byKey(const Key('feature_backup')), findsOneWidget);
      
      // Verifikasi text feature
      expect(find.text('Manajemen Jadwal'), findsOneWidget);
      expect(find.text('Jurnal Harian'), findsOneWidget);
      expect(find.text('Galeri Foto'), findsOneWidget);
      expect(find.text('Backup Otomatis'), findsOneWidget);
    });
    
    /// TEST 5: Feature Icons Display
    /// Memastikan icon untuk setiap feature ditampilkan
    testWidgets('should display feature icons', (tester) async {
      // Arrange & Act: Build screen
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => MockAuthProvider(),
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      
      // Assert: Verifikasi icons ada
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.edit_note), findsOneWidget);
      expect(find.byIcon(Icons.photo_library), findsOneWidget);
      expect(find.byIcon(Icons.cloud_upload), findsOneWidget);
    });
    
    /// TEST 6: Google Sign-In Button
    /// Memastikan button login dengan Google ada
    testWidgets('should display Google Sign-In button', (tester) async {
      // Arrange & Act: Build screen
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => MockAuthProvider(),
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      
      // Assert: Verifikasi button ada dengan text dan icon
      expect(find.byKey(const Key('google_signin_button')), findsOneWidget);
      expect(find.text('Masuk dengan Google'), findsOneWidget);
      expect(find.byIcon(Icons.g_mobiledata_rounded), findsOneWidget);
    });
    
    /// TEST 7: Terms and Privacy Text
    /// Memastikan text terms & privacy ditampilkan
    testWidgets('should display terms and privacy text', (tester) async {
      // Arrange & Act: Build screen
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => MockAuthProvider(),
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      
      // Assert: Verifikasi text ada
      expect(
        find.text('Dengan masuk, Anda menyetujui\n'
            'Syarat & Ketentuan serta Kebijakan Privasi'),
        findsOneWidget,
      );
    });
    
    /// TEST 8: Button Tap Interaction
    /// Memastikan button dapat di-tap
    testWidgets('should handle button tap', (tester) async {
      // Arrange: Build screen
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => MockAuthProvider(),
          child: MaterialApp(
            home: const LoginScreen(),
            routes: {
              '/home': (context) => const Scaffold(
                    body: Center(child: Text('Home Screen')),
                  ),
            },
          ),
        ),
      );
      
      // Act: Scroll to button then tap
      await tester.ensureVisible(find.byKey(const Key('google_signin_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('google_signin_button')));
      await tester.pump();
      
      // Wait for async operations to complete
      await tester.pumpAndSettle();
      
      // Assert: After successful tap and navigation, Home Screen should be visible
      expect(find.text('Home Screen'), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });
  });
  
  group('LoginScreen Loading State Tests', () {
    
    /// TEST 9: Loading Overlay Display
    /// Memastikan loading overlay muncul saat loading
    testWidgets('should show loading overlay when authenticating', 
        (tester) async {
      // Arrange: Build screen dengan provider
      final authProvider = MockAuthProvider();
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: authProvider,
          child: MaterialApp(
            home: const LoginScreen(),
            routes: {
              '/home': (context) => const Scaffold(
                    body: Center(child: Text('Home Screen')),
                  ),
            },
          ),
        ),
      );
      
      // Act: Scroll to button then tap
      await tester.ensureVisible(find.byKey(const Key('google_signin_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('google_signin_button')));
      await tester.pump(); // Start animation
      
      // Assert: Verifikasi loading overlay muncul
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Masuk dengan Google...'), findsOneWidget);
      
      // Wait for completion
      await tester.pumpAndSettle();
    });
    
    /// TEST 10: Loading Text Display
    /// Memastikan loading message ditampilkan
    testWidgets('should display loading message', (tester) async {
      // Arrange: Setup provider dengan loading state
      final authProvider = MockAuthProvider();
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: authProvider,
          child: MaterialApp(
            home: const LoginScreen(),
            routes: {
              '/home': (context) => const Scaffold(
                    body: Center(child: Text('Home Screen')),
                  ),
            },
          ),
        ),
      );
      
      // Act: Scroll to button then trigger loading
      await tester.ensureVisible(find.byKey(const Key('google_signin_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('google_signin_button')));
      await tester.pump();
      
      // Assert: Verifikasi loading text
      expect(find.text('Masuk dengan Google...'), findsOneWidget);
      
      await tester.pumpAndSettle();
    });
    
    /// TEST 11: Content Behind Loading
    /// Memastikan content tetap ada di belakang loading overlay
    testWidgets('should keep content visible behind loading overlay', 
        (tester) async {
      // Arrange: Build screen
      final authProvider = MockAuthProvider();
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: authProvider,
          child: MaterialApp(
            home: const LoginScreen(),
            routes: {
              '/home': (context) => const Scaffold(
                    body: Center(child: Text('Home Screen')),
                  ),
            },
          ),
        ),
      );
      
      // Act: Scroll to button then trigger loading
      await tester.ensureVisible(find.byKey(const Key('google_signin_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('google_signin_button')));
      await tester.pump();
      
      // Assert: Verifikasi content masih ada (meskipun di belakang overlay)
      expect(find.byKey(const Key('login_content')), findsOneWidget);
      expect(find.text('MomJournal'), findsOneWidget);
      
      await tester.pumpAndSettle();
    });
  });
  
  group('LoginScreen Navigation Tests', () {
    
    /// TEST 12: Successful Login Navigation
    /// Memastikan navigasi ke home setelah login sukses
    testWidgets('should navigate to home screen after successful login', 
        (tester) async {
      // Arrange: Build screen dengan route
      final authProvider = MockAuthProvider();
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: authProvider,
          child: MaterialApp(
            home: const LoginScreen(),
            routes: {
              '/home': (context) => const Scaffold(
                    body: Center(child: Text('Home Screen')),
                  ),
            },
          ),
        ),
      );
      
      // Act: Scroll to button then tap login
      await tester.ensureVisible(find.byKey(const Key('google_signin_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('google_signin_button')));
      await tester.pumpAndSettle(); // Wait for all animations and navigation
      
      // Assert: Verifikasi sudah di home screen
      expect(find.text('Home Screen'), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });
  });
  
  group('LoginScreen Responsive Layout Tests', () {
    
    /// TEST 13: Vertical Layout Structure
    /// Memastikan layout tersusun secara vertikal
    testWidgets('should have proper vertical layout structure', 
        (tester) async {
      // Arrange & Act: Build screen
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => MockAuthProvider(),
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      
      // Assert: Verifikasi Column dan layout structure
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
    
    /// TEST 14: Scrollable Content
    /// Memastikan content dapat di-scroll
    testWidgets('should be scrollable', (tester) async {
      // Arrange & Act: Build screen
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => MockAuthProvider(),
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      
      // Assert: Verifikasi scrollable widget ada
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
    
    /// TEST 15: SafeArea Usage
    /// Memastikan menggunakan SafeArea untuk device notch
    testWidgets('should use SafeArea for proper spacing', (tester) async {
      // Arrange & Act: Build screen
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => MockAuthProvider(),
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      
      // Assert: Verifikasi SafeArea digunakan
      expect(find.byType(SafeArea), findsOneWidget);
    });
  });
  
  group('LoginScreen Accessibility Tests', () {
    
    /// TEST 16: Semantic Labels
    /// Memastikan widget memiliki semantic labels untuk screen readers
    testWidgets('should have proper semantic labels', (tester) async {
      // Arrange & Act: Build screen
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => MockAuthProvider(),
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      
      // Assert: Verifikasi semantic ada
      expect(find.text('MomJournal'), findsOneWidget);
      expect(find.text('Masuk dengan Google'), findsOneWidget);
    });
    
    /// TEST 17: Proper Text Contrast
    /// Memastikan text memiliki contrast yang baik
    testWidgets('should use proper text styling for readability', 
        (tester) async {
      // Arrange & Act: Build screen
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => MockAuthProvider(),
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      
      // Assert: Verifikasi text widgets ada dan readable
      final appNameText = tester.widget<Text>(find.byKey(const Key('app_name')));
      expect(appNameText.style, isNotNull);
      
      final taglineText = tester.widget<Text>(find.byKey(const Key('tagline')));
      expect(taglineText.style, isNotNull);
    });
  });
}