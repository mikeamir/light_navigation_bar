import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.red,
        body: Center(
          child: NavigationBar(
            icons: [
              Icons.favorite,
              Icons.alarm,
              Icons.camera,
              Icons.camera_roll,
            ],
            onSelected: print,
            screenSizeWidthPercentage: 80,
            screenSizeHeightPercentage: 10,
            radius: 25,
            lightOn: true,
          ),
        ),
      ),
    ),
  );
}

// ignore: must_be_immutable
class NavigationBar extends StatefulWidget {
  final Color backgroundColor, activeIconColor, inactiveIconColor;
  final List<IconData> icons;
  final double radius;
  final Function(int index) onSelected;
  final int screenSizeWidthPercentage, screenSizeHeightPercentage;
  final Duration duration;
  final bool lightOn;
  int index;

  NavigationBar({
    @required this.icons,
    @required this.onSelected,
    this.activeIconColor = Colors.white,
    this.backgroundColor = Colors.black,
    this.inactiveIconColor = Colors.white30,
    this.radius = 0,
    this.index = 0,
    this.screenSizeWidthPercentage = 100,
    this.screenSizeHeightPercentage = 100,
    this.duration = const Duration(milliseconds: 100),
    this.lightOn = true,
  });

  @override
  _NavigationBarState createState() => _NavigationBarState(lightOn: lightOn);
}

class _NavigationBarState extends State<NavigationBar> {
  bool lightOn;

  _NavigationBarState({this.lightOn});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: widget.screenSizeHeightPercentage / 100,
      widthFactor: widget.screenSizeWidthPercentage / 100,
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          color: widget.backgroundColor,
        ),
        child: FractionallySizedBox(
          widthFactor: 0.95,
          child: Stack(
            children: [
              Row(
                children: List<Widget>.generate(
                  widget.icons.length,
                  (index) {
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          setState(() {
                            widget.index = index;
                            widget.onSelected(index);

                            if (widget.lightOn) {
                              lightOn = false;
                              Timer(
                                widget.duration,
                                () {
                                  setState(() {
                                    lightOn = true;
                                  });
                                },
                              );
                            }
                          });
                        },
                        child: Center(
                          child: FractionallySizedBox(
                            heightFactor: 0.4,
                            child: FittedBox(
                              child: Icon(
                                widget.icons[index],
                                color: widget.index == index ? widget.activeIconColor : widget.inactiveIconColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              AnimatedContainer(
                alignment: Alignment(-1 + ((widget.index) * (2 / (widget.icons.length - 1))), 0),
                duration: widget.duration,
                child: CustomPaint(
                  painter: LightPainter(color: widget.activeIconColor, lightOn: lightOn),
                  child: FractionallySizedBox(
                    heightFactor: 1,
                    widthFactor: 1 / widget.icons.length,
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

class LightPainter extends CustomPainter {
  final Color color;
  final bool lightOn;

  LightPainter({
    @required this.color,
    @required this.lightOn,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // will use the cascading notation
    Paint topBarPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.height * 0.05;

    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.025),
      Offset(size.width * 0.75, size.height * 0.025),
      topBarPaint,
    );

    if (lightOn) {
      // now for the light
      // we will use the shader properity to apply the linear gredient
      Paint lightPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [color, color.withOpacity(0)]).createShader(
          Rect.fromLTWH(
            0,
            0,
            size.width,
            size.height,
          ),
        );

      Path lightPath = Path();

      lightPath.moveTo(size.width * 0.25, size.height * 0.025);
      // left bottom most point
      lightPath.lineTo(0, size.height);
      lightPath.lineTo(size.width, size.height);
      lightPath.lineTo(size.width * 0.75, size.height * 0.025);
      lightPath.close();

      canvas.drawPath(lightPath, lightPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
