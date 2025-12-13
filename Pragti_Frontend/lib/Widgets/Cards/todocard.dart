import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pragti/Data/urls.dart';
import 'package:pragti/Widgets/showsnackbar.dart';

class ToDoCard extends StatefulWidget {
  final String id;
  final String status;
  final String title;
  final String description;
  final String note;
  final String priority;
  final String category;
  final String due_date;
  final String due_time;
  final VoidCallback? onStatusChanged;
  final VoidCallback? onDelete;

  const ToDoCard({
    super.key,
    required this.id,
    required this.status,
    required this.title,
    required this.description,
    required this.note,
    required this.priority,
    required this.category,
    required this.due_date,
    required this.due_time,
    this.onStatusChanged,
    this.onDelete,
  });

  @override
  _ToDoCardState createState() => _ToDoCardState();
}

class _ToDoCardState extends State<ToDoCard> {
  bool isExpanded = false;
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    isCompleted = widget.status.toLowerCase() == 'done';
  }

  Color _getPriorityColor() {
    switch (widget.priority.toLowerCase()) {
      case 'high':
        return Colors.red.shade400;
      case 'medium':
        return Colors.orange.shade400;
      case 'low':
        return Colors.green.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  Future<void> deletetodo(id) async {
    final url = Uri.parse("${Urls.deletetodo}$id");
    final response = await http.delete(url);
    if (response.statusCode == 200) {
      widget.onDelete?.call();
    } else {
      ShowSnackbar.show(context, "Unable To Delete Todo");
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.category.toLowerCase()) {
      case 'work':
        return Icons.work_outline;
      case 'personal':
        return Icons.person_outline;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'health':
        return Icons.favorite_outline;
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
      child: Card(
        elevation: isExpanded ? 8 : 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          onTap: () => setState(() => isExpanded = !isExpanded),
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: _getPriorityColor().withOpacity(0.08),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getPriorityColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getCategoryIcon(),
                              color: _getPriorityColor(),
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    decoration:
                                        isCompleted
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                    color:
                                        isCompleted
                                            ? Colors.grey
                                            : Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getPriorityColor().withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    widget.priority.toUpperCase(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: _getPriorityColor(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final newStatus = isCompleted ? "pending" : "done";

                        setState(() => isCompleted = !isCompleted);

                        var url =
                            "${Urls.toggletodo}?todo_id=${widget.id}&status=$newStatus";

                        final response = await http.patch(Uri.parse(url));

                        if (response.statusCode == 200) {
                          widget.onStatusChanged
                              ?.call(); // <-- THIS IS WHERE IT GOES
                        } else {
                          ShowSnackbar.show(
                            context,
                            "Problem Updating Todo Status",
                          );
                        }
                      },
                      icon: Icon(
                        isCompleted
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: isCompleted ? Colors.green : Colors.grey,
                        size: 28,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Description
                Row(
                  children: [
                    Icon(
                      Icons.subject_rounded,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.description,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: isExpanded ? null : 1,
                        overflow: isExpanded ? null : TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Date and Time Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.blue.shade700,
                            ),
                            SizedBox(width: 6),
                            Text(
                              widget.due_date,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.purple.shade700,
                            ),
                            SizedBox(width: 6),
                            Text(
                              widget.due_time,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.purple.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Expanded Content
                AnimatedCrossFade(
                  firstChild: SizedBox.shrink(),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                          // IconButton(
                          //   tooltip: "Edit Todo",
                          //   onPressed: () {},
                          //   icon: Icon(Icons.edit),
                          // ),
                          IconButton(
                            tooltip: "Delete Todo",
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: Text(
                                        "Delete Todo",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: Text(
                                        "Are you sure you want to delete this task?",
                                        style: GoogleFonts.poppins(),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: Text("Cancel"),
                                        ),
                                        ElevatedButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red[400],
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                          ),
                                          child: Text("Delete"),
                                        ),
                                      ],
                                    ),
                              );
                              if (confirm == true) {
                                deletetodo(widget.id);
                              }
                            },
                            icon: Icon(Icons.delete_rounded),
                            color: Colors.red,
                          ),
                        ],
                      ),
                      SizedBox(height: 2),

                      // Category
                      _buildDetailRow(
                        icon: Icons.folder_outlined,
                        label: 'Category',
                        value: widget.category,
                        color: Colors.teal,
                      ),
                      SizedBox(height: 8),

                      // Status
                      _buildDetailRow(
                        icon: Icons.info_outline,
                        label: 'Status',
                        value: widget.status,
                        color: Colors.indigo,
                      ),
                      SizedBox(height: 8),

                      // Note
                      if (widget.note.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.note_outlined,
                              size: 18,
                              color: Colors.amber.shade700,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Note:',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.amber.shade200,
                                      ),
                                    ),
                                    child: Text(
                                      widget.note,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  crossFadeState:
                      isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                  duration: Duration(milliseconds: 300),
                ),

                // Expand/Collapse Indicator
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}
