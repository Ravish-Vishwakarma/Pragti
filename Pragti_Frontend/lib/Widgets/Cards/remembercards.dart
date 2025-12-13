import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

class RememberCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RememberCard({
    super.key,
    required this.data,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<RememberCard> createState() => _RememberCardState();
}

class _RememberCardState extends State<RememberCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.data['title'] ?? '',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              MarkdownBody(
                data: widget.data['content']?.toString() ?? '',
                styleSheet: MarkdownStyleSheet(
                  p: GoogleFonts.jetBrainsMono(color: Colors.black),
                ),
              ),
              if (_expanded) ...[
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      label: const Text("Edit"),
                      onPressed: widget.onEdit,
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text("Delete"),
                      onPressed: widget.onDelete,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
