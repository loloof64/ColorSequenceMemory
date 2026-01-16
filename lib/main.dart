import 'package:flutter/material.dart';
import 'package:minisound/engine.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color sequence memory',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Color sequence memory'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final Engine _engine;
  bool _engineReady = false;

  final soundDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _engine = Engine();
    _engine.init().then((_) {
      _engine.start().then((_) {
        setState(() {
          _engineReady = true;
        });
      });
    });
  }

  void _beep(double frequence, Duration duration) async {
    if (!_engineReady) return;
    final sound = _engine.genPulse(freq: frequence);
    sound.play();
    await Future.delayed(duration);
    sound.stop();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = 3.0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          children: [
            _soundButton(context, 200.0, Colors.blue),
            _soundButton(context, 300.0, Colors.red),
            _soundButton(context, 500.0, Colors.yellow),
            _soundButton(context, 400.0, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _soundButton(
    BuildContext context,
    soundFrequence,
    Color backgroundColor,
  ) {
    final minSize = MediaQuery.sizeOf(context).shortestSide;
    final buttonSize = minSize * 0.5;
    return Container(
      color: Colors.transparent,
      width: buttonSize,
      height: buttonSize,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        onPressed: () => _beep(soundFrequence, soundDuration),
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor,
          ),
        ),
      ),
    );
  }
}
