import 'package:flutter/material.dart'
    show
        AlertDialog,
        AppBar,
        BuildContext,
        Canvas,
        Color,
        Colors,
        Column,
        Container,
        CrossAxisAlignment,
        CustomPaint,
        CustomPainter,
        ElevatedButton,
        Expanded,
        MainAxisAlignment,
        MaterialApp,
        Navigator,
        Offset,
        Paint,
        PaintingStyle,
        Row,
        Scaffold,
        SingleChildScrollView,
        Size,
        SizedBox,
        State,
        StatefulWidget,
        StatelessWidget,
        Text,
        Widget,
        runApp,
        showDialog;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:sensors/sensors.dart'
    show AccelerometerEvent, accelerometerEvents;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double dotX = 0.0;
  double dotY = 0.0;
  List<Offset> path = [];
  Color selectedColor = Colors.blue;
  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        dotX += event
            .x; // Move dot horizontally based on phone's acceleration on the x-axis
        dotY += event
            .y; // Move dot vertically based on phone's acceleration on the y-axis
        path.add(
            Offset(-dotX * 4, dotY * 6)); // Add current position to the path
      });
    });
  }

  void clearScreen() {
    setState(() {
      dotX = 0;
      dotY = 0;
      path.clear(); // Clear the path to remove all lines
    });
  }

  void startDraw() {
    // Your code here
  }

  void openColorPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  selectedColor = color;
                });
              },
              colorPickerWidth: 300.0,
              pickerAreaHeightPercent: 0.7,
              enableAlpha: true,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accelerometer Game'),
      ),
      body: Column(
        children: [
          Row(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 20,
              ),
              const Text('dotX: '),
              Text(dotX.toStringAsFixed(2)),
            ],
          ),
          const SizedBox(
            height: 2,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('dotY: '),
              Text(dotY.toStringAsFixed(2)),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
          Expanded(
            child: path.isNotEmpty
                ? CustomPaint(
                    painter: BallPainter(path, selectedColor),
                    //child: Container(),
                  )
                : Container(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  //startDraw();
                },
                child: const Text('Draw'),
              ),
              const SizedBox(
                width: 16,
              ),
              ElevatedButton(
                onPressed: clearScreen,
                child: const Text('Clear Screen'),
              ),
              const SizedBox(
                width: 16,
              ),
              ElevatedButton(
                onPressed: () {
                  openColorPickerDialog(context);
                },
                child: const Text('Choose Color'),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class BallPainter extends CustomPainter {
  final List<Offset> path;
  final Color color; // Added color property

  BallPainter(this.path, this.color); // Updated constructor

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color // Use the selected color
      ..strokeWidth = 4;

    for (int i = 1; i < path.length; i++) {
      canvas.drawLine(path[i - 1], path[i], paint);
    }

    // Draw a ball at the last point of the path
    final ballPaint = Paint()
      ..color = color // Use the selected color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(path.last, 10, ballPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
