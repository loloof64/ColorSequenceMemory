import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:minisound/player_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => FlutterI18n.translate(context, "title"),
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      localizationsDelegates: [
        FlutterI18nDelegate(
          translationLoader: FileTranslationLoader(
            useCountryCode: false,
            fallbackFile: 'en',
            basePath: 'assets/flutter_i18n',
          ),
        ),
        ...GlobalMaterialLocalizations.delegates,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('es'), Locale('fr')],
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final Player _engine;
  bool _engineReady = false;
  QuarterCirclePosition? _highlightedButton;

  bool _isPlayingSequence = false;
  bool _gameInProgress = false;
  List<QuarterCirclePosition> _sequence = [];
  int _checkIndex = 0;

  final soundDuration = Duration(milliseconds: 300);
  final playSequenceGap = Duration(milliseconds: 80);
  final _associatedSounds = <QuarterCirclePosition, double>{
    QuarterCirclePosition.topLeft: 200.0,
    QuarterCirclePosition.topRight: 300.0,
    QuarterCirclePosition.bottomRight: 400.0,
    QuarterCirclePosition.bottomLeft: 500.0,
  };
  final double lostSoundFrequence = 100.0;
  final lostSoundDuration = Duration(milliseconds: 420);
  final gapBeforeGameOverSound = Duration(milliseconds: 100);
  final gapAfterGuessedSequence = Duration(milliseconds: 400);

  // Pre-generated sounds to reuse
  late final Map<QuarterCirclePosition, dynamic> _preSounds = {};
  late final dynamic _lostSound;

  @override
  void initState() {
    super.initState();
    _engine = Player();
    _engine.init().then((_) {
      _engine.start().then((_) {
        // Pre-generate all sounds
        for (final entry in _associatedSounds.entries) {
          final sound = _engine.genWaveform(
            WaveformType.square,
            freq: entry.value,
          );
          sound.volume = 0.25;
          _preSounds[entry.key] = sound;
        }
        _lostSound = _engine.genWaveform(
          WaveformType.square,
          freq: lostSoundFrequence,
        );
        _lostSound.volume = 0.25;

        setState(() {
          _engineReady = true;
        });
      });
    });
  }

  Future<void> _beep({
    required double frequence,
    required Duration duration,
    required QuarterCirclePosition? highlightPosition,
  }) async {
    if (!_engineReady) return;
    final sound = highlightPosition != null
        ? _preSounds[highlightPosition]
        : _lostSound;

    setState(() {
      _highlightedButton = highlightPosition;
    });
    sound.play();
    await Future.delayed(duration);
    sound.stop();
    setState(() {
      _highlightedButton = null;
    });
  }

  void _addButtonToSequence() {
    final values = QuarterCirclePosition.values;
    final nextSideOrdinal = Random().nextInt(values.length);
    final nextButton = values[nextSideOrdinal];
    setState(() {
      _sequence.add(nextButton);
    });
  }

  Future<void> _handleGameStart() async {
    if (_gameInProgress) return;
    setState(() {
      _sequence = [];
      _gameInProgress = true;
    });
    _addButtonToSequence();
    await _playSequence();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = 3.0;
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    final isPortrait =
        MediaQuery.orientationOf(context) == Orientation.portrait;
    final deviceSize = isPortrait ? 0.7 * width : 0.6 * height;
    final middleButtonSize = deviceSize * 0.45;

    final score = _sequence.isNotEmpty ? _sequence.length - 1 : 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(FlutterI18n.translate(context, "title")),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 4.0,
          children: [
            Text(
              "${FlutterI18n.translate(context, "score")}: $score",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize ?? 50,
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: deviceSize,
                  height: deviceSize,
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    children: [
                      _soundButton(
                        context: context,
                        soundFrequence:
                            _associatedSounds[QuarterCirclePosition.topLeft],
                        backgroundColor: Colors.blue,
                        position: QuarterCirclePosition.topLeft,
                        highlighted:
                            _highlightedButton == QuarterCirclePosition.topLeft,
                      ),
                      _soundButton(
                        context: context,
                        soundFrequence:
                            _associatedSounds[QuarterCirclePosition.topRight],
                        backgroundColor: Colors.red,
                        position: QuarterCirclePosition.topRight,
                        highlighted:
                            _highlightedButton ==
                            QuarterCirclePosition.topRight,
                      ),
                      _soundButton(
                        context: context,
                        soundFrequence:
                            _associatedSounds[QuarterCirclePosition.bottomLeft],
                        backgroundColor: Colors.yellow,
                        position: QuarterCirclePosition.bottomLeft,
                        highlighted:
                            _highlightedButton ==
                            QuarterCirclePosition.bottomLeft,
                      ),
                      _soundButton(
                        context: context,
                        soundFrequence:
                            _associatedSounds[QuarterCirclePosition
                                .bottomRight],
                        backgroundColor: Colors.green,
                        position: QuarterCirclePosition.bottomRight,
                        highlighted:
                            _highlightedButton ==
                            QuarterCirclePosition.bottomRight,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: middleButtonSize,
                  height: middleButtonSize,
                  child: ElevatedButton(
                    onPressed: _handleGameStart,
                    child: I18nText("start_game"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _playSequence() async {
    setState(() {
      _isPlayingSequence = true;
    });

    for (final side in _sequence) {
      await _beep(
        frequence: _associatedSounds[side]!,
        duration: soundDuration,
        highlightPosition: side,
      );
      await Future.delayed(playSequenceGap);
    }

    setState(() {
      _isPlayingSequence = false;
      _checkIndex = 0;
    });
  }

  Future<void> _handleButtonPress({
    required double frequence,
    required Duration duration,
    required Color backgroundColor,
    required QuarterCirclePosition position,
  }) async {
    if (!_gameInProgress) return;
    if (_isPlayingSequence) return;
    await _beep(
      frequence: frequence,
      duration: duration,
      highlightPosition: position,
    );

    final isExpectedButton = _sequence[_checkIndex] == position;
    if (isExpectedButton) {
      final thereAreMoreButtonsInSeq = _checkIndex < _sequence.length - 1;
      if (thereAreMoreButtonsInSeq) {
        setState(() {
          _checkIndex++;
        });
      } else {
        setState(() {
          _isPlayingSequence = true;
        });
        _addButtonToSequence();
        await Future.delayed(gapAfterGuessedSequence);
        await _playSequence();
      }
    } else {
      setState(() {
        _isPlayingSequence = true;
      });
      await Future.delayed(gapBeforeGameOverSound);
      await _beep(
        frequence: lostSoundFrequence,
        duration: lostSoundDuration,
        highlightPosition: null,
      );
      setState(() {
        _gameInProgress = false;
      });
    }
  }

  Widget _soundButton({
    required BuildContext context,
    required soundFrequence,
    required Color backgroundColor,
    required QuarterCirclePosition position,
    required bool highlighted,
  }) {
    final minSize = MediaQuery.sizeOf(context).shortestSide;
    final buttonSize = minSize * 0.5;
    final background = Theme.of(context).scaffoldBackgroundColor;
    return Container(
      color: backgroundColor.withAlpha(highlighted ? 255 : 100),
      width: buttonSize,
      height: buttonSize,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shadowColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(),
          padding: EdgeInsets.zero,
        ),
        onPressed: () => _handleButtonPress(
          frequence: soundFrequence,
          duration: soundDuration,
          position: position,
          backgroundColor: background,
        ),
        child: ClipPath(
          clipper: QuarterCircleClipper(position),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            color: background,
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
