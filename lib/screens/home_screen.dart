import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:diagonal_decoration/diagonal_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sahm_app/constants/colors.dart';
import 'package:sahm_app/helpers/size.dart';
import 'package:sahm_app/widgets/less_than_minimum_screens_scaffold_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  static const double _backgroundFirstArrowSize = 2500;
  static const double _backgroundSecondArrowSize = 4000;

  late AnimationController _patternController;
  late Animation<double> _patternAnimation;

  final ValueNotifier<String> _gameTextNotifier =
      ValueNotifier<String>('بسم الله');

  bool _isHintVisible = false;

  late AnimationController _firstArrowController;
  late Animation<double> _firstArrowPositionAnimation;
  late Animation<double> _firstArrowOpacityAnimation;

  late AnimationController _secondArrowController;
  late Animation<double> _secondArrowPositionAnimation;
  late Animation<double> _secondArrowOpacityAnimation;

  @override
  void initState() {
    super.initState();

    _patternController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _patternAnimation = Tween<double>(begin: 0.0, end: 0.15).animate(
      CurvedAnimation(parent: _patternController, curve: Curves.easeIn),
    );
    Future.delayed(const Duration(milliseconds: 2000), () {
      _patternController.forward();
    });

    _firstArrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    double firstArrowEndTop = -_backgroundFirstArrowSize / 2;
    double firstArrowStartTop = firstArrowEndTop - 100;

    _firstArrowPositionAnimation = Tween<double>(
      begin: firstArrowStartTop,
      end: firstArrowEndTop,
    ).animate(
      CurvedAnimation(
        parent: _firstArrowController,
        curve: Curves.easeOut,
      ),
    );

    _firstArrowOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(
      CurvedAnimation(
        parent: _firstArrowController,
        curve: Curves.easeOut,
      ),
    );

    _firstArrowController.forward();

    _secondArrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    double secondArrowEndTop = -_backgroundSecondArrowSize / 3;
    double secondArrowStartTop = secondArrowEndTop - 150;

    _secondArrowPositionAnimation = Tween<double>(
      begin: secondArrowStartTop,
      end: secondArrowEndTop,
    ).animate(
      CurvedAnimation(
        parent: _secondArrowController,
        curve: Curves.easeOut,
      ),
    );

    _secondArrowOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 0.15,
    ).animate(
      CurvedAnimation(
        parent: _secondArrowController,
        curve: Curves.easeOut,
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      _secondArrowController.forward();
    });

    // ? Initialize hint visibility after 3 seconds
    Timer(const Duration(seconds: 3), () {
      setState(() => _isHintVisible = true);
    });
  }

  @override
  void dispose() {
    _patternController.dispose();
    _gameTextNotifier.dispose();
    _firstArrowController.dispose();
    _secondArrowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);

    // * Crash for less than minimum screens
    if (HelperSize.hasLessThanMinimumScreen(context)) {
      return const LessThanMinimumScreensScaffoldWidget();
    }

    return Scaffold(
      body: AnimatedBuilder(
        animation: _patternAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: RepeatedPatternPainter(opacity: _patternAnimation.value),
            size: Size.infinite,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // * The big background arrows
                AnimatedBuilder(
                  animation: _firstArrowController,
                  builder: (context, child) {
                    return Positioned(
                      top: _firstArrowPositionAnimation.value,
                      left: (mediaQuery.size.width / 2) -
                          (_backgroundFirstArrowSize / 2),
                      child: Opacity(
                        opacity: _firstArrowOpacityAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/svgs/arrow-downward.svg',
                    width: _backgroundFirstArrowSize,
                    height: _backgroundFirstArrowSize,
                  ),
                ),
                AnimatedBuilder(
                  animation: _secondArrowController,
                  builder: (context, child) {
                    return Positioned(
                      top: _secondArrowPositionAnimation.value,
                      left: (mediaQuery.size.width / 2) -
                          (_backgroundSecondArrowSize / 2),
                      child: Opacity(
                        opacity: _secondArrowOpacityAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/svgs/arrow-downward.svg',
                    width: _backgroundSecondArrowSize,
                    height: _backgroundSecondArrowSize,
                  ),
                ),
                // * Blurred background text during countdown
                Positioned(
                  top: (mediaQuery.size.height / 3) - 400,
                  left: (mediaQuery.size.width / 2) - 78.8,
                  child: ValueListenableBuilder<String>(
                    valueListenable: _gameTextNotifier,
                    builder: (context, value, child) {
                      bool isCountdown =
                          value == '3' || value == '2' || value == '1';
                      if (!isCountdown) return const SizedBox.shrink();
                      return AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Transform.scale(
                          scale: 2.8,
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                            child:
                                LayoutBuilder(builder: (context, constraints) {
                              final double calculatedFontSize =
                                  constraints.maxWidth * 0.097;
                              final double limitedFontSize =
                                  min(calculatedFontSize, 50);
                              return Text(
                                value,
                                style: theme.textTheme.bodySmall!.copyWith(
                                  fontSize: limitedFontSize * 5,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.withOpacity(0.4),
                                ),
                              );
                            }),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // * Main Content
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final theme = Theme.of(context);
                        final double calculatedFontSize =
                            constraints.maxWidth < constraints.maxHeight
                                ? constraints.maxWidth * 0.112
                                : constraints.maxHeight * 0.07;
                        final double limitedFontSize = min(
                          calculatedFontSize,
                          50,
                        );

                        // ? Calculate the hint's height
                        double hintHeight =
                            constraints.maxWidth < 300 ? 70 : 100;

                        // ? Calculate the available height
                        final double availableHeightForGrid =
                            constraints.maxHeight - hintHeight;

                        final isShort =
                            MediaQuery.of(context).size.height < 500;

                        String localValue = 'بسم الله';

                        return Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Spacer(flex: 2),
                            SizedBox(
                              height: Platform.isAndroid
                                  ? isShort
                                      ? 100
                                      : 100
                                  : isShort
                                      ? 75
                                      : 100,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 5,
                                      ),
                                      child: ValueListenableBuilder<String>(
                                        valueListenable: _gameTextNotifier,
                                        builder: (context, value, child) {
                                          localValue = value;
                                          double fontSize = limitedFontSize;

                                          Widget textWidget;

                                          if (value == 'بسم الله' ||
                                              value == 'الحمد لله') {
                                            textWidget = Shimmer.fromColors(
                                              direction: ShimmerDirection.rtl,
                                              period: const Duration(
                                                  milliseconds: 2000),
                                              baseColor: const Color.fromARGB(
                                                  255, 233, 218, 176),
                                              highlightColor:
                                                  const Color.fromARGB(
                                                      255, 255, 252, 244),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 3.0),
                                                child: Text(
                                                  value,
                                                  maxLines: 2,
                                                  textAlign: TextAlign.center,
                                                  style: theme
                                                      .textTheme.bodySmall!
                                                      .copyWith(
                                                    fontSize: fontSize,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily:
                                                        'IBMPlexSansArabic',
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else {
                                            textWidget = Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8.0,
                                                bottom: 6.0,
                                              ),
                                              child: Text(
                                                value,
                                                maxLines: 2,
                                                textAlign: TextAlign.center,
                                                style: theme
                                                    .textTheme.bodySmall!
                                                    .copyWith(
                                                  color: const Color.fromARGB(
                                                      255, 233, 218, 176),
                                                  fontSize: fontSize,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily:
                                                      'IBMPlexSansArabic',
                                                ),
                                              ),
                                            );
                                          }

                                          final textStyle = theme
                                              .textTheme.bodyLarge!
                                              .copyWith(
                                            color: ConstantColors.green,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 18,
                                            height: 2,
                                          );

                                          return AnimatedSwitcher(
                                            duration: const Duration(
                                                milliseconds: 275),
                                            transitionBuilder: (Widget child,
                                                Animation<double> animation) {
                                              return FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              );
                                            },
                                            child: FittedBox(
                                              key: ValueKey<String>(value),
                                              fit: BoxFit.scaleDown,
                                              child: InkWell(
                                                onTap: () {
                                                  if (localValue ==
                                                          'بسم الله' ||
                                                      localValue ==
                                                          'الحمد لله' ||
                                                      localValue ==
                                                          'هل من مستهم ؟') {
                                                    showBarModalBottomSheet(
                                                      context: context,
                                                      builder: (context) =>
                                                          Container(
                                                        color: ConstantColors
                                                            .gold
                                                            .withOpacity(0.65),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(30),
                                                        child: Center(
                                                          child:
                                                              SingleChildScrollView(
                                                            child:
                                                                AnimatedContent(
                                                              textStyle:
                                                                  textStyle,
                                                              launchUrl:
                                                                  _launchUrl,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: Container(
                                                  height: 100,
                                                  alignment: Alignment.center,
                                                  foregroundDecoration:
                                                      BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.2),
                                                        blurRadius: 10,
                                                        offset:
                                                            const Offset(0, 4),
                                                      ),
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  decoration:
                                                      DiagonalDecoration(
                                                    lineColor: ConstantColors
                                                        .gold
                                                        .withOpacity(0.3),
                                                    backgroundColor:
                                                        ConstantColors.green
                                                            .withOpacity(0.6),
                                                    radius:
                                                        const Radius.circular(
                                                            20),
                                                    lineWidth: 1,
                                                    distanceBetweenLines: 20,
                                                  ),
                                                  clipBehavior: Clip.none,
                                                  padding: EdgeInsets.symmetric(
                                                    vertical:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .height <
                                                                400
                                                            ? 0
                                                            : 10,
                                                    horizontal: 25,
                                                  ),
                                                  child: textWidget,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(flex: 1),
                            IstihamGrid(
                              gameTextNotifier: _gameTextNotifier,
                              onButtonToggle: () {
                                if (!_isHintVisible) {
                                  setState(() {
                                    _isHintVisible = true;
                                  });
                                }
                              },
                              availableHeight: availableHeightForGrid,
                            ),
                            const Spacer(flex: 3),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('لم يتم فتح الرابط : $url');
    }
  }
}

class AnimatedContent extends StatelessWidget {
  final TextStyle textStyle;
  final Function(String url) launchUrl;

  const AnimatedContent({
    super.key,
    required this.textStyle,
    required this.launchUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: AnimateList(
        delay: 400.ms,
        interval: 650.ms,
        effects: [
          FadeEffect(duration: 1200.ms),
          MoveEffect(
            curve: Curves.easeInOut,
            begin: const Offset(20, 0),
            end: Offset.zero,
            duration: 800.ms,
          ),
        ],
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              'بسم الله الرحمن الرحيم',
              softWrap: true,
              style: textStyle,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'الحمد لله رب العالمين ، والصلاة والسلام على عبد الله ورسوله ، خاتم الأنبياء والمرسلين : محمد ، وعلى آله وصحبه أجمعين والتابعين . أما بعد :',
            softWrap: true,
            style: textStyle,
          ),
          const SizedBox(height: 20),
          Wrap(
            children: [
              Text(
                'فهذا تطبيق لتفعيل ونشر سنة ',
                style: textStyle,
              ),
              InkWell(
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                child: Stack(
                  children: [
                    Text(
                      'الاستهام',
                      style: textStyle.copyWith(
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Positioned(
                      bottom: 3,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 1,
                        color: ConstantColors.green,
                      ),
                    ),
                  ],
                ),
                onTap: () => launchUrl(
                    'https://islamic-content.com/dictionary/word/11455/ar'),
              ),
              Text(
                ' بين الناس ...',
                style: textStyle,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.center,
            child: Text(
              'والحمد لله رب العالمين',
              softWrap: true,
              style: textStyle,
            ),
          ),
          const SizedBox(height: 30),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              children: [
                Text(
                  '~ ',
                  style: textStyle.copyWith(
                    fontSize: 15,
                  ),
                ),
                InkWell(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                  onTap: () => launchUrl('https://github.com/VPremiss'),
                  child: Text(
                    'VPremiss',
                    style: textStyle.copyWith(
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RepeatedPatternPainter extends CustomPainter {
  final double opacity;

  RepeatedPatternPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ConstantColors.green.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // * The path that represents the SVG
    final path = Path()
      ..moveTo(15.986, 4.186)
      ..lineTo(4.1, 16.072)
      ..moveTo(23.606, 4.186)
      ..lineTo(35.986, 16.566)
      ..moveTo(35.986, 23.434)
      ..lineTo(23.52, 35.9)
      ..moveTo(4.1, 23.52)
      ..lineTo(15.9, 35.9);

    // * The offset for each repeated tile
    const double tileWidth = 40.0;
    const double tileHeight = 40.0;

    // * Loop over the screen dimensions and draw the SVG pattern in a grid
    for (double y = 0; y < size.height; y += tileHeight) {
      for (double x = 0; x < size.width; x += tileWidth) {
        canvas.save();
        canvas.translate(x, y);
        canvas.drawPath(path, paint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant RepeatedPatternPainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}

class IstihamGrid extends StatefulWidget {
  final ValueNotifier<String> gameTextNotifier;
  final VoidCallback onButtonToggle;
  final double availableHeight;

  const IstihamGrid({
    super.key,
    required this.gameTextNotifier,
    required this.onButtonToggle,
    required this.availableHeight,
  });

  @override
  State<IstihamGrid> createState() => _IstihamGridState();
}

class _IstihamGridState extends State<IstihamGrid>
    with SingleTickerProviderStateMixin {
  static const double _gridMinDiamondScreenSize = 400;

  static const double _gridSquareRotationAngle = 0.0; // * 0 degrees
  static const double _gridDiamondRotationAngle = -pi / 4; // * -45 degrees

  static const Duration _gridRotationDurationSpeed = Duration(
    milliseconds: 600,
  );
  static const Duration _gridRotationDurationDelay = Duration(
    milliseconds: 250,
  );

  final ValueNotifier<bool> _isGridInSquareShape = ValueNotifier<bool>(false);

  bool _isInitialGridAnimationCheckDone = false;
  bool _isGridAnimating = false;
  Timer? _gridAnimationDebounceTimer;
  double _gridCurrentRotationAngle = _gridDiamondRotationAngle;

  late AnimationController _gridRotationAnimationController;
  late Animation<double> _gridRotationAnimation;

  List<Color> _availableBackgroundColors = [
    Colors.blueAccent.shade400,
    Colors.blueGrey.shade600,
    Colors.yellow.shade600,
    Colors.green.shade600,
    Colors.pink.shade500,
    Colors.deepPurple,
    Colors.teal.shade500,
    Colors.black,
    Colors.brown.shade400,
  ];

  List<Color> _availableTextColors = [
    Colors.white,
    Colors.white,
    Colors.black,
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
  ];

  final List<ValueNotifier<ButtonState>> _buttonStates = List.generate(
    9,
    (_) => ValueNotifier<ButtonState>(ButtonState()),
  );

  List<int> _toggledButtonIndices = [];

  Timer? _countdownTimer;

  int _countdownSeconds = 3;

  int? _winningButtonIndex;

  @override
  void initState() {
    super.initState();

    _gridRotationAnimationController = AnimationController(
      duration: _gridRotationDurationSpeed,
      vsync: this,
    );

    _gridRotationAnimation = _createGridRotationAnimation(
      _isGridInSquareShape.value,
    );

    _gridRotationAnimationController.addStatusListener(
      (status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          _isGridAnimating = false;
        }
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialConstraints = context.size;

      if (initialConstraints != null) {
        if (initialConstraints.width < _gridMinDiamondScreenSize) {
          _gridCurrentRotationAngle = _gridSquareRotationAngle;
        }

        _isGridInSquareShape.value =
            initialConstraints.width < _gridMinDiamondScreenSize;
      }
    });
  }

  @override
  void dispose() {
    _gridAnimationDebounceTimer?.cancel();
    _isGridInSquareShape.dispose();
    _gridRotationAnimationController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double availableHeight = widget.availableHeight;

        if (!_isInitialGridAnimationCheckDone) {
          _isInitialGridAnimationCheckDone = true;
          _attemptGridRotationAnimation(screenWidth, availableHeight);
        }

        _prepareGridRotationAnimationAttempt(screenWidth, availableHeight);

        double gridSize = 3;
        bool isGridRotated = !_isGridInSquareShape.value;

        double maxGridWidthBasedOnHeight =
            isGridRotated ? availableHeight / sqrt(2) : availableHeight;

        double gridWidth = min(
          min(
            screenWidth,
            screenWidth >= 400 && screenWidth < 525
                ? 310
                : _gridMinDiamondScreenSize,
          ),
          maxGridWidthBasedOnHeight,
        );

        double buttonSize = gridWidth / gridSize;
        double rotatedGridSize =
            isGridRotated ? gridWidth * sqrt(2) : gridWidth;

        return AnimatedBuilder(
          animation: _gridRotationAnimation,
          builder: (context, child) {
            return SizedBox(
              width: rotatedGridSize,
              height: rotatedGridSize - 10,
              child: Transform(
                transform: Matrix4.rotationZ(_gridRotationAnimation.value),
                alignment: Alignment.center,
                child: Align(
                  alignment: Alignment.center,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: gridWidth,
                    height: gridWidth,
                    child: _buildGrid(gridSize.toInt(), buttonSize),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _attemptGridRotationAnimation(
      double screenWidth, double availableHeight) {
    if (_isGridAnimating) return;

    double maxGridWidthBasedOnHeight = availableHeight / sqrt(2);
    bool shouldBeInSquareShape = screenWidth < _gridMinDiamondScreenSize ||
        maxGridWidthBasedOnHeight < _gridMinDiamondScreenSize;

    if (shouldBeInSquareShape != _isGridInSquareShape.value) {
      _isGridInSquareShape.value = shouldBeInSquareShape;
      _isGridAnimating = true;
      _gridRotationAnimation =
          _createGridRotationAnimation(shouldBeInSquareShape);
      _gridCurrentRotationAngle = shouldBeInSquareShape
          ? _gridSquareRotationAngle
          : _gridDiamondRotationAngle;

      _gridRotationAnimationController.forward(from: 0).then((_) {
        _isGridAnimating = false;
      });
    }
  }

  void _prepareGridRotationAnimationAttempt(
      double screenWidth, double availableHeight) {
    _gridAnimationDebounceTimer?.cancel();
    _gridAnimationDebounceTimer = Timer(
      _gridRotationDurationDelay,
      () => _attemptGridRotationAnimation(screenWidth, availableHeight),
    );
  }

  Animation<double> _createGridRotationAnimation(bool isInSquareShape) {
    return Tween(
      begin: _gridCurrentRotationAngle,
      end: isInSquareShape
          ? _gridSquareRotationAngle
          : _gridDiamondRotationAngle,
    ).animate(
      CurvedAnimation(
        parent: _gridRotationAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  Widget _buildGrid(int size, double buttonSize) {
    return SizedBox(
      width: buttonSize * size,
      height: buttonSize * size,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(size * size, (index) {
          final row = index ~/ size;
          final col = index % size;
          final x = col * buttonSize;
          final y = row * buttonSize;
          final buttonStateNotifier = _buttonStates[index];

          return Positioned(
            left: x,
            top: y,
            width: buttonSize,
            height: buttonSize,
            child: IstihamButton(
              buttonSize: buttonSize,
              index: index,
              buttonStateNotifier: buttonStateNotifier,
              onTap: _handleButtonTap,
              isGridInSquareShape: _isGridInSquareShape,
              winningButtonIndex: _winningButtonIndex,
            ),
          );
        }),
      ),
    );
  }

  void _handleButtonTap(int index) {
    setState(() {
      final buttonStateNotifier = _buttonStates[index];
      final buttonState = buttonStateNotifier.value;
      _winningButtonIndex = null;
      if (!buttonState.isToggled) {
        Color? bgColor;
        Color? txtColor;
        if (_availableBackgroundColors.isNotEmpty) {
          int colorIndex = Random().nextInt(_availableBackgroundColors.length);
          bgColor = _availableBackgroundColors.removeAt(colorIndex);
          txtColor = _availableTextColors.removeAt(colorIndex);
        }
        buttonStateNotifier.value = buttonState.copyWith(
          isToggled: true,
          backgroundColor: bgColor,
          textColor: txtColor,
        );

        _toggledButtonIndices.add(index);

        if (_toggledButtonIndices.length == 1) {
          widget.gameTextNotifier.value = 'هل من مستهم ؟';
        }
      } else {
        if (buttonState.backgroundColor != null) {
          _availableBackgroundColors.add(buttonState.backgroundColor!);
        }
        if (buttonState.textColor != null) {
          _availableTextColors.add(buttonState.textColor!);
        }
        buttonStateNotifier.value = buttonState.copyWith(
          isToggled: false,
          backgroundColor: null,
          textColor: null,
        );

        _toggledButtonIndices.remove(index);

        if (_toggledButtonIndices.isEmpty) {
          widget.gameTextNotifier.value = 'بسم الله';
          _resetAvailableColors();
        } else if (_toggledButtonIndices.length == 1) {
          widget.gameTextNotifier.value = 'هل من مستهم ؟';
        }
      }

      if (_toggledButtonIndices.length >= 2) {
        _countdownTimer?.cancel();
        _countdownSeconds = 3;
        _startCountdown();
      } else {
        _countdownTimer?.cancel();
      }
    });

    widget.onButtonToggle();
  }

  void _startCountdown() {
    widget.gameTextNotifier.value = '$_countdownSeconds';
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdownSeconds--;
        if (_countdownSeconds > 0) {
          widget.gameTextNotifier.value = '$_countdownSeconds';
        } else {
          timer.cancel();
          _selectWinner();
        }
      });
    });
  }

  void _selectWinner() {
    setState(() {
      if (_toggledButtonIndices.isNotEmpty) {
        int winnerIndex = _toggledButtonIndices[
            Random().nextInt(_toggledButtonIndices.length)];
        _winningButtonIndex = winnerIndex;

        for (int i = 0; i < _buttonStates.length; i++) {
          if (i != winnerIndex) {
            final buttonState = _buttonStates[i].value;
            if (buttonState.backgroundColor != null) {
              _availableBackgroundColors.add(buttonState.backgroundColor!);
            }
            if (buttonState.textColor != null) {
              _availableTextColors.add(buttonState.textColor!);
            }
            _buttonStates[i].value = ButtonState();
          }
        }
        _toggledButtonIndices = [winnerIndex];

        widget.gameTextNotifier.value = 'الحمد لله';
      } else {
        widget.gameTextNotifier.value = 'هل من مستهم ؟';
      }
    });
  }

  void _resetAvailableColors() {
    _availableBackgroundColors = [
      Colors.blueAccent.shade400,
      Colors.blueGrey.shade600,
      Colors.yellow.shade600,
      Colors.green.shade600,
      Colors.pink.shade500,
      Colors.deepPurple,
      Colors.teal.shade500,
      Colors.black,
      Colors.brown.shade400,
    ];

    _availableTextColors = [
      Colors.white,
      Colors.white,
      Colors.black,
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.white,
    ];
  }
}

class ButtonState {
  final bool isToggled;
  final Color? backgroundColor;
  final Color? textColor;

  ButtonState({
    this.isToggled = false,
    this.backgroundColor,
    this.textColor,
  });

  ButtonState copyWith({
    bool? isToggled,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return ButtonState(
      isToggled: isToggled ?? this.isToggled,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
    );
  }
}

class IstihamButton extends StatelessWidget {
  final double buttonSize;
  final int index;
  final ValueNotifier<ButtonState> buttonStateNotifier;
  final Function(int) onTap;
  final ValueNotifier<bool> isGridInSquareShape;
  final int? winningButtonIndex;

  const IstihamButton({
    super.key,
    required this.buttonSize,
    required this.index,
    required this.buttonStateNotifier,
    required this.onTap,
    required this.isGridInSquareShape,
    this.winningButtonIndex,
  });

  @override
  Widget build(BuildContext context) {
    final isGridRotated = !isGridInSquareShape.value;

    return ValueListenableBuilder<ButtonState>(
      valueListenable: buttonStateNotifier,
      builder: (context, buttonState, child) {
        final hasWon = buttonState.isToggled && index == winningButtonIndex;
        final shouldBeSmall = HelperSize.hasNearMinimumScreen(context);
        final double buttonBorderRadius = shouldBeSmall ? 15.0 : 25.0;
        double fontSize = shouldBeSmall ? 40.0 : 60.0;
        if (buttonState.isToggled) {
          fontSize -= 2.0;
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // * Blurred blob behind the button
            if (buttonState.isToggled)
              Align(
                alignment: Alignment.center,
                child: Center(
                  child: OverflowBox(
                    maxWidth: buttonSize * 1.85,
                    maxHeight: buttonSize * 1.85,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: 12,
                        sigmaY: 12,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        width: buttonSize * 1.85,
                        height: buttonSize * 1.85,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              buttonState.backgroundColor!.withOpacity(0.5),
                              Colors.transparent,
                            ],
                            stops: const [0.5, 0.9],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // * The button
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(buttonBorderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8.0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(buttonBorderRadius),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: hasWon
                                  ? buttonState.backgroundColor ?? Colors.white
                                  : Colors.white,
                              borderRadius:
                                  BorderRadius.circular(buttonBorderRadius),
                            ),
                          ),
                          // * An inner border with shadow
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    buttonBorderRadius - 2),
                                border: Border.all(
                                  color: buttonState.isToggled
                                      ? buttonState.backgroundColor ??
                                          Colors.black
                                      : Colors.grey.withOpacity(0.1),
                                  width: 4.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.00),
                                    blurRadius: 4.0,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              hoverColor: ConstantColors.gold.withOpacity(0.15),
                              splashColor: ConstantColors.gold.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(
                                buttonBorderRadius,
                              ),
                              onTap: () => onTap(index),
                              child: Center(
                                child: AnimatedRotation(
                                  turns: isGridRotated && buttonState.isToggled
                                      ? 0.125
                                      : 0,
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    alignment: Alignment.center,
                                    children: [
                                      // * The outer circle
                                      if (buttonState.isToggled)
                                        Positioned(
                                          top: Platform.isAndroid
                                              ? shouldBeSmall
                                                  ? -20
                                                  : -9.25
                                              : shouldBeSmall
                                                  ? 1
                                                  : 3,
                                          left: Platform.isAndroid
                                              ? shouldBeSmall
                                                  ? -7.25
                                                  : -12
                                              : shouldBeSmall
                                                  ? -3.25
                                                  : -4.75,
                                          child: Text(
                                            '○',
                                            style: TextStyle(
                                              color: hasWon
                                                  ? Colors.transparent
                                                  : buttonState.isToggled
                                                      ? buttonState
                                                              .backgroundColor ??
                                                          Colors.black
                                                      : Colors.black,
                                              fontSize: fontSize *
                                                  (Platform.isAndroid
                                                      ? 1.6
                                                      : 0.9),
                                            ),
                                          ),
                                        ),
                                      // * The special character inside the circle
                                      Text(
                                        '⋄',
                                        style: TextStyle(
                                          color: hasWon
                                              ? buttonState.textColor
                                              : Colors.black,
                                          fontSize: fontSize,
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
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
