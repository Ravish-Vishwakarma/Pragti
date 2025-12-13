import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pragti/Data/urls.dart';
import 'package:pragti/Widgets/Cards/todocard.dart';
import 'package:pragti/Widgets/Dialog/tododialog.dart';
import 'package:pragti/Widgets/showsnackbar.dart';
import 'package:pragti/Widgets/style.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List _todo = [];
  List _filteredTodo = [];
  bool _isLoading = false;
  int cross_axis_count = 5;

  // Filter states
  String _selectedCategory = 'all';
  String _selectedPriority = 'all';
  String _selectedStatus = 'all';
  String _searchQuery = '';

  // bool _searchbar = false;
  Future<void> fetchTodos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(Urls.todo));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _todo = data;
          _applyFilters();
          _isLoading = false;
        });
      } else {
        ShowSnackbar.show(context, "Failed to load todos from API");
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

  void _applyFilters() {
    setState(() {
      _filteredTodo =
          _todo.where((todo) {
            // Category filter
            if (_selectedCategory != 'all' &&
                todo['category'].toString().toLowerCase() !=
                    _selectedCategory) {
              return false;
            }

            // Priority filter
            if (_selectedPriority != 'all' &&
                todo['priority'].toString().toLowerCase() !=
                    _selectedPriority) {
              return false;
            }

            // Status filter
            if (_selectedStatus != 'all' &&
                todo['status'].toString().toLowerCase() != _selectedStatus) {
              return false;
            }

            // Search filter
            if (_searchQuery.isNotEmpty) {
              final searchLower = _searchQuery.toLowerCase();
              final titleMatch = todo['title']
                  .toString()
                  .toLowerCase()
                  .contains(searchLower);
              final descMatch = todo['description']
                  .toString()
                  .toLowerCase()
                  .contains(searchLower);
              return titleMatch || descMatch;
            }

            return true;
          }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = 'all';
      _selectedPriority = 'all';
      _selectedStatus = 'all';
      _searchQuery = '';
      _applyFilters();
    });
  }

  final TextEditingController _categoryController = TextEditingController();

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Filters",
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _resetFilters();
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.refresh),
                          tooltip: "Reset Filters",
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Category Filter
                    Text(
                      "Category",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _categoryController,
                            decoration: InputDecoration(
                              labelText: 'Enter category',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(
                              255,
                              34,
                              44,
                              38,
                            ), // button color
                            borderRadius: BorderRadius.circular(
                              4,
                            ), // rounded corners
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.check, color: Colors.white),
                            onPressed: () {
                              final cat =
                                  _categoryController.text.trim().toLowerCase();
                              if (cat.isNotEmpty) {
                                setModalState(() => _selectedCategory = cat);
                                setState(() {
                                  _selectedCategory = cat;
                                  _applyFilters();
                                  _categoryController.clear();
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Priority Filter
                    Text(
                      "Priority",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          ['all', 'high', 'medium', 'low']
                              .map(
                                (priority) => FilterChip(
                                  label: Text(capitalizeFirstLetter(priority)),
                                  selected: _selectedPriority == priority,
                                  onSelected: (selected) {
                                    setModalState(() {
                                      _selectedPriority = priority;
                                    });
                                    setState(() {
                                      _selectedPriority = priority;
                                      _applyFilters();
                                    });
                                  },
                                  selectedColor:
                                      priority == 'high'
                                          ? Colors.red.shade200
                                          : priority == 'medium'
                                          ? Colors.orange.shade200
                                          : priority == 'low'
                                          ? Colors.green.shade200
                                          : Colors.grey.shade200,
                                ),
                              )
                              .toList(),
                    ),
                    SizedBox(height: 16),

                    // Status Filter
                    Text(
                      "Status",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          ['all', 'pending', 'done']
                              .map(
                                (status) => FilterChip(
                                  label: Text(capitalizeFirstLetter(status)),
                                  selected: _selectedStatus == status,
                                  onSelected: (selected) {
                                    setModalState(() {
                                      _selectedStatus = status;
                                    });
                                    setState(() {
                                      _selectedStatus = status;
                                      _applyFilters();
                                    });
                                  },
                                  selectedColor:
                                      status == 'done'
                                          ? Colors.green.shade200
                                          : status == 'pending'
                                          ? Colors.orange.shade200
                                          : Colors.grey.shade200,
                                ),
                              )
                              .toList(),
                    ),
                    SizedBox(height: 20),

                    // Apply Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Apply Filters",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              );
            },
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchTodos();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    cross_axis_count = max(1, (screenWidth / 350).toInt());
    int activeFilters = 0;
    if (_selectedCategory != 'all') activeFilters++;
    if (_selectedPriority != 'all') activeFilters++;
    if (_selectedStatus != 'all') activeFilters++;
    if (_searchQuery.isNotEmpty) activeFilters++;
    return Scaffold(
      floatingActionButton: FloatingActionButton.small(
        onPressed: () async {
          showTodoDialog(
            context,
            onTaskCreated: (data) {
              // Reload the list after creating a task
              fetchTodos();
            },
          );
        },

        backgroundColor: MyColors.palebeige,
        child: const Icon(Icons.add),
      ),
      body: Container(
        color: Color.fromARGB(255, 63, 77, 67),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // _searchbar
                  //     ?
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                            _applyFilters();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Search tasks...",
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          suffixIcon:
                              _searchQuery.isNotEmpty
                                  ? IconButton(
                                    icon: Icon(Icons.clear, color: Colors.grey),
                                    onPressed: () {
                                      setState(() {
                                        _searchQuery = '';
                                        _applyFilters();
                                      });
                                    },
                                  )
                                  : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ),
                  // : Expanded(
                  //   key: Key("ai_field"),
                  //   child: Container(
                  //     padding: EdgeInsets.all(16),
                  //     child: TextField(
                  //       decoration: InputDecoration(
                  //         hintText: "Describe Your Task",
                  //         prefixIcon: Padding(
                  //           padding: const EdgeInsets.all(8.0),
                  //           child: SvgPicture.asset(
                  //             "assets/Icons/svg/ai_star.svg",
                  //             color: Colors.grey[800],
                  //             width: 10,
                  //             height: 10,
                  //           ),
                  //         ),
                  //         suffixIcon: IconButton(
                  //           icon: Icon(Icons.send, color: Colors.grey),
                  //           onPressed: () {},
                  //         ),
                  //         filled: true,
                  //         fillColor: Colors.white,
                  //         border: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(12),
                  //           borderSide: BorderSide.none,
                  //         ),
                  //         contentPadding: EdgeInsets.symmetric(
                  //           vertical: 12,
                  //         ),
                  //       ),
                  //       style: GoogleFonts.poppins(),
                  //     ),
                  //   ),
                  // ),
                  // IconButton(
                  //   onPressed: () {
                  //     setState(() {
                  //       if (_searchbar) {
                  //         _searchbar = false;
                  //       } else {
                  //         _searchbar = true;
                  //       }
                  //     });
                  //   },
                  //   color: Colors.white,

                  //   icon: Icon(
                  //     _searchbar ? Icons.close_rounded : Icons.search_rounded,
                  //     color: Colors.white,
                  //   ),
                  //   tooltip:
                  //       _searchbar ? 'Switch To AI Mode' : 'Switch To Search',
                  // ),
                  IconButton(
                    icon: Icon(Icons.refresh_rounded, color: Colors.white),
                    color: Colors.white,
                    onPressed: () {
                      fetchTodos();
                    },
                  ),
                  IconButton(
                    color: Colors.white,
                    icon:
                        activeFilters > 0
                            ? Icon(Icons.error, color: Colors.red)
                            : Icon(Icons.filter_list, color: Colors.white),
                    onPressed: () {
                      _showFilterBottomSheet();
                    },
                  ),
                ],
              ),
            ),

            // -------------------------------------- Active Filters Chips -------------------------------------- //
            if (activeFilters > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (_selectedCategory != 'all')
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text(capitalizeFirstLetter(_selectedCategory)),
                          deleteIcon: Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _selectedCategory = 'all';
                              _applyFilters();
                            });
                          },
                          backgroundColor: Colors.blue.shade100,
                        ),
                      ),
                    if (_selectedPriority != 'all')
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text(capitalizeFirstLetter(_selectedPriority)),
                          deleteIcon: Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _selectedPriority = 'all';
                              _applyFilters();
                            });
                          },
                          backgroundColor: Colors.orange.shade100,
                        ),
                      ),
                    if (_selectedStatus != 'all')
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text(capitalizeFirstLetter(_selectedStatus)),
                          deleteIcon: Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _selectedStatus = 'all';
                              _applyFilters();
                            });
                          },
                          backgroundColor: Colors.green.shade100,
                        ),
                      ),
                  ],
                ),
              ),

            // -------------------------------------- List View -------------------------------------- //
            Expanded(
              child:
                  _isLoading
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                MyColors.almostwhite,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Loading tasks...",
                              style: GoogleFonts.jetBrainsMono(
                                textStyle: TextStyle(
                                  fontSize: 14,
                                  color: MyColors.almostwhite,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      : _filteredTodo.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              activeFilters > 0
                                  ? Icons.filter_list_off
                                  : Icons.task_alt,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 16),
                            Text(
                              activeFilters > 0
                                  ? "No tasks match your filters"
                                  : "No ToDo!",
                              style: GoogleFonts.jetBrainsMono(
                                textStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: MyColors.almostwhite,
                                ),
                              ),
                            ),
                            if (activeFilters > 0)
                              TextButton(
                                onPressed: _resetFilters,
                                child: Text(
                                  "Clear Filters",
                                  style: GoogleFonts.poppins(
                                    color: Colors.blue.shade200,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                      : RefreshIndicator(
                        onRefresh: fetchTodos,
                        color: MyColors.forestgreen,
                        child: MasonryGridView.count(
                          padding: const EdgeInsets.all(8),
                          crossAxisCount: cross_axis_count,
                          mainAxisSpacing: 0,
                          crossAxisSpacing: 0,

                          itemCount: _filteredTodo.length,
                          itemBuilder: (context, index) {
                            var todo = _filteredTodo[index];
                            return ToDoCard(
                              key: ValueKey(todo['id']),
                              id: todo['id'].toString(),
                              status: todo['status'],
                              title: todo['title'],
                              description: todo['description'],
                              note: todo['note'],
                              priority: todo['priority'],
                              category: todo['category'],
                              due_date: todo['due_date'],
                              due_time: todo['due_time'],
                              onStatusChanged: () {
                                var newstatus = "done";
                                if (todo['status'] == "done") {
                                  newstatus = "pending";
                                }
                                _todo[index]["status"] = newstatus;
                              },
                              onDelete: () {
                                _todo.removeAt(index);
                              },
                            );
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
