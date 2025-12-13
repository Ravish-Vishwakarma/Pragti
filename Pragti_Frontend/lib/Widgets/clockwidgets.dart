import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ClockTimer extends StatefulWidget {
  final int totalSeconds;
  final String ntitle;
  final String nmessage;

  const ClockTimer({
    super.key,
    this.totalSeconds = 300,
    required this.ntitle,
    required this.nmessage,
  });

  @override
  _ClockTimerState createState() => _ClockTimerState();
}

class _ClockTimerState extends State<ClockTimer> {
  Future<void> _sendNotification(title, message) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
      'POST',
      Uri.parse('http://127.0.0.1:8000/show_notification'),
    );

    request.body = json.encode({"title": "$title", "message": "$message"});
    request.headers.addAll(headers);
    await request.send();
  }

  @override
  void didUpdateWidget(covariant ClockTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.totalSeconds != oldWidget.totalSeconds) {
      _timer?.cancel();

      setState(() {
        _secondsLeft = widget.totalSeconds;
      });
    }
  }

  late int _secondsLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.totalSeconds;
  }

  void _startTimer() {
    _timer?.cancel(); // make sure no duplicate timers
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        _timer?.cancel();
        _sendNotification(widget.ntitle, widget.nmessage);
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _secondsLeft = widget.totalSeconds;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$secs";
  }

  @override
  Widget build(BuildContext context) {
    double progress = _secondsLeft / widget.totalSeconds;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 250,
              height: 250,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 12,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            Text(
              _formatTime(_secondsLeft),
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Time: ${_formatTime(widget.totalSeconds)}',
          style: TextStyle(
            fontSize: 14,
            color: const Color.fromARGB(255, 75, 75, 75),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: _startTimer, child: Text("Start")),
            const SizedBox(width: 10),
            ElevatedButton(onPressed: _stopTimer, child: Text("Stop")),
            const SizedBox(width: 10),
            ElevatedButton(onPressed: _resetTimer, child: Text("Reset")),
          ],
        ),
      ],
    );
  }
}
