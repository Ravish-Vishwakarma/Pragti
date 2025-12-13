import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pragti/Widgets/style.dart';

class ExpenseCard extends StatefulWidget {
  final String id;
  final String title;
  final String description;
  final double money;
  final String type;
  final String category;
  final String date;
  final String time;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ExpenseCard({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.money,
    required this.type,
    required this.category,
    required this.date,
    required this.time,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  _ExpenseCardState createState() => _ExpenseCardState();
}

class _ExpenseCardState extends State<ExpenseCard> {
  bool isExpanded = false;

  Color _getTypeColor() {
    return widget.type.toLowerCase() == 'income'
        ? Colors.green.shade400
        : Colors.red.shade400;
  }

  @override
  Widget build(BuildContext context) {
    bool isIncome = widget.type.toLowerCase() == 'income';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
      child: Card(
        elevation: isExpanded ? 8 : 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          onTap: () => setState(() => isExpanded = !isExpanded),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 2),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getTypeColor().withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.category.toUpperCase(),
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getTypeColor(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${isIncome ? '+' : '-'}${widget.money.toStringAsFixed(2)}",
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _getTypeColor(),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor().withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.type.toUpperCase(),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getTypeColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Description
                if (widget.description.isNotEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.description,
                          style: GoogleFonts.jetBrainsMono(
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
                          color: _getTypeColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.date,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _getTypeColor(),
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
                          color: _getTypeColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.time,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _getTypeColor(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Expanded Content
                isExpanded
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 2),
                        Divider(color: Colors.grey),
                        SizedBox(height: 4),

                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: widget.onEdit,
                                icon: Icon(Icons.edit, size: 18),
                                label: Text(
                                  "Edit",
                                  style: GoogleFonts.jetBrainsMono(),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MyColors.darkgreen,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: Text(
                                            "Delete Transaction",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          content: Text(
                                            "Are you sure you want to delete this transaction?",
                                            style: GoogleFonts.poppins(),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    false,
                                                  ),
                                              child: Text("Cancel"),
                                            ),
                                            ElevatedButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    true,
                                                  ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.red[400],
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
                                    widget.onDelete();
                                  }
                                },
                                icon: Icon(Icons.delete, size: 18),
                                label: Text(
                                  "Delete",
                                  style: GoogleFonts.jetBrainsMono(),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
