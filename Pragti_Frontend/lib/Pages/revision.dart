import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pragti/Data/urls.dart';
import 'package:pragti/Widgets/spoilertext.dart';
import 'package:pragti/Widgets/style.dart';

class RevisionPage extends StatefulWidget {
  const RevisionPage({super.key});
  @override
  State<RevisionPage> createState() => _RevisionPageState();
}

class _RevisionPageState extends State<RevisionPage> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _contentDateController = TextEditingController();
  final TextEditingController _contentRepetitionController =
      TextEditingController();
  final TextEditingController _contentQuestionCountController =
      TextEditingController();
  final TextEditingController _customQuestionController =
      TextEditingController();
  final TextEditingController _customQuestionAnswerController =
      TextEditingController();
  final TextEditingController _customQuestionDateController =
      TextEditingController();
  final TextEditingController _customQuestionRepetitionController =
      TextEditingController();
  List _questions = [];
  Future<void> fetchQuestions() async {
    final response = await http.get(Uri.parse(Urls.getquestions));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        _questions = data;
      });
    }
  }

  Future<void> updateQuestionByID(qid, status) async {
    final url = Uri.parse(Urls.updatequestionstatusbyid);
    var headers = {'Content-Type': 'application/json'};
    var body = json.encode({"status": "$status", "question_id": qid});
    http.put(url, headers: headers, body: body);
  }

  Future<void> deleteQuestionByID(iid) async {
    final url = Uri.parse('${Urls.deletequestionbyid}?iid=$iid');
    http.delete(url);
  }

  @override
  void initState() {
    fetchQuestions();
    super.initState();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  bool isminimized = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.forestgreen,
      // appBar: MyAppbar(title: "REVISION"),
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(0),
          bottomLeft: Radius.circular(1),
        ),
        child: Container(
          color: const Color.fromARGB(255, 63, 77, 67),
          child: Center(
            child: Column(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (isminimized) {
                        isminimized = false;
                      } else {
                        isminimized = true;
                      }
                    });
                  },
                  icon: Icon(
                    isminimized
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_up_rounded,
                    color: Colors.white,
                  ),
                ),
                isminimized
                    ? Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        0,
                                        5,
                                        0,
                                        3,
                                      ),
                                      child: Text(
                                        "CONTENT",
                                        style: GoogleFonts.jetBrainsMono(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    TextFormField(
                                      controller: _contentController,
                                      maxLines: null,
                                      style: TextStyle(color: Colors.white),
                                      cursorColor: Colors.white,
                                      decoration: InputDecoration(
                                        hintText:
                                            "Paste the content you want to revise....",
                                        hintStyle: TextStyle(
                                          color: Colors.white,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.white,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: TextFormField(
                                            controller: _contentDateController,
                                            readOnly: true,
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                            cursorColor: Colors.white,
                                            decoration: InputDecoration(
                                              suffixIcon: InkWell(
                                                onTap: () {
                                                  _selectDate(
                                                    context,
                                                    _contentDateController,
                                                  );
                                                },
                                                child: Icon(
                                                  Icons.calendar_month_rounded,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              label: Text("End Date"),
                                              labelStyle: TextStyle(
                                                color: Colors.white,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          flex: 1,
                                          child: TextFormField(
                                            controller:
                                                _contentRepetitionController,
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                            cursorColor: Colors.white,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                            decoration: InputDecoration(
                                              label: Text("Repetation"),
                                              labelStyle: TextStyle(
                                                color: Colors.white,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          flex: 1,
                                          child: TextFormField(
                                            controller:
                                                _contentQuestionCountController,
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                            cursorColor: Colors.white,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                            decoration: InputDecoration(
                                              label: Text("Questions"),
                                              labelStyle: TextStyle(
                                                color: Colors.white,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        0,
                                        8,
                                        0,
                                        0,
                                      ),
                                      child: SizedBox(
                                        width:
                                            double
                                                .infinity, // makes button full width
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            if (_contentController
                                                    .text
                                                    .isEmpty ||
                                                _contentDateController
                                                    .text
                                                    .isEmpty ||
                                                _contentRepetitionController
                                                    .text
                                                    .isEmpty ||
                                                _contentQuestionCountController
                                                    .text
                                                    .isEmpty) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  action: SnackBarAction(
                                                    label: 'Dismiss',
                                                    textColor: Colors.white,
                                                    onPressed: () {},
                                                  ),
                                                  content: Text(
                                                    "Please fill all the content fields",
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            DateTime parsedEndDate = DateFormat(
                                              'dd/MM/yyyy',
                                            ).parse(
                                              _contentDateController.text,
                                            );
                                            String formattedEndDate =
                                                DateFormat(
                                                  'dd-MM-yyyy',
                                                ).format(parsedEndDate);
                                            String formattedCreatedDate =
                                                DateFormat(
                                                  'dd-MM-yyyy',
                                                ).format(DateTime.now());
                                            var headers = {
                                              'Content-Type':
                                                  'application/json',
                                            };
                                            var request = http.Request(
                                              'POST',
                                              Uri.parse(Urls.addtopic),
                                            );
                                            request.body = json.encode({
                                              "content":
                                                  _contentController.text,
                                              "end_date": formattedEndDate,
                                              "created_date":
                                                  formattedCreatedDate,
                                              "frequency":
                                                  _contentRepetitionController
                                                      .text,
                                              "question_count":
                                                  _contentQuestionCountController
                                                      .text,
                                            });
                                            request.headers.addAll(headers);
                                            http.StreamedResponse response =
                                                await request.send();
                                            if (response.statusCode == 200) {
                                              print(
                                                await response.stream
                                                    .bytesToString(),
                                              );
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  action: SnackBarAction(
                                                    label: 'Dismiss',
                                                    textColor: Colors.white,
                                                    onPressed: () {},
                                                  ),
                                                  content: Text(
                                                    'Topic added successfully!',
                                                  ),
                                                ),
                                              );
                                              _contentController.clear();
                                              _contentDateController.clear();
                                              _contentRepetitionController
                                                  .clear();
                                              _contentQuestionCountController
                                                  .clear();
                                            } else {
                                              print(response.reasonPhrase);
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  action: SnackBarAction(
                                                    label: 'Dismiss',
                                                    textColor: Colors.white,
                                                    onPressed: () {},
                                                  ),
                                                  content: Text(
                                                    'Failed to add topic: ${response.reasonPhrase}',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color.fromARGB(
                                              255,
                                              34,
                                              44,
                                              38,
                                            ), // button color
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    4,
                                                  ), // rounded corners
                                            ),
                                          ),
                                          child: Text(
                                            "+ Add Acitivity",
                                            style: GoogleFonts.jetBrainsMono(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                child: Divider(color: Colors.white60),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        0,
                                        5,
                                        0,
                                        3,
                                      ),
                                      child: Text(
                                        "CUSTOM QUESTIONS",
                                        style: GoogleFonts.jetBrainsMono(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    TextFormField(
                                      controller: _customQuestionController,
                                      maxLines: null,
                                      style: TextStyle(color: Colors.white),
                                      cursorColor: Colors.white,
                                      decoration: InputDecoration(
                                        hintText: "Enter Your Question",
                                        hintStyle: TextStyle(
                                          color: Colors.white,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.white,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    TextFormField(
                                      controller:
                                          _customQuestionAnswerController,
                                      maxLines: null,
                                      style: TextStyle(color: Colors.white),
                                      cursorColor: Colors.white,
                                      decoration: InputDecoration(
                                        hintText: "Enter Your Answer",
                                        hintStyle: TextStyle(
                                          color: Colors.white,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.white,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: TextFormField(
                                            controller:
                                                _customQuestionDateController,
                                            readOnly: true,
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                            cursorColor: Colors.white,
                                            decoration: InputDecoration(
                                              suffixIcon: InkWell(
                                                onTap:
                                                    () => _selectDate(
                                                      context,
                                                      _customQuestionDateController,
                                                    ),
                                                child: Icon(
                                                  Icons.calendar_month_rounded,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              label: Text("End Date"),
                                              labelStyle: TextStyle(
                                                color: Colors.white,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ), // spacing between the two fields
                                        Expanded(
                                          flex: 1,
                                          child: TextFormField(
                                            controller:
                                                _customQuestionRepetitionController,
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                            cursorColor: Colors.white,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                            decoration: InputDecoration(
                                              label: Text("Repetation"),
                                              labelStyle: TextStyle(
                                                color: Colors.white,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        0,
                                        8,
                                        0,
                                        0,
                                      ),
                                      child: SizedBox(
                                        width:
                                            double
                                                .infinity, // makes button full width
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            if (_customQuestionController
                                                    .text
                                                    .isEmpty ||
                                                _customQuestionAnswerController
                                                    .text
                                                    .isEmpty ||
                                                _customQuestionDateController
                                                    .text
                                                    .isEmpty ||
                                                _customQuestionRepetitionController
                                                    .text
                                                    .isEmpty) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  action: SnackBarAction(
                                                    label: 'Dismiss',
                                                    textColor: Colors.white,
                                                    onPressed: () {},
                                                  ),
                                                  content: Text(
                                                    "Please fill all the question fields",
                                                  ),
                                                ),
                                              );
                                              return;
                                            }
                                            DateTime parsedDate = DateFormat(
                                              'dd/MM/yyyy',
                                            ).parse(
                                              _customQuestionDateController
                                                  .text,
                                            );
                                            String formattedDate = DateFormat(
                                              'dd-MM-yyyy',
                                            ).format(parsedDate);
                                            var headers = {
                                              'Content-Type':
                                                  'application/json',
                                            };
                                            var request = http.Request(
                                              'POST',
                                              Uri.parse(Urls.addquestion),
                                            );
                                            request.body = json.encode({
                                              "question":
                                                  _customQuestionController
                                                      .text,
                                              "answer":
                                                  _customQuestionAnswerController
                                                      .text,
                                              "end_date": formattedDate,
                                              "repetition":
                                                  _customQuestionRepetitionController
                                                      .text,
                                              "status": "active",
                                              "topic_id": "0",
                                            });
                                            request.headers.addAll(headers);
                                            http.StreamedResponse response =
                                                await request.send();
                                            if (response.statusCode == 200) {
                                              print(
                                                await response.stream
                                                    .bytesToString(),
                                              );
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  action: SnackBarAction(
                                                    label: 'Dismiss',
                                                    textColor: Colors.white,
                                                    onPressed: () {},
                                                  ),
                                                  content: Text(
                                                    'Question added successfully!',
                                                  ),
                                                ),
                                              );
                                              _customQuestionController.clear();
                                              _customQuestionAnswerController
                                                  .clear();
                                              _customQuestionDateController
                                                  .clear();
                                              _customQuestionRepetitionController
                                                  .clear();
                                              fetchQuestions();
                                            } else {
                                              print(response.reasonPhrase);
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  action: SnackBarAction(
                                                    label: 'Dismiss',
                                                    textColor: Colors.white,
                                                    onPressed: () {},
                                                  ),
                                                  content: Text(
                                                    'Failed to add question: ${response.reasonPhrase}',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color.fromARGB(
                                              255,
                                              34,
                                              44,
                                              38,
                                            ), // button color
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    4,
                                                  ), // rounded corners
                                            ),
                                          ),
                                          child: Text(
                                            "+ Add Question",
                                            style: GoogleFonts.jetBrainsMono(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    )
                    : SizedBox.shrink(),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Divider(thickness: 2)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "QUESTIONS",
                          style: GoogleFonts.jetBrainsMono(color: Colors.white),
                        ),
                      ),
                      Expanded(child: Divider(thickness: 2)),
                      Tooltip(
                        message: "Refresh List",
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: InkWell(
                            onTap: fetchQuestions,
                            child: Icon(Icons.refresh, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _questions.length,
                    itemBuilder: (context, index) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Make the main content take all remaining width
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Question
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "QUESTION:   ",
                                          style: GoogleFonts.jetBrainsMono(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(_questions[index]['question']),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "ANSWER:",
                                          style: GoogleFonts.jetBrainsMono(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SpoilerText(
                                          _questions[index]['answer'],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              Column(
                                children: [
                                  IconButton(
                                    tooltip: "On/Off",
                                    onPressed: () async {
                                      setState(() {
                                        _questions[index]['status'] =
                                            _questions[index]['status'] ==
                                                    "active"
                                                ? "off"
                                                : "active";
                                      });
                                      // Send update to server
                                      await updateQuestionByID(
                                        _questions[index]['id'],
                                        _questions[index]['status'],
                                      );
                                    },
                                    icon: Icon(
                                      _questions[index]['status'] == "active"
                                          ? Icons.check_box
                                          : Icons
                                              .check_box_outline_blank_rounded,
                                      color: Colors.black,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      await deleteQuestionByID(
                                        _questions[index]['id'],
                                      );
                                      setState(() {
                                        _questions.removeAt(index);
                                      });
                                    },
                                    tooltip: "Delete Question",
                                    icon: Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
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
      ),
    );
  }
}
