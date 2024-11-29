import 'package:flutter/material.dart';
import 'package:my_simple_note/service/database_helper.dart';
import 'add_edit_note_screen.dart';
import 'package:my_simple_note/widget/note_card.dart';

class NotesAppScreen extends StatefulWidget {
  const NotesAppScreen({super.key});

  @override
  NotesAppScreenState createState() => NotesAppScreenState();
}

class NotesAppScreenState extends State<NotesAppScreen> {
  final _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _notes = [];
  String _searchQuery = '';
  bool _sortAscending = true;
  bool _isSearching = false;

  final List<List<Color>> _noteGradients = const [
    [Color(0xFFee9ca7), Color(0xff594689)],
    [Color(0xff206459), Color(0xff32ad8d)],
    [Color(0xffb993d6), Color(0xff8ca6db)],
    [Color(0xffda5a72), Color(0xffaf1738)],
    [Color(0xff16bffd), Color(0xffcb3066)],
  ];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await _dbHelper.fetchNotes();
    setState(() {
      // Reverse the list to show the latest notes at the top based on date_added
      _notes = notes;
    });
  }

  void _sortNotes() {
    setState(() {
      _notes.sort((a, b) {
        final dateA = DateTime.parse(a['date_added']);
        final dateB = DateTime.parse(b['date_added']);
        return _sortAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      });
      _sortAscending = !_sortAscending;
    });
  }

  void _deleteNoteConfirm(int id) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Delete Note'),
            content: const Text('Are you sure you want to delete this note?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _dbHelper.deleteNote(id).then((_) => _loadNotes());
                },
                child: const Text('Yes'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('No'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = _notes.where((note) {
      return note['title']
          .toLowerCase()
          .contains(_searchQuery.toLowerCase()) ||
          note['content']
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: _isSearching
            ? TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: const InputDecoration(
            hintText: 'Search notes...',
            hintStyle: TextStyle(color: Colors.black54),
          ),
          autofocus: true,
        )
            : const Text(
          'My Simple Note',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchQuery = '';
              });
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.sort,
              color: Colors.black,
            ),
            onPressed: _sortNotes,
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.cyan, Colors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditNoteScreen()),
          );
          if (result == true) _loadNotes(); // Refresh the list after adding/editing
        },
        child: const Icon(Icons.add),
      ),

      body: filteredNotes.isEmpty
          ? Container( // Wrap the column with a container
        color: Colors.white, // Set a solid white background
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.note_alt_outlined, size: 80, color: Colors.grey), // Use black icon color for visibility
              SizedBox(height: 16),
              Text(
                'No Notes Available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Set text color to black
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tap the + button to add your first note!',
                style: TextStyle(fontSize: 14, color: Colors.black), // Set text color to black
              ),
            ],
          ),
        ),
      )
          : ListView.builder(
        itemCount: filteredNotes.length,
        itemBuilder: (context, index) {
          final note = filteredNotes[index];
          final gradient = _noteGradients[index % _noteGradients.length];
          return NoteCard(
            note: note,
            gradient: gradient,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditNoteScreen(note: note),
                ),
              );
              if (result == true) _loadNotes(); // Refresh after editing
            },
            onDelete: () => _deleteNoteConfirm(note['id']),
          );
        },
      ),
    );
  }
}
