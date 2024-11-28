import 'package:flutter/material.dart';
import 'package:my_simple_note/service/database_helper.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Map<String, dynamic>? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  _AddEditNoteScreenState createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  // Create an instance of DatabaseHelper
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!['title'];
      _contentController.text = widget.note!['content'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Add Note' : 'Edit Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Content is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final title = _titleController.text;
                    final content = _contentController.text;
                    final dateAdded = DateTime.now().toIso8601String();

                    if (widget.note == null) {
                      // Insert new note
                      _dbHelper.insertNote({
                        'title': title,
                        'content': content,
                        'date_added': dateAdded,
                      }).then((_) => Navigator.pop(context, true));
                    } else {
                      // Update existing note
                      _dbHelper.updateNote(widget.note!['id'], {
                        'title': title,
                        'content': content,
                        'date_added': dateAdded,
                      }).then((_) => Navigator.pop(context, true));
                    }
                  }
                },
                child: Text(widget.note == null ? 'Add Note' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
