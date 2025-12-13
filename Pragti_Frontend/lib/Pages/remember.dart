import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pragti/Data/urls.dart';
import 'package:pragti/Widgets/Dialog/rememberdialog.dart';
import 'package:pragti/Widgets/Cards/remembercards.dart';
import 'package:pragti/Widgets/showsnackbar.dart';
import 'package:pragti/Widgets/style.dart';

class RememberPage extends StatefulWidget {
  const RememberPage({super.key});

  @override
  State<RememberPage> createState() => _RememberPageState();
}

class _RememberPageState extends State<RememberPage> {
  final TextEditingController _searchcontroller = TextEditingController();

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(Urls.remember));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        _allRememberData = data; // Keep full copy
        _rememberdata = data; // This is what we show
      });
    } else {
      ShowSnackbar.show(context, 'Failed to load remember data');
    }
  }

  Future<void> _deleteFromServer(int id) async {
    final url = Uri.parse('http://127.0.0.1:8000/remember/delete?rid=$id');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      // Successfully deleted
    } else {
      ShowSnackbar.show(context, 'Failed to delete item with id $id');
    }
  }

  Future<void> _updateDataOnServer(Map<String, dynamic> updatedData) async {
    final url = Uri.parse('http://127.0.0.1:8000/remember/update');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': updatedData['id'],
        'title': updatedData['title'],
        'content': updatedData['content'],
      }),
    );

    if (response.statusCode == 200) {
      // Successfully updated
    } else {
      ShowSnackbar.show(
        context,
        'Failed to update item with id ${updatedData['id']}',
      );
    }
  }

  List _rememberdata = []; // Displayed list
  List _allRememberData = []; // Full list from server

  @override
  void initState() {
    super.initState();
    fetchData();

    _searchcontroller.addListener(() {
      final query = _searchcontroller.text.toLowerCase();
      setState(() {
        _rememberdata =
            _allRememberData.where((item) {
              final title = (item['title'] ?? '').toLowerCase();
              final content = (item['content'] ?? '').toLowerCase();
              return title.contains(query) || content.contains(query);
            }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.forestgreen,
      // appBar: MyAppbar(title: "REMEMBER"),
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(0),
          bottomLeft: Radius.circular(1),
        ),
        child: Container(
          color: const Color.fromARGB(255, 63, 77, 67),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SearchBar(
                        controller: _searchcontroller,
                        backgroundColor: WidgetStateProperty.all(
                          MyColors.forestgreen,
                        ),
                        leading: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                          child: Icon(Icons.search, color: MyColors.beige),
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
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        trailing: [
                          IconButton(
                            icon: Icon(Icons.clear, color: MyColors.beige),
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
                    icon: Icon(Icons.refresh, color: MyColors.beige),
                    onPressed: () {
                      fetchData();
                    },
                    tooltip: "Reload Data",
                  ),
                ],
              ),
              Expanded(
                child:
                    _rememberdata.isEmpty
                        ? const Text("No Events")
                        : ListView.builder(
                          itemCount: _rememberdata.length,
                          itemBuilder: (context, index) {
                            return RememberCard(
                              data: _rememberdata[index],
                              onEdit: () async {
                                final currentItem = _rememberdata[index];

                                // Open dialog pre-filled with existing data
                                final updated = await showRememberDialog(
                                  context,
                                  existingData: currentItem,
                                );

                                if (updated != null) {
                                  await _updateDataOnServer(updated);
                                  setState(() {
                                    _rememberdata[index] = updated;
                                  });
                                }
                              },
                              onDelete: () async {
                                final id = _rememberdata[index]['id'];

                                final confirm = await showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text("Delete this item?"),
                                        content: Text(
                                          "Are you sure you want to delete '${_rememberdata[index]['title']}'?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadiusGeometry.circular(5),
                                        ),
                                      ),
                                );

                                if (confirm == true) {
                                  await _deleteFromServer(id);
                                  setState(() => _rememberdata.removeAt(index));
                                }
                              },
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: MyColors.forestgreen,
        tooltip: "Add",
        onPressed: () {
          showRememberDialog(context);
        },
        child: Icon(Icons.add, color: MyColors.beige),
      ),
    );
  }
}
