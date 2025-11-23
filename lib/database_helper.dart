import 'package:notes_app/notes_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> _getDB() async {
  return openDatabase(
    join(await getDatabasesPath(), "notes.db"),
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
create table notes (
id integer primary key autoincrement,
title text not null,
content text not null
)''');
    },
  );
}

Future<int> insertNote(Note note) async {
  final db = await _getDB();
  return await db.insert('notes', note.toMap());
}

Future<List<Note>> getNotes() async {
  final db = await _getDB();
  final List<Map<String, dynamic>> maps = await db.query("notes");
  return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
}

Future<int> updateNote(Note note) async {
  final db = await _getDB();
  return await db.update(
    "notes",
    note.toMap(),
    where: "id = ?",
    whereArgs: [note.id],
  );
}

Future<List<Note>> searchNotes(String query) async {
  final db = await _getDB();
  final List<Map<String, dynamic>> maps = await db.query(
    "notes",
    where: "title LIKE ?",
    whereArgs: ['%$query%'], // matches any part of the title
  );

  return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
}

Future<int> deleteNote(int id) async {
  final db = await _getDB();
  return await db.delete("notes", where: "id = ?", whereArgs: [id]);
}
