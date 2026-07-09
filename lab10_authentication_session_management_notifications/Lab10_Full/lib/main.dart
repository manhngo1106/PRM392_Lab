// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:js' as js;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Global configurations
bool isFirebaseReady = false;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Mock user state for simulation when Firebase is missing
final MockUserState mockUserState = MockUserState();

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

  // 1. Initialize Firebase if possible
  try {
    await Firebase.initializeApp();
    isFirebaseReady = true;
    await GoogleSignIn.instance.initialize();
  } catch (e) {
    debugPrint("Firebase Core Initialization failed (Running in Mock Mode): $e");
    isFirebaseReady = false;
  }

  // 2. Initialize Local Notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      debugPrint("Notification clicked: ${response.payload}");
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 10 - Integrated Solution',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.indigoAccent,
        scaffoldBackgroundColor: const Color(0xFF0F101E),
        colorScheme: const ColorScheme.dark(
          primary: Colors.indigoAccent,
          secondary: Colors.pinkAccent,
          surface: Color(0xFF191A2E),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// ----------------------------------------------------
// SPLASH ROUTER
// ----------------------------------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkActiveSessions();
  }

  void _checkActiveSessions() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // A. Check Firebase session
    if (isFirebaseReady) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(provider: "Firebase Google"),
          ),
        );
        return;
      }
    }

    // B. Check SharedPreferences API Session
    final prefs = await SharedPreferences.getInstance();
    final apiToken = prefs.getString('token');
    
    if (!mounted) return;

    if (apiToken != null && apiToken.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(provider: "DummyJSON API"),
        ),
      );
      return;
    }

    // C. Otherwise, go to login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F101E), Color(0xFF1A173A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.indigoAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_outlined, size: 80, color: Colors.indigoAccent),
              ),
              const SizedBox(height: 24),
              const Text(
                'AUTHENTICATOR',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lab 10 Integrated Session Manager',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.indigoAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// LOGIN SCREEN (Standard API & Firebase Google)
// ----------------------------------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Request notifications permission and fire login success alert
  Future<void> _triggerLoginSuccessNotification(String name, String method) async {
    try {
      if (kIsWeb) {
        final notificationClass = js.context['Notification'];
        if (notificationClass != null) {
          final String? permission = js.context['Notification']?['permission'];
          if (permission == 'granted') {
            js.JsObject(notificationClass, [
              'Login Successful! 🔐',
              js.JsObject.jsify({
                'body': 'Welcome back, $name! Authenticated via $method.',
                'icon': 'favicon.png'
              })
            ]);
            return;
          } else {
            js.context['Notification'].callMethod('requestPermission').then((result) {
              if (result == 'granted') {
                js.JsObject(notificationClass, [
                  'Login Successful! 🔐',
                  js.JsObject.jsify({
                    'body': 'Welcome back, $name! Authenticated via $method.'
                  })
                ]);
              }
            });
            return;
          }
        }
      }

      // Request permission (Android 13+)
      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'lab10_full_channel_id',
        'Session Security Alerts',
        channelDescription: 'Alerts you about recent logins',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        id: 100,
        title: 'Login Successful! 🔐',
        body: 'Welcome back, $name! Authenticated via $method.',
        notificationDetails: platformDetails,
        payload: 'lab10_full_payload',
      );
    } catch (e) {
      debugPrint("Notification success trigger failed: $e");
    }
  }

  void _handleCredentialLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('https://dummyjson.com/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', responseData['accessToken'] ?? '');
        await prefs.setString('username', responseData['username'] ?? '');
        await prefs.setString('email', responseData['email'] ?? '');
        await prefs.setString('firstName', responseData['firstName'] ?? '');
        await prefs.setString('lastName', responseData['lastName'] ?? '');
        await prefs.setString('image', responseData['image'] ?? '');

        final String userFullName = '${responseData['firstName']} ${responseData['lastName']}';
        
        // Trigger notification
        await _triggerLoginSuccessNotification(userFullName, "DummyJSON REST API");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login successful! Welcome $userFullName.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(provider: "DummyJSON API"),
            ),
          );
        }
      } else {
        final errorMessage = responseData['message'] ?? 'Authentication failed';
        if (mounted) {
          _showErrorDialog("Credential Error", errorMessage);
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        _showErrorDialog("Network Error", "Unable to connect to the server.");
      }
    }
  }

  void _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
    });

    if (isFirebaseReady) {
      try {
        final googleUser = await GoogleSignIn.instance.authenticate();
        final GoogleSignInAuthentication googleAuth = googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        final UserCredential firebaseUserCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        
        final user = firebaseUserCredential.user;
        final String displayName = user?.displayName ?? "Google User";

        // Trigger notification
        await _triggerLoginSuccessNotification(displayName, "Firebase Google Auth");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Google login successful! Welcome $displayName.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(provider: "Firebase Google"),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog("Google Authentication Failure", e.toString());
        }
      } finally {
        if (mounted) {
          setState(() {
            _isGoogleLoading = false;
          });
        }
      }
    } else {
      // Simulate Google Sign-in
      await Future.delayed(const Duration(milliseconds: 1500));
      mockUserState.loginSimulated();
      
      // Trigger notification
      await _triggerLoginSuccessNotification(mockUserState.displayName, "Simulated Google Auth");

      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Simulated Google login successful! Welcome ${mockUserState.displayName}.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(provider: "Simulated Google"),
          ),
        );
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.pinkAccent),
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
            colors: [Color(0xFF0F101E), Color(0xFF1E1735)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            if (!isFirebaseReady)
              SafeArea(
                child: Container(
                  width: double.infinity,
                  color: Colors.amber.withOpacity(0.9),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.black, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mock Mode: Firebase credentials missing. Simulated Google Sign-In active.',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.indigoAccent.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_outlined,
                            size: 64,
                            color: Colors.indigoAccent,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Welcome to Lab10',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Integrated Portal: REST API & Google Auth',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.06)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  labelText: 'API Username',
                                  prefixIcon: const Icon(Icons.person_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter username';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'API Password',
                                  prefixIcon: const Icon(Icons.lock_outlined),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter password';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _isLoading ? null : _handleCredentialLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigoAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'API Log In',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                              ),
                              const SizedBox(height: 16),
                              const Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.white12)),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('OR', style: TextStyle(color: Colors.white30, fontSize: 12)),
                                  ),
                                  Expanded(child: Divider(color: Colors.white12)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                                icon: _isGoogleLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.pinkAccent,
                                        ),
                                      )
                                    : const Icon(Icons.login),
                                label: Text(
                                  isFirebaseReady
                                      ? 'Sign in with Google'
                                      : 'Simulate Google Account',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.pinkAccent,
                                  side: const BorderSide(color: Colors.pinkAccent),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
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
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// HOME DASHBOARD
// ----------------------------------------------------
class HomeScreen extends StatefulWidget {
  final String provider;

  const HomeScreen({super.key, required this.provider});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _displayName = '';
  String _username = '';
  String _email = '';
  String _photoUrl = '';
  String _sessionToken = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }

  void _loadUserSession() async {
    if (widget.provider == "DummyJSON API") {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _displayName = '${prefs.getString('firstName') ?? ''} ${prefs.getString('lastName') ?? ''}';
        _username = prefs.getString('username') ?? '';
        _email = prefs.getString('email') ?? '';
        _photoUrl = prefs.getString('image') ?? '';
        _sessionToken = prefs.getString('token') ?? '';
        _isLoading = false;
      });
    } else if (widget.provider == "Firebase Google") {
      final user = FirebaseAuth.instance.currentUser;
      setState(() {
        _displayName = user?.displayName ?? 'Google User';
        _username = 'google_provider';
        _email = user?.email ?? '';
        _photoUrl = user?.photoURL ?? '';
        _sessionToken = user?.uid ?? 'No UID retrieved';
        _isLoading = false;
      });
    } else {
      // Simulated Google
      setState(() {
        _displayName = mockUserState.displayName;
        _username = 'simulated_provider';
        _email = mockUserState.email;
        _photoUrl = mockUserState.photoUrl;
        _sessionToken = "mock-uuid-firebase-credentials-123456";
        _isLoading = false;
      });
    }
  }

  void _handleLogout() async {
    setState(() {
      _isLoading = true;
    });

    if (widget.provider == "DummyJSON API") {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } else if (widget.provider == "Firebase Google") {
      try {
        await GoogleSignIn.instance.signOut();
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        debugPrint("Google Sign out failed: $e");
      }
    } else {
      mockUserState.logoutSimulated();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged out of ${widget.provider} session successfully.'),
          backgroundColor: Colors.pinkAccent,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F101E), Color(0xFF1E1735)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (widget.provider == "Simulated Google")
                Container(
                  width: double.infinity,
                  color: Colors.amber.withOpacity(0.9),
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: const Center(
                    child: Text(
                      'Running in Simulated Firebase Session',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
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
                          'Integrated Portal',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.indigoAccent.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 54,
                                backgroundColor: Colors.indigoAccent.withOpacity(0.1),
                                backgroundImage: _photoUrl.isNotEmpty ? NetworkImage(_photoUrl) : null,
                                child: _photoUrl.isEmpty
                                    ? const Icon(Icons.person, size: 54, color: Colors.white24)
                                    : null,
                                onBackgroundImageError: (exception, stackTrace) {},
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _displayName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.indigoAccent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Provider: ${widget.provider}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigoAccent,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Divider(color: Colors.white10),
                              const SizedBox(height: 16),
                              _buildProfileRow(Icons.email_outlined, 'Email Address', _email),
                              const SizedBox(height: 16),
                              _buildProfileRow(Icons.account_circle_outlined, 'Provider ID / Username', '@$_username'),
                              const SizedBox(height: 16),
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Session Token / UID:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                height: 75,
                                width: double.infinity,
                                child: SingleChildScrollView(
                                  child: SelectableText(
                                    _sessionToken,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      color: Colors.pinkAccent,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton.icon(
                                onPressed: _handleLogout,
                                icon: const Icon(Icons.power_settings_new),
                                label: const Text('End Session & Logout'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pinkAccent.withOpacity(0.1),
                                  foregroundColor: Colors.pinkAccent,
                                  side: const BorderSide(color: Colors.pinkAccent),
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

  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white38),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}
