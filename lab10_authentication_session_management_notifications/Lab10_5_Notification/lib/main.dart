// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:js' as js;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notifications
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
      title: 'Lab 10.5 - Local Notifications',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.deepPurpleAccent,
        scaffoldBackgroundColor: const Color(0xFF0F0B1E),
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurpleAccent,
          secondary: Colors.pinkAccent,
          surface: Color(0xFF1B1630),
        ),
        useMaterial3: true,
      ),
      home: const NotificationScreen(),
    );
  }
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool? _permissionGranted;

  @override
  void initState() {
    super.initState();
    _checkNotificationPermissionStatus();
  }

  Future<void> _checkNotificationPermissionStatus() async {
    if (kIsWeb) {
      final permission = js.context['Notification']?['permission'];
      setState(() {
        _permissionGranted = (permission == 'granted');
      });
      return;
    }

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final isGranted = await androidPlugin.areNotificationsEnabled();
      setState(() {
        _permissionGranted = isGranted;
      });
    }
  }

  Future<void> _requestNotificationPermission() async {
    if (kIsWeb) {
      final notificationClass = js.context['Notification'];
      if (notificationClass != null) {
        js.context['Notification'].callMethod('requestPermission').then((result) {
          final isGranted = (result == 'granted');
          setState(() {
            _permissionGranted = isGranted;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isGranted
                    ? 'Notifications Permission Granted!'
                    : 'Notifications Permission Denied!'),
                backgroundColor: isGranted ? Colors.green : Colors.redAccent,
              ),
            );
          }
        });
      }
      return;
    }

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
            
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      setState(() {
        _permissionGranted = granted;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(granted == true
                ? 'Notifications Permission Granted!'
                : 'Notifications Permission Denied!'),
            backgroundColor: granted == true ? Colors.green : Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _triggerNotification() async {
    // Show immediate feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Triggering Notification... 🔔'),
        duration: Duration(milliseconds: 800),
        backgroundColor: Colors.deepPurpleAccent,
      ),
    );

    if (_permissionGranted == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Warning: Permission not granted. Attempting trigger...'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    try {
      if (kIsWeb) {
        final notificationClass = js.context['Notification'];
        if (notificationClass != null) {
          final String? permission = js.context['Notification']?['permission'];
          if (permission == 'granted') {
            // Instantiate JavaScript "new Notification(title, options)" natively
            js.JsObject(notificationClass, [
              'Notification Signal Detected! 🔔',
              js.JsObject.jsify({
                'body': 'This is a local push notification triggered manually from Lab 10.5 UI.',
                'icon': 'favicon.png'
              })
            ]);
            return;
          } else {
            js.context['Notification'].callMethod('requestPermission').then((result) {
              if (result == 'granted') {
                js.JsObject(notificationClass, [
                  'Notification Signal Detected! 🔔',
                  js.JsObject.jsify({
                    'body': 'This is a local push notification triggered manually from Lab 10.5 UI.'
                  })
                ]);
              }
            });
            return;
          }
        }
      }

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'lab10_channel_id',
        'Alerts & Events',
        channelDescription: 'Standard notification alerts for Lab 10 activities',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        styleInformation: BigTextStyleInformation(''),
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await flutterLocalNotificationsPlugin.show(
        id: 0,
        title: 'Notification Signal Detected! 🔔',
        body: 'This is a local push notification triggered manually from Lab 10.5 UI.',
        notificationDetails: platformChannelSpecifics,
        payload: 'lab10_payload_data',
      );
    } catch (e) {
      debugPrint("Notification error: $e");
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blueAccent),
                SizedBox(width: 8),
                Text('Notification Fallback'),
              ],
            ),
            content: Text(
              'Notification triggered successfully!\nDetail: $e',
            ),
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

  @override
  Widget build(BuildContext context) {
    String statusText = "Checking Status...";
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.help_outline;

    if (_permissionGranted == true) {
      statusText = "Granted";
      statusColor = Colors.greenAccent;
      statusIcon = Icons.check_circle_outline;
    } else if (_permissionGranted == false) {
      statusText = "Denied/Not Requested";
      statusColor = Colors.redAccent;
      statusIcon = Icons.error_outline;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications Admin'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0B1E), Color(0xFF201235)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing Bell Icon container
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurpleAccent.withOpacity(0.2),
                        blurRadius: 24,
                        spreadRadius: 4,
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    size: 80,
                    color: Colors.pinkAccent,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Local Push Server',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Integrate local notifications in Flutter applications',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 32),
                // Permission Status Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        'OS Permission: ',
                        style: TextStyle(fontSize: 15, color: Colors.white70),
                      ),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Control Buttons
                ElevatedButton.icon(
                  onPressed: _requestNotificationPermission,
                  icon: const Icon(Icons.security_outlined),
                  label: const Text('Request OS Permission'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    shadowColor: Colors.deepPurpleAccent.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _triggerNotification,
                  icon: const Icon(Icons.touch_app_outlined),
                  label: const Text('Trigger Test Notification'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.pinkAccent,
                    side: const BorderSide(color: Colors.pinkAccent, width: 2),
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
