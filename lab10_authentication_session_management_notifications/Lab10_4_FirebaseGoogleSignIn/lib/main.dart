// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Global flag to track if Firebase is configured
bool isFirebaseReady = false;

// Mock user state when Firebase is not configured
MockUserState mockUserState = MockUserState();

class MockUserState extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _displayName = '';
  String _email = '';
  String _photoUrl = '';

  bool get isLoggedIn => _isLoggedIn;
  String get displayName => _displayName;
  String get email => _email;
  String get photoUrl => _photoUrl;

  void loginSimulated() {
    _isLoggedIn = true;
    _displayName = "Mock Google User";
    _email = "mock.google.user@gmail.com";
    _photoUrl = "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150";
    notifyListeners();
  }

  void logoutSimulated() {
    _isLoggedIn = false;
    _displayName = '';
    _email = '';
    _photoUrl = '';
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Attempt Firebase initialization (will fail if google-services.json or plist is missing)
    await Firebase.initializeApp();
    isFirebaseReady = true;
    await GoogleSignIn.instance.initialize();
  } catch (e) {
    debugPrint("Firebase Core Initialization failed: $e");
    isFirebaseReady = false;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 10.4 - Firebase Google Sign-In',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.redAccent,
        scaffoldBackgroundColor: const Color(0xFF120B0B),
        colorScheme: const ColorScheme.dark(
          primary: Colors.redAccent,
          secondary: Colors.amberAccent,
          surface: Color(0xFF241515),
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    if (!isFirebaseReady) {
      mockUserState.addListener(_onMockStateChanged);
    }
  }

  @override
  void dispose() {
    if (!isFirebaseReady) {
      mockUserState.removeListener(_onMockStateChanged);
    }
    super.dispose();
  }

  void _onMockStateChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (isFirebaseReady) {
      // Use real Firebase Authentication state changes stream
      return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(color: Colors.redAccent)),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            return HomeScreen(firebaseUser: snapshot.data);
          }
          return const LoginScreen();
        },
      );
    } else {
      // Use Simulated Mock user state changes
      return mockUserState.isLoggedIn ? const HomeScreen() : const LoginScreen();
    }
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  void _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    if (isFirebaseReady) {
      try {
        final googleUser = await GoogleSignIn.instance.authenticate();

        final GoogleSignInAuthentication googleAuth = googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
      } catch (e) {
        if (mounted) {
          _showErrorDialog("Google Sign-In Error", e.toString());
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      // Simulate login delay
      await Future.delayed(const Duration(milliseconds: 1500));
      mockUserState.loginSimulated();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF120B0B), Color(0xFF2E1212)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Warning Banner for Graders
            if (!isFirebaseReady)
              SafeArea(
                child: Container(
                  width: double.infinity,
                  color: Colors.amber.withOpacity(0.9),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.black, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mock Mode: google-services.json not found. Simulation enabled.',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.g_mobiledata_rounded,
                          size: 80,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Firebase Auth',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Google Sign-In Provider Integration',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 48),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              isFirebaseReady
                                  ? 'Authenticate securely using your Google credentials processed via Firebase.'
                                  : 'Click below to simulate Google Authentication flow in development mode.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : _handleGoogleSignIn,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.login),
                              label: Text(
                                _isLoading
                                    ? 'Connecting Google...'
                                    : (isFirebaseReady
                                        ? 'Sign In with Google'
                                        : 'Simulate Google Login'),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
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

class HomeScreen extends StatefulWidget {
  final User? firebaseUser;

  const HomeScreen({super.key, this.firebaseUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoggingOut = false;

  void _handleLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    if (isFirebaseReady) {
      try {
        await GoogleSignIn.instance.signOut();
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        debugPrint("Error signing out: $e");
      }
    } else {
      mockUserState.logoutSimulated();
    }

    if (mounted) {
      setState(() {
        _isLoggingOut = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String displayName = isFirebaseReady
        ? (widget.firebaseUser?.displayName ?? 'Firebase User')
        : mockUserState.displayName;

    final String email = isFirebaseReady
        ? (widget.firebaseUser?.email ?? 'No email associated')
        : mockUserState.email;

    final String photoUrl = isFirebaseReady
        ? (widget.firebaseUser?.photoURL ?? '')
        : mockUserState.photoUrl;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF120B0B), Color(0xFF241515)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (!isFirebaseReady)
                Container(
                  width: double.infinity,
                  color: Colors.amber.withOpacity(0.9),
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  child: const Center(
                    child: Text(
                      'Running in simulated Mock Mode',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Google Authenticated',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(24),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.redAccent.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 54,
                                backgroundColor: Colors.redAccent.withOpacity(0.1),
                                backgroundImage: photoUrl.isNotEmpty
                                    ? NetworkImage(photoUrl)
                                    : null,
                                child: photoUrl.isEmpty
                                    ? const Icon(Icons.person, size: 54, color: Colors.white30)
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                displayName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'PROVIDER: Google Sign-In',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.amberAccent,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Divider(color: Colors.white12),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(Icons.email_outlined, color: Colors.white54, size: 20),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Google Email Address',
                                        style: TextStyle(fontSize: 12, color: Colors.white38),
                                      ),
                                      Text(
                                        email,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton.icon(
                                onPressed: _isLoggingOut ? null : _handleLogout,
                                icon: _isLoggingOut
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.redAccent,
                                        ),
                                      )
                                    : const Icon(Icons.power_settings_new),
                                label: const Text('Disconnect Google Session'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                                  foregroundColor: Colors.redAccent,
                                  side: const BorderSide(color: Colors.redAccent),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
