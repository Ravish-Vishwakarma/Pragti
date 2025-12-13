import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pragti/Data/urls.dart';
import 'package:pragti/Widgets/Dialog/taskmanagerdialog.dart';
import 'package:pragti/Widgets/style.dart';

class TaskManagerPage extends StatefulWidget {
  const TaskManagerPage({super.key});

  @override
  State<TaskManagerPage> createState() => _TaskManagerPageState();
}

class _TaskManagerPageState extends State<TaskManagerPage> {
  TextEditingController _searchcontroller = TextEditingController();
  List _processlist = [];
  List _blockprocesslist = [];

  Future<void> getprocesses() async {
    final response = await http.get(Uri.parse(Urls.getprocesses));
    if (response.statusCode == 200) {
      _processlist = jsonDecode(response.body);
    }
  }

  Future<void> getblockprocesses() async {
    final response = await http.get(Uri.parse(Urls.getblockprocesses));
    if (response.statusCode == 200) {
      _blockprocesslist = jsonDecode(response.body);
    }
  }

  @override
  void initState() {
    getprocesses();
    getblockprocesses();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.forestgreen,
      // appBar: MyAppbar(title: "TASK MANAGER"),
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
                SizedBox(height: 8),

                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Row(
                                children: [
                                  Expanded(child: Divider()),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      "ALL APPS",
                                      style: GoogleFonts.jetBrainsMono(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Divider()),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: SearchBar(
                                      constraints: const BoxConstraints(
                                        minHeight: 45, // set lower height
                                        maxHeight: 45,
                                      ),
                                      controller: _searchcontroller,
                                      backgroundColor: WidgetStateProperty.all(
                                        MyColors.forestgreen,
                                      ),
                                      leading: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          8,
                                          0,
                                          0,
                                          0,
                                        ),
                                        child: Icon(
                                          Icons.search,
                                          color: MyColors.beige,
                                        ),
                                      ),
                                      hintText: "Search Events",
                                      hintStyle: WidgetStateProperty.all(
                                        TextStyle(color: MyColors.beige),
                                      ),
                                      textStyle: WidgetStateProperty.all(
                                        TextStyle(color: MyColors.beige),
                                      ),
                                      shape: WidgetStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                      trailing: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.clear,
                                            color: MyColors.beige,
                                          ),
                                          onPressed: () {
                                            _searchcontroller.clear();
                                          },
                                          tooltip: "Clear Query",
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.refresh,
                                    color: MyColors.beige,
                                  ),
                                  onPressed: () {
                                    getprocesses();
                                  },
                                  tooltip: "Reload Data",
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Expanded(
                              child: ListView.builder(
                                itemCount: _processlist.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 8,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: Colors.white,
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          _processlist[index],
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        trailing: IconButton(
                                          tooltip: "Add To Block List",
                                          onPressed: () async {
                                            await showTaskManagerDialog(
                                              context,
                                              _processlist[index],
                                            );
                                            getblockprocesses();
                                          },
                                          icon: Icon(
                                            Icons.block_rounded,
                                            color: Colors.red,
                                          ),
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

                      Expanded(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Row(
                                children: [
                                  Expanded(child: Divider()),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      "BLOCKED APPS",
                                      style: GoogleFonts.jetBrainsMono(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Divider()),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: _blockprocesslist.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 8,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: Colors.white,
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          _blockprocesslist[index]["process"],
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        subtitle: Text(
                                          _blockprocesslist[index]["message"],
                                        ),
                                        trailing: IconButton(
                                          tooltip: "Remove",
                                          onPressed: () {},
                                          icon: Icon(
                                            Icons.cancel_rounded,
                                            color: Colors.red,
                                          ),
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
                    ],
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
