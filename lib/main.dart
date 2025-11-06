import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const ShakeQuoteApp());
}

class ShakeQuoteApp extends StatelessWidget {
  const ShakeQuoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shake to Get a Quote',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  static const EventChannel _eventChannel = EventChannel(
    'com.example.shake/event',
  );

  late StreamSubscription<dynamic> _streamSub;
  final Random _rnd = Random();
  final List<String> quotes = [
    "Don't hesitate — failure is easier than regret.",
    "Every small step brings you closer to your goal.",
    "Success is not an accident; it’s the result of preparation and persistence.",
    "Learn something new today, even if it's small.",
    "Obstacles are what reveal our true strength.",
    "Start where you are, use what you have, do what you can.",
    "Focus creates greatness.",
  ];

  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  String? _currentQuote;
  bool _showQuote = false;
  int _lastShownTs = 0;
  final int _displayDebounceMs = 800;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );

    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _streamSub = _eventChannel.receiveBroadcastStream().listen(
      _onEvent,
      onError: _onError,
    );
  }

  void _onEvent(dynamic event) {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastShownTs < _displayDebounceMs) return;
    _lastShownTs = now;

    _showRandomQuote();
  }

  void _onError(dynamic error) {
    debugPrint('EventChannel error: $error');
  }

  void _showRandomQuote() {
    setState(() {
      _currentQuote = quotes[_rnd.nextInt(quotes.length)];
      _showQuote = true;
    });

    _animController.reset();
    _animController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showQuote = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _streamSub.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shake to Get a Quote')),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.vibration, size: 96),
                SizedBox(height: 16),
                Text(
                  'Shake your phone to get a motivational quote',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          if (_showQuote && _currentQuote != null)
            Positioned.fill(
              child: Center(
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnim.value,
                      child: Transform.scale(
                        scale: _scaleAnim.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade700.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 20,
                          offset: Offset(0, 10),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Text(
                      _currentQuote!,
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
