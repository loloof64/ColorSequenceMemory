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
            _soundButton(
              context,
              200.0,
              Colors.blue,
              QuarterCirclePosition.topLeft,
            ),
            _soundButton(
              context,
              300.0,
              Colors.red,
              QuarterCirclePosition.topRight,
            ),
            _soundButton(
              context,
              500.0,
              Colors.yellow,
              QuarterCirclePosition.bottomLeft,
            ),
            _soundButton(
              context,
              400.0,
              Colors.green,
              QuarterCirclePosition.bottomRight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _soundButton(
    BuildContext context,
    soundFrequence,
    Color backgroundColor,
    QuarterCirclePosition position,
  ) {
    final minSize = MediaQuery.sizeOf(context).shortestSide;
    final buttonSize = minSize * 0.5;
    return Container(
      color: backgroundColor,
      width: buttonSize,
      height: buttonSize,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(),
          padding: EdgeInsets.zero,
        ),
        onPressed: () => _beep(soundFrequence, soundDuration),
        child: ClipPath(
          clipper: QuarterCircleClipper(position),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

enum QuarterCirclePosition { topLeft, topRight, bottomLeft, bottomRight }

class QuarterCircleClipper extends CustomClipper<Path> {
  final QuarterCirclePosition position;
  QuarterCircleClipper(this.position);

  @override
  Path getClip(Size size) {
    final path = Path();
    switch (position) {
      case QuarterCirclePosition.topLeft:
        path.moveTo(size.width, 0);
        path.arcToPoint(
          Offset(0, size.height),
          radius: Radius.circular(size.width),
          clockwise: false,
        );
        path.lineTo(0, 0);
        path.close();
        break;
      case QuarterCirclePosition.topRight:
        path.moveTo(size.width, size.height);
        path.arcToPoint(
          Offset(0, 0),
          radius: Radius.circular(size.width),
          clockwise: false,
        );
        path.lineTo(size.width, 0);
        path.close();
        break;
      case QuarterCirclePosition.bottomLeft:
        path.moveTo(0, 0);
        path.arcToPoint(
          Offset(size.width, size.height),
          radius: Radius.circular(size.width),
          clockwise: false,
        );
        path.lineTo(0, size.height);
        path.close();
        break;
      case QuarterCirclePosition.bottomRight:
        path.moveTo(0, size.height);
        path.arcToPoint(
          Offset(size.width, 0),
          radius: Radius.circular(size.width),
          clockwise: false,
        );
        path.lineTo(size.width, size.height);
        path.close();
        break;
    }
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
