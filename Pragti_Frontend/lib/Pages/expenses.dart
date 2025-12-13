import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pragti/Data/urls.dart';
import 'package:pragti/Widgets/Cards/expensecard.dart';
import 'package:pragti/Widgets/showsnackbar.dart';
import 'package:pragti/Widgets/style.dart';

// Import the ExpenseCard widget
class Expensespage extends StatefulWidget {
  const Expensespage({super.key});
  @override
  State<Expensespage> createState() => _ExpensespageState();
}

class _ExpensespageState extends State<Expensespage> {
  List _expenses = [];
  List _filteredExpenses = [];
  bool _isLoading = false;
  // Filter states
  String _selectedCategory = 'all';
  String _selectedType = 'all';
  String _searchQuery = '';
  DateTimeRange? _dateRange;
  // Statistics
  double _totalIncome = 0;
  double _totalExpense = 0;
  double _balance = 0;
  final TextEditingController _categoryController = TextEditingController();

  Future<void> fetchExpenses() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(Urls.expenses));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _expenses = data;
          _calculateTotals();
          _applyFilters();
          _isLoading = false;
        });
      } else {
        ShowSnackbar.show(context, "Failed to load expenses from API");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {},
          ),
          content: Text("Error loading expenses: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _calculateTotals() {
    _totalIncome = 0;
    _totalExpense = 0;
    for (var expense in _expenses) {
      if (expense['type'].toString().toLowerCase() == 'income') {
        _totalIncome += (expense['money'] ?? 0);
      } else {
        _totalExpense += (expense['money'] ?? 0);
      }
    }
    _balance = _totalIncome - _totalExpense;
  }

  void _applyFilters() {
    setState(() {
      _filteredExpenses =
          _expenses.where((expense) {
            if (_selectedType != 'all' &&
                expense['type'].toString().toLowerCase() != _selectedType) {
              return false;
            }
            if (_selectedCategory != 'all' &&
                expense['category'].toString().toLowerCase() !=
                    _selectedCategory) {
              return false;
            }
            if (_dateRange != null) {
              try {
                final expenseDate = DateFormat(
                  'yyyy-MM-dd',
                ).parse(expense['date']);
                if (expenseDate.isBefore(_dateRange!.start) ||
                    expenseDate.isAfter(_dateRange!.end)) {
                  return false;
                }
              } catch (e) {
                return false;
              }
            }
            if (_searchQuery.isNotEmpty) {
              final searchLower = _searchQuery.toLowerCase();
              final titleMatch = expense['title']
                  .toString()
                  .toLowerCase()
                  .contains(searchLower);
              final descMatch = expense['description']
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
      _selectedType = 'all';
      _searchQuery = '';
      _dateRange = null;
      _applyFilters();
    });
  }

  Future<void> _deleteExpense(int id) async {
    try {
      final response = await http.delete(Uri.parse('${Urls.expenses}/$id'));
      if (response.statusCode == 200) {
        fetchExpenses();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text("Transaction deleted successfully!"),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ShowSnackbar.show(context, 'Failed to delete');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {},
          ),
          content: Text("Error deleting: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _editExpense(Map<String, dynamic> expense) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: expense['title']);
    final descriptionController = TextEditingController(
      text: expense['description'],
    );
    final moneyController = TextEditingController(
      text: expense['money'].toString(),
    );
    final categoryController = TextEditingController(text: expense['category']);
    String selectedType = expense['type'];
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                constraints: BoxConstraints(maxWidth: 500, maxHeight: 700),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color:
                            selectedType == 'income'
                                ? Colors.green.shade400
                                : Colors.red.shade400,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.white, size: 28),
                          SizedBox(width: 12),
                          Text(
                            "Edit Transaction",
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(20),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Type Selection
                              Text(
                                "Type",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedType = 'expense';
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color:
                                              selectedType == 'expense'
                                                  ? Colors.red.shade100
                                                  : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color:
                                                selectedType == 'expense'
                                                    ? Colors.red
                                                    : Colors.grey.shade300,
                                            width: 2,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.remove_circle_outline,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "Expense",
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedType = 'income';
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color:
                                              selectedType == 'income'
                                                  ? Colors.green.shade100
                                                  : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color:
                                                selectedType == 'income'
                                                    ? Colors.green
                                                    : Colors.grey.shade300,
                                            width: 2,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_circle_outline,
                                              color: Colors.green,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "Income",
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              // Title
                              TextFormField(
                                controller: titleController,
                                decoration: InputDecoration(
                                  labelText: "Title",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter a title";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              // Amount
                              TextFormField(
                                controller: moneyController,
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: InputDecoration(
                                  labelText: "Amount",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter amount";
                                  }
                                  if (double.tryParse(value) == null) {
                                    return "Please enter valid number";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              // Category
                              TextFormField(
                                controller: categoryController,
                                decoration: InputDecoration(
                                  labelText: "Category",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter a category";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              // Description
                              TextFormField(
                                controller: descriptionController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  labelText: "Description",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Cancel"),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                final updateData = {
                                  'title': titleController.text,
                                  'description': descriptionController.text,
                                  'money': double.parse(moneyController.text),
                                  'type': selectedType,
                                  'category': categoryController.text,
                                };
                                Navigator.pop(context);
                                try {
                                  final response = await http.put(
                                    Uri.parse(
                                      '${Urls.expenses}/${expense['id']}',
                                    ),
                                    headers: {
                                      'Content-Type': 'application/json',
                                    },
                                    body: json.encode(updateData),
                                  );
                                  if (response.statusCode == 200) {
                                    fetchExpenses();
                                    ScaffoldMessenger.of(
                                      this.context,
                                    ).showSnackBar(
                                      SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        action: SnackBarAction(
                                          label: 'Dismiss',
                                          textColor: Colors.white,
                                          onPressed: () {},
                                        ),
                                        content: Text(
                                          "Transaction updated successfully!",
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(
                                    this.context,
                                  ).showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      action: SnackBarAction(
                                        label: 'Dismiss',
                                        textColor: Colors.white,
                                        onPressed: () {},
                                      ),
                                      content: Text("Error: $e"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: Text("Update"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

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
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Type Filter
                    Text(
                      "Type",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          ['all', 'income', 'expense']
                              .map(
                                (type) => FilterChip(
                                  label: Text(capitalizeFirstLetter(type)),
                                  selected: _selectedType == type,
                                  onSelected: (selected) {
                                    setModalState(() => _selectedType = type);
                                    setState(() {
                                      _selectedType = type;
                                      _applyFilters();
                                    });
                                  },
                                  selectedColor:
                                      type == 'income'
                                          ? Colors.green.shade200
                                          : type == 'expense'
                                          ? Colors.red.shade200
                                          : Colors.grey.shade200,
                                ),
                              )
                              .toList(),
                    ),
                    SizedBox(height: 16),
                    // Category Filter
                    Text(
                      "Category",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
                    // Date Range Filter
                    Text(
                      "Date Range",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                          initialDateRange: _dateRange,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Colors.blue,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setModalState(() {
                            _dateRange = picked;
                          });
                          setState(() {
                            _dateRange = picked;
                            _applyFilters();
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade50,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _dateRange != null
                                    ? '${DateFormat('MMM dd, yyyy').format(_dateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_dateRange!.end)}'
                                    : 'Select date range',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color:
                                      _dateRange != null
                                          ? Colors.black87
                                          : Colors.grey.shade600,
                                ),
                              ),
                            ),
                            Icon(Icons.calendar_today, size: 18),
                          ],
                        ),
                      ),
                    ),
                    if (_dateRange != null) ...[
                      SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            setModalState(() {
                              _dateRange = null;
                            });
                            setState(() {
                              _dateRange = null;
                              _applyFilters();
                            });
                          },
                          icon: Icon(Icons.clear, size: 16),
                          label: Text("Clear Date Range"),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
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

  void _showAddExpenseDialog() {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final moneyController = TextEditingController();
    final categoryController = TextEditingController();
    String selectedType = "expense";
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                constraints: BoxConstraints(maxWidth: 500, maxHeight: 700),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color:
                            selectedType == 'income'
                                ? Colors.green.shade400
                                : Colors.red.shade400,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Add ${capitalizeFirstLetter(selectedType)}",
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(20),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Type Selection
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedType = 'expense';
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color:
                                              selectedType == 'expense'
                                                  ? Colors.red.shade100
                                                  : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color:
                                                selectedType == 'expense'
                                                    ? Colors.red
                                                    : Colors.grey.shade300,
                                            width: 2,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.remove_circle_outline,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "Expense",
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedType = 'income';
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color:
                                              selectedType == 'income'
                                                  ? Colors.green.shade100
                                                  : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color:
                                                selectedType == 'income'
                                                    ? Colors.green
                                                    : Colors.grey.shade300,
                                            width: 2,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_circle_outline,
                                              color: Colors.green,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "Income",
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              // Title
                              TextFormField(
                                controller: titleController,
                                decoration: InputDecoration(
                                  labelText: "Title",
                                  prefixIcon: Icon(Icons.title),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter a title";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              // Amount
                              TextFormField(
                                controller: moneyController,
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: InputDecoration(
                                  labelText: "Amount",
                                  prefixIcon: Icon(Icons.attach_money),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter amount";
                                  }
                                  if (double.tryParse(value) == null) {
                                    return "Please enter valid number";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              // Category
                              TextFormField(
                                controller: categoryController,
                                decoration: InputDecoration(
                                  labelText: "Category",
                                  prefixIcon: Icon(Icons.category),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter a category";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              // Description
                              TextFormField(
                                controller: descriptionController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  labelText: "Description (Optional)",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              // Date and Time
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime.now().add(
                                            Duration(days: 365),
                                          ),
                                        );
                                        if (date != null) {
                                          setState(() {
                                            selectedDate = date;
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              selectedDate != null
                                                  ? DateFormat(
                                                    'MMM dd, yyyy',
                                                  ).format(selectedDate!)
                                                  : "Select Date",
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                              ),
                                            ),
                                            Icon(
                                              Icons.calendar_today,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        );
                                        if (time != null) {
                                          setState(() {
                                            selectedTime = time;
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              selectedTime != null
                                                  ? selectedTime!.format(
                                                    context,
                                                  )
                                                  : "Select Time",
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                              ),
                                            ),
                                            Icon(Icons.access_time, size: 18),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Cancel"),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                if (selectedDate == null ||
                                    selectedTime == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      action: SnackBarAction(
                                        label: 'Dismiss',
                                        textColor: Colors.white,
                                        onPressed: () {},
                                      ),
                                      content: Text(
                                        "Please select date and time",
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }
                                final expenseData = {
                                  'title': titleController.text,
                                  'description': descriptionController.text,
                                  'money': double.parse(moneyController.text),
                                  'type': selectedType,
                                  'category': categoryController.text,
                                  'date': DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(selectedDate!),
                                  'time':
                                      '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                                };
                                Navigator.pop(context);
                                try {
                                  final response = await http.post(
                                    Uri.parse(Urls.expenses),
                                    headers: {
                                      'Content-Type': 'application/json',
                                    },
                                    body: json.encode(expenseData),
                                  );
                                  if (response.statusCode == 200 ||
                                      response.statusCode == 201) {
                                    fetchExpenses();
                                    ScaffoldMessenger.of(
                                      this.context,
                                    ).showSnackBar(
                                      SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        action: SnackBarAction(
                                          label: 'Dismiss',
                                          textColor: Colors.white,
                                          onPressed: () {},
                                        ),
                                        content: Text("Added successfully!"),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(
                                    this.context,
                                  ).showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      action: SnackBarAction(
                                        label: 'Dismiss',
                                        textColor: Colors.white,
                                        onPressed: () {},
                                      ),
                                      content: Text("Error: $e"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  selectedType == 'income'
                                      ? Colors.green
                                      : Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: Text("Add"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchExpenses();
  }

  @override
  Widget build(BuildContext context) {
    int activeFilters = 0;
    if (_selectedCategory != 'all') activeFilters++;
    if (_selectedType != 'all') activeFilters++;
    if (_dateRange != null) activeFilters++;
    if (_searchQuery.isNotEmpty) activeFilters++;
    return Scaffold(
      backgroundColor: MyColors.forestgreen,
      appBar: AppBar(
        backgroundColor: MyColors.forestgreen,

        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  "Balance: ",
                  style: GoogleFonts.jetBrainsMono(color: Colors.white),
                ),
                Text(
                  "\$$_balance",
                  style: GoogleFonts.jetBrainsMono(
                    color: _balance >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_downward_rounded, color: Colors.red),
                        Text(
                          "\$$_totalExpense",
                          style: GoogleFonts.jetBrainsMono(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_upward_rounded, color: Colors.green),
                        Text(
                          "\$$_totalIncome",
                          style: GoogleFonts.jetBrainsMono(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          activeFilters > 0
              ? IconButton(
                onPressed: _showFilterBottomSheet,
                icon: Icon(Icons.error),
                color: Colors.red,
              )
              : IconButton(
                onPressed: _showFilterBottomSheet,
                color: Colors.white,
                icon: Icon(Icons.filter_list),
              ),
        ],
      ),
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
              SizedBox(height: 8),
              // Search Bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _applyFilters();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search transactions...",
                    prefixIcon: Icon(Icons.search),
                    suffixIcon:
                        _searchQuery.isNotEmpty
                            ? IconButton(
                              icon: Icon(Icons.clear),
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
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              // Active Filters
              if (activeFilters > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      if (_selectedType != 'all')
                        Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text(capitalizeFirstLetter(_selectedType)),
                            deleteIcon: Icon(Icons.close, size: 18),
                            onDeleted: () {
                              setState(() {
                                _selectedType = 'all';
                                _applyFilters();
                              });
                            },
                            backgroundColor:
                                _selectedType == 'income'
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                          ),
                        ),
                      if (_selectedCategory != 'all')
                        Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text(
                              capitalizeFirstLetter(_selectedCategory),
                            ),
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
                      if (_dateRange != null)
                        Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text(
                              '${DateFormat('MMM dd').format(_dateRange!.start)} - ${DateFormat('MMM dd').format(_dateRange!.end)}',
                            ),
                            deleteIcon: Icon(Icons.close, size: 18),
                            onDeleted: () {
                              setState(() {
                                _dateRange = null;
                                _applyFilters();
                              });
                            },
                            backgroundColor: Colors.purple.shade100,
                          ),
                        ),
                    ],
                  ),
                ),
              // Transactions List with ExpenseCard
              Expanded(
                child:
                    _isLoading
                        ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              MyColors.almostwhite,
                            ),
                          ),
                        )
                        : _filteredExpenses.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 16),
                              Text(
                                activeFilters > 0
                                    ? "No transactions match filters"
                                    : "No transactions yet!",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: MyColors.almostwhite,
                                ),
                              ),
                              if (activeFilters > 0)
                                TextButton(
                                  onPressed: _resetFilters,
                                  child: Text("Clear Filters"),
                                ),
                            ],
                          ),
                        )
                        : ShaderMask(
                          shaderCallback: (rect) {
                            return LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: const [Colors.transparent, Colors.green],
                              stops: const [0.0, 0.020],
                            ).createShader(rect);
                          },
                          blendMode: BlendMode.dstIn,
                          child: ListView.builder(
                            itemCount: _filteredExpenses.length,
                            itemBuilder: (context, index) {
                              var expense = _filteredExpenses[index];
                              return ExpenseCard(
                                id: expense['id'].toString(),
                                title: expense['title'],
                                description: expense['description'],
                                money: expense['money'].toDouble(),
                                type: expense['type'],
                                category: expense['category'],
                                date: expense['date'],
                                time: expense['time'],
                                onDelete: () => _deleteExpense(expense['id']),
                                onEdit: () => _editExpense(expense),
                              );
                            },
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: _showAddExpenseDialog,
        backgroundColor: MyColors.darkgreen,
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Icon(Icons.add, size: 25, color: Colors.white),
      ),
    );
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
