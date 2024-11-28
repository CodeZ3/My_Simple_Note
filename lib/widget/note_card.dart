import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoteCard extends StatefulWidget {
  final Map<String, dynamic> note;
  final List<Color> gradient;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.gradient,
    required this.onTap,
    required this.onDelete,
  });

  @override
  _NoteCardState createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  // State variable to track expansion
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Format the date
    final String formattedDate = DateFormat('dd/MM/yyyy hh:mm a')
        .format(DateTime.parse(widget.note['date_added']));


    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          onTap: widget.onTap,
          title: Text(
            widget.note['title'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Use a Container with a minimum height for the content
              Container(
                constraints: BoxConstraints(
                  minHeight: 30, // Minimum height to show at least 2 lines
                  maxHeight: _isExpanded ? double.infinity : 40, // Adjust max height when expanded
                ),
                child: SingleChildScrollView(
                  child: Text(
                    widget.note['content'],
                    style: const TextStyle(color: Colors.white),
                    maxLines: _isExpanded ? null : 2, // Show 2 lines when collapsed
                    overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 10), // Gap between content and timestamp
              Text(
                formattedDate,
                style: const TextStyle(color: Colors.white),
              ),
              // Show more/less button
              TextButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded; // Toggle expansion
                  });
                },
                child: Text(
                  _isExpanded ? 'Show Less' : 'Show More',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: widget.onTap,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: widget.onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
