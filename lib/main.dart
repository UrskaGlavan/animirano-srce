import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const FadingScreen(),
    );
  }
}

class FadingScreen extends StatefulWidget {
  const FadingScreen({super.key});

  @override
  State<FadingScreen> createState() => _FadingScreenState();
}

class _FadingScreenState extends State<FadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _heartController;
  late Animation<double> _heartSizeAnimation;

  late AnimationController _glitterController; // Controller za bleščice
  List<Offset> _glitterPositions = [];
  final Random _random = Random();
  bool _vidno = true;

  @override
  void initState() {
    super.initState();

    // Srce animacija
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _heartSizeAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
    );

    _heartController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _vidno = false; // Srce izgine
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            _vidno = true; // Srce se ponovno prikaže
          });
          _heartController
              .reverse(); // Srce se zmanjša nazaj na začetno velikost
        });
      }
    });

    // Bleščice animacija
    _glitterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        _updateGlitterPositions();
      });

    _glitterPositions = List.generate(
      30,
      (_) => Offset(
        _random.nextDouble() *
            MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                .size
                .width,
        _random.nextDouble() *
            MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                .size
                .height,
      ),
    );

    _glitterController.repeat(); // Bleščice animacija teče ves čas
  }

  @override
  void dispose() {
    _heartController.dispose();
    _glitterController.dispose();
    super.dispose();
  }

  void _updateGlitterPositions() {
    setState(() {
      _glitterPositions = _glitterPositions.map((position) {
        final dx = position.dx + (_random.nextDouble() - 0.5) * 20;
        final dy = position.dy + (_random.nextDouble() - 0.5) * 20;

        final maxWidth =
            MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                .size
                .width;
        final maxHeight =
            MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                .size
                .height;

        return Offset(
          dx.clamp(0.0, maxWidth),
          dy.clamp(0.0, maxHeight),
        );
      }).toList();
    });
  }

  List<Widget> _generateGlitters() {
    return List.generate(30, (index) {
      return Positioned(
        left: _glitterPositions[index].dx,
        top: _glitterPositions[index].dy,
        child: Icon(
          Icons.circle,
          size: _random.nextDouble() * 8 + 2,
          color: Color.fromARGB(
            255,
            _random.nextInt(256),
            _random.nextInt(256),
            _random.nextInt(256),
          ),
        ),
      );
    });
  }

  void _toggleHeartAnimation() {
    _heartController.forward(); // Zaženemo srce animacijo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fading Heart with Moving Glitter"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 137, 78, 240),
                  Color.fromARGB(255, 153, 192, 224),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Stack(
            children: _generateGlitters(), // Bleščice se premikajo neodvisno
          ),
          Center(
            child: AnimatedOpacity(
              opacity: _vidno ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: AnimatedBuilder(
                animation: _heartSizeAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _heartSizeAnimation.value, // Srce animacija
                    child: const Icon(
                      Icons.favorite,
                      size: 200,
                      color: Colors.pink,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleHeartAnimation,
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
