import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pragti/Data/urls.dart';
import 'package:pragti/Widgets/Dialog/alarmdialog.dart';
import 'package:pragti/Widgets/Dialog/timerdialog.dart';
import 'package:pragti/Widgets/clockwidgets.dart';
import 'package:pragti/Widgets/style.dart';
import 'dart:async';

class MyClock extends StatefulWidget {
  const MyClock({super.key});

  @override
  State<MyClock> createState() => _MyClockState();
}

class _MyClockState extends State<MyClock> {
  var viewtype = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        backgroundColor: MyColors.forestgreen,
        title: Center(
          child: CupertinoSlidingSegmentedControl(
            groupValue: viewtype,
            children: <int, Widget>{
              1: slidertext("TIMER"),
              // 2: slidertext("ALARM"),
              3: slidertext("STOP WATCH"),
            },
            onValueChanged: (int? value) {
              if (value != null) {
                setState(() => viewtype = value);
              }
            },
            thumbColor: Colors.black,
          ),
        ),
      ),
      backgroundColor: MyColors.forestgreen,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final pageWidth = constraints.maxWidth;
          final pageHeight = constraints.maxHeight;
          return ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(0),
              bottomLeft: Radius.circular(1),
            ),
            child: Container(
              color: const Color.fromARGB(255, 63, 77, 67),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  viewtype == 1
                      ? Expanded(
                        child: MyTimerPage(
                          pageHeight: pageHeight,
                          pageWidth: pageWidth,
                        ),
                      )
                      : viewtype == 2
                      ? Expanded(child: MyAlarmPage())
                      : Expanded(child: MyStopwatchPage()),
                  // Container(
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(5),
                  //     color: Colors.white,
                  //   ),
                  //   margin: const EdgeInsets.all(8),
                  //   padding: const EdgeInsets.all(10),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //     children: [
                  //       InkWell(
                  //         onTap: () {
                  //           setState(() {
                  //             viewtype = 1;
                  //           });
                  //         },
                  //         child: Text(
                  //           "Timer",
                  //           style: GoogleFonts.jetBrainsMono(
                  //             textStyle: TextStyle(
                  //               color: Colors.black,
                  //               fontSize: 15,
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       InkWell(
                  //         onTap: () {
                  //           setState(() {
                  //             viewtype = 2;
                  //           });
                  //         },
                  //         child: Text(
                  //           "Alarm",
                  //           style: GoogleFonts.jetBrainsMono(
                  //             textStyle: TextStyle(
                  //               color: Colors.black,
                  //               fontSize: 15,
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       InkWell(
                  //         onTap: () {
                  //           setState(() {
                  //             viewtype = 3;
                  //           });
                  //         },
                  //         child: Text(
                  //           "Stop Watch",
                  //           style: GoogleFonts.jetBrainsMono(
                  //             textStyle: TextStyle(
                  //               color: Colors.black,
                  //               fontSize: 15,
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  slidertext(text) {
    return Text(text, style: GoogleFonts.jetBrainsMono(color: Colors.white));
  }
}

// ------------------------------------------ STOPWATCH ------------------------------------------ //
class MyStopwatchPage extends StatefulWidget {
  const MyStopwatchPage({super.key});

  @override
  State<MyStopwatchPage> createState() => _MyStopwatchPageState();
}

class _MyStopwatchPageState extends State<MyStopwatchPage> {
  final Stopwatch _stopwatch = Stopwatch();
  late Duration _elapsedTime;
  late String _elapsedTimeString;
  late Timer timer;
  late final List _timerlist = [];

  @override
  void initState() {
    super.initState();

    _elapsedTime = Duration.zero;
    _elapsedTimeString = _formatElapsedTime(_elapsedTime);

    // Create a timer that runs a callback every 100 milliseconds to update UI
    timer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      setState(() {
        // Update elapsed time only if the stopwatch is running
        if (_stopwatch.isRunning) {
          _updateElapsedTime();
        }
      });
    });
  }

  // Start/Stop button callback
  void _startStopwatch() {
    if (!_stopwatch.isRunning) {
      // Start the stopwatch and update elapsed time
      _stopwatch.start();
      _updateElapsedTime();
    } else {
      // Stop the stopwatch
      _stopwatch.stop();
    }
  }

  // Reset button callback
  void _resetStopwatch() {
    // Reset the stopwatch to zero and update elapsed time
    _stopwatch.reset();
    _updateElapsedTime();
  }

  // Update elapsed time and formatted time string
  void _updateElapsedTime() {
    setState(() {
      _elapsedTime = _stopwatch.elapsed;
      _elapsedTimeString = _formatElapsedTime(_elapsedTime);
    });
  }

  // Format a Duration into a string (MM:SS.SS)
  String _formatElapsedTime(Duration time) {
    return '${time.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(time.inSeconds.remainder(60)).toString().padLeft(2, '0')}.${(time.inMilliseconds % 1000 ~/ 100).toString()}';
  }

  Duration _parseDuration(String s) {
    final parts = s.split(':');
    final minutes = int.parse(parts[0]);
    final secondParts = parts[1].split('.');
    final seconds = int.parse(secondParts[0]);
    final tenths = int.parse(secondParts[1]);
    return Duration(
      minutes: minutes,
      seconds: seconds,
      milliseconds: tenths * 100,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "STOPWATCH",
                style: GoogleFonts.jetBrainsMono(
                  textStyle: TextStyle(color: Colors.black, fontSize: 24),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _elapsedTimeString,
                style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _startStopwatch,
                    icon:
                        _stopwatch.isRunning
                            ? Icon(Icons.pause_rounded, size: 30)
                            : Icon(Icons.play_arrow_rounded, size: 30),
                    tooltip: _stopwatch.isRunning ? 'Stop' : 'Start',
                  ),
                  const SizedBox(width: 12),

                  IconButton(
                    onPressed: _resetStopwatch,
                    icon: Icon(Icons.replay_rounded, size: 30),
                    tooltip: 'Reset',
                  ),
                  const SizedBox(width: 12),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _timerlist.insert(0, _elapsedTimeString);
                      });
                    },
                    icon: const Icon(Icons.keyboard_double_arrow_down_rounded),
                    tooltip: "Record",
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _timerlist.clear();
                      });
                    },
                    hoverColor: Color.fromARGB(
                      255,
                      255,
                      154,
                      147,
                    ).withOpacity(0.30),
                    icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                    tooltip: "Clear List",
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 2),
              const SizedBox(height: 10),
              Expanded(
                child:
                    _timerlist.isEmpty
                        ? const Center(child: Text("No laps yet"))
                        : ListView.builder(
                          itemCount: _timerlist.length,
                          itemBuilder: (context, index) {
                            String differenceText;
                            if (index < _timerlist.length - 1) {
                              final currentLap = _parseDuration(
                                _timerlist[index],
                              );
                              final previousLap = _parseDuration(
                                _timerlist[index + 1],
                              );
                              final difference = currentLap - previousLap;
                              differenceText =
                                  '+${_formatElapsedTime(difference)}';
                            } else {
                              differenceText = '+${_timerlist[index]}';
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDADADA),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 20,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _timerlist[index],
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    Text(
                                      differenceText,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------ ALARM ------------------------------------------ //
class MyAlarmPage extends StatefulWidget {
  const MyAlarmPage({super.key});

  @override
  State<MyAlarmPage> createState() => _MyAlarmPageState();
}

class _MyAlarmPageState extends State<MyAlarmPage> {
  List _alarmdata = [];
  Future<void> fetchAlarm() async {
    final response = await http.get(Uri.parse(Urls.getalarm));
    try {
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _alarmdata = data;
        });
      }
    } catch (a) {
      Exception("Error Occur");
    }
  }

  Future<void> deleteAlarm(int aid) async {
    try {
      final uri = Uri.parse(
        Urls.deletealarm,
      ).replace(queryParameters: {'aid': aid.toString()});

      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        await fetchAlarm();
      } else {
        throw Exception('Failed to delete Alarm: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete Alarm: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAlarm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 63, 77, 67),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () async {
          await showAddAlarmDialog(context);
          fetchAlarm();
        },
        tooltip: "Create Alarm",

        backgroundColor: MyColors.forestgreen,
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: Card(
        child: Column(
          children: [
            Center(
              child: Text(
                "ALARM",
                style: GoogleFonts.jetBrainsMono(
                  textStyle: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _alarmdata.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(255, 219, 219, 219),
                      ),
                      child: ListTile(
                        title: Text(_alarmdata[index]['title'].toString()),
                        subtitle: Text(_alarmdata[index]['message'].toString()),
                        leading: Icon(Icons.alarm),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _alarmdata[index]['time'].toString(),
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(width: 15),
                            IconButton(
                              onPressed: () {
                                deleteAlarm(_alarmdata[index]['id']);
                              },
                              tooltip: "Delete Alarm",
                              icon: Icon(Icons.delete_rounded),
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------ TIMER ------------------------------------------ //
class MyTimerPage extends StatefulWidget {
  final double pageHeight;
  final double pageWidth;
  const MyTimerPage({
    super.key,
    required this.pageHeight,
    required this.pageWidth,
  });

  @override
  State<MyTimerPage> createState() => _MyTimerPageState();
}

class _MyTimerPageState extends State<MyTimerPage> {
  TextEditingController customtime = TextEditingController();
  bool _isLoading = false;

  Future<void> fetchTimer() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(Urls.gettimer));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _timerdata = data;
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load timer from API");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading todos: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deleteTimer(int tid) async {
    try {
      final uri = Uri.parse(
        Urls.deletetimer,
      ).replace(queryParameters: {'tid': tid.toString()});

      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        await fetchTimer(); // only if async
      } else {
        throw Exception('Failed to delete timer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete timer: $e');
    }
  }

  List _timerdata = [];
  @override
  void initState() {
    fetchTimer();

    super.initState();
  }

  int timersec = 60;
  String title = "";
  String message = "";
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 10),
          ClockTimer(totalSeconds: timersec, ntitle: title, nmessage: message),
          SizedBox(
            width: widget.pageWidth / 2.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.values[4],
                    children: [
                      Text(
                        "Presets",
                        style: GoogleFonts.jetBrainsMono(
                          textStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await showAddTimerDialog(context);
                          fetchTimer();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(
                            255,
                            239,
                            240,
                            239,
                          ), // button color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              4,
                            ), // rounded corners
                          ),
                        ),
                        child: Text(
                          "+ Add",
                          style: GoogleFonts.jetBrainsMono(
                            textStyle: TextStyle(fontSize: 15),
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Divider(thickness: 1.5),
                ),
                Row(
                  children: [
                    timerbtn(1),
                    timerbtn(5),
                    timerbtn(10),
                    timerbtn(30),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: TextFormField(
                          controller: customtime,
                          decoration: InputDecoration(
                            label: Center(child: Text("MM:SS")),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        try {
                          var time = customtime.text.split(":");
                          setState(() {
                            timersec =
                                (int.parse(time[0]) * 60) + int.parse(time[1]);
                            title = customtime.text;
                            message = "Time Over";
                          });
                        } catch (a) {
                          final snack = SnackBar(
                            content: Text("Wrong Format"),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            action: SnackBarAction(
                              label: 'Dismiss',
                              textColor: Colors.white,
                              onPressed: () {},
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snack);
                        }
                      },
                      tooltip: "Add Timer",
                      icon: Icon(Icons.add),
                    ),
                    SizedBox(width: 2),
                  ],
                ),
                Expanded(
                  child:
                      _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : _timerdata.isEmpty
                          ? Center(child: Text("No Presets"))
                          : ListView.builder(
                            itemCount: _timerdata.length,
                            itemBuilder: (context, index) {
                              var timer = _timerdata[index];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          var timelist = timer["time"]
                                              .toString()
                                              .split(":");
                                          setState(() {
                                            timersec =
                                                int.parse(timelist[0]) *
                                                    60 *
                                                    60 +
                                                int.parse(timelist[1]) * 60 +
                                                int.parse(timelist[2]);
                                            title = timer["title"];
                                            message = timer["message"];
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                            255,
                                            34,
                                            44,
                                            38,
                                          ), // button color
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ), // rounded corners
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              timer["title"].toString(),
                                              style: GoogleFonts.jetBrainsMono(
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              timer["time"].toString(),
                                              style: GoogleFonts.jetBrainsMono(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        5,
                                        0,
                                        0,
                                        0,
                                      ),
                                      child: Tooltip(
                                        message: "Delete",
                                        child: InkWell(
                                          onTap: () {
                                            deleteTimer(
                                              _timerdata[index]['id'],
                                            );
                                          },
                                          child: Icon(
                                            Icons.delete_outline_outlined,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  timerbtn(time) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 2, 0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 223, 223, 223),
        borderRadius: BorderRadius.circular(17),
      ),
      child: IconButton(
        icon: Text("${time}Min "),
        color: Colors.white,
        onPressed: () {
          setState(() {
            timersec = time * 60;
            title = "$time Minute";
            message = "Time Over";
          });
        },
      ),
    );
  }
}
