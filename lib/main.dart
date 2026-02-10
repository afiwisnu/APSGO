import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/landing_page.dart';
import 'screens/login_page.dart';
import 'theme/app_color.dart';
import 'services/history_logging_service.dart';
import 'services/kontrol_automation_service.dart';

void main() {
  // Start history logging service as soon as app starts
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App kembali ke foreground
        print('📱 App resumed - services will auto-start when needed');
        break;
      case AppLifecycleState.inactive:
        // App temporary inactive (misal: phone call)
        print('📱 App inactive');
        break;
      case AppLifecycleState.paused:
        // App di background, stop services untuk hemat battery
        print('📱 App paused - stopping background services');
        HistoryLoggingService().stop();
        KontrolAutomationService().stopAll();
        break;
      case AppLifecycleState.detached:
        // App akan di-terminate
        print('📱 App detaching - cleanup services');
        HistoryLoggingService().dispose();
        KontrolAutomationService().dispose();
        break;
      case AppLifecycleState.hidden:
        // App hidden (new in Flutter 3.13+)
        print('📱 App hidden');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ApsGo',
      theme: ThemeData(
        primaryColor: AppColor.primary,
        scaffoldBackgroundColor: AppColor.background,
        useMaterial3: true,
      ),
      home: const FirebaseInitializer(),
      routes: {'/login': (context) => const LoginPage()},
    );
  }
}

class FirebaseInitializer extends StatefulWidget {
  const FirebaseInitializer({super.key});

  @override
  State<FirebaseInitializer> createState() => _FirebaseInitializerState();
}

class _FirebaseInitializerState extends State<FirebaseInitializer> {
  bool _initialized = false;
  bool _error = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      setState(() {
        _initialized = true;
      });
      print('✅ Firebase initialized successfully');

      // Start history logging service after Firebase is initialized
      final loggingService = HistoryLoggingService();
      loggingService.start();
      print('✅ History logging service started');
    } on FirebaseException catch (e) {
      // Jika app sudah ada, anggap sudah initialized
      if (e.code == 'duplicate-app') {
        setState(() {
          _initialized = true;
        });
        print('✅ Firebase already initialized');

        // Start logging service
        final loggingService = HistoryLoggingService();
        loggingService.start();
        print('✅ History logging service started');
      } else {
        setState(() {
          _error = true;
          _errorMessage = e.message ?? e.toString();
        });
        print('❌ Firebase initialization error: $e');
      }
    } catch (e) {
      setState(() {
        _error = true;
        _errorMessage = e.toString();
      });
      print('❌ Firebase initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 24),
                const Text(
                  'Error Initializing Firebase',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = false;
                      _initialized = false;
                    });
                    _initializeFirebase();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_initialized) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
              ),
              const SizedBox(height: 24),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColor.textDark.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const LandingPage();
  }
}
