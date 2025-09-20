import 'package:flutter/material.dart';

void main() => runApp(NoteApp());

class Note {
  String title;
  String content;
  bool isPinned;
  Note({required this.title, required this.content, this.isPinned = false});
}

class NoteApp extends StatefulWidget {
  @override
  _NoteAppState createState() => _NoteAppState();
}

class _NoteAppState extends State<NoteApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Note App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: NoteHomePage(
        onToggleTheme: () => setState(() => _isDarkMode = !_isDarkMode),
      ),
    );
  }
}

class NoteHomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const NoteHomePage({Key? key, required this.onToggleTheme}) : super(key: key);

  @override
  _NoteHomePageState createState() => _NoteHomePageState();
}

class _NoteHomePageState extends State<NoteHomePage> {
  final List<Note> _notes = [];
  String _searchQuery = '';

  void _addOrEditNote({Note? note}) {
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(note == null ? 'Add Note' : 'Edit Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: contentController,
              decoration: InputDecoration(labelText: 'Content'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                setState(() {
                  if (note == null) {
                    _notes.add(
                      Note(
                        title: titleController.text,
                        content: contentController.text,
                      ),
                    );
                  } else {
                    note.title = titleController.text;
                    note.content = contentController.text;
                  }
                });
              }
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _togglePin(Note note) => setState(() => note.isPinned = !note.isPinned);

  void _delete(Note note) => setState(() => _notes.remove(note));

  @override
  Widget build(BuildContext context) {
    final filteredNotes =
        _notes
            .where(
              (note) =>
                  note.title.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  note.content.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
            )
            .toList()
          ..sort((a, b) => b.isPinned ? 1 : -1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            tooltip: 'Toggle Dark Mode',
            onPressed: widget.onToggleTheme,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
        ),
      ),
      body: filteredNotes.isEmpty
          ? const Center(child: Text('No notes yet. Tap + to add one.'))
          : ListView.builder(
              itemCount: filteredNotes.length,
              itemBuilder: (_, index) {
                final note = filteredNotes[index];
                return Card(
                  child: ListTile(
                    title: Text(note.title),
                    subtitle: Text(note.content),
                    leading: IconButton(
                      icon: Icon(
                        note.isPinned
                            ? Icons.push_pin
                            : Icons.push_pin_outlined,
                        color: note.isPinned ? Colors.amber : null,
                      ),
                      onPressed: () => _togglePin(note),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _delete(note),
                    ),
                    onTap: () => _addOrEditNote(note: note),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditNote(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
