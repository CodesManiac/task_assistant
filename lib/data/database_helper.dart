import 'dart:async';
import 'dart:io';
import 'package:task_assistant/models/notes.dart';
// import 'package:sqfLite/sqfLite.dart';
// import 'package:path_provider/path_provider.dart';

class DatabaseHelper{
  static DatabaseHelper _databasehelper; //Singleton Database
  static Database _database; //Singleton Database

  String notesTable ='notes_table';
  String colId='id';
  String colTitle='title';
  String colDescription='description';
  String colPriority='priority';
  String colDate='date';

  DatabaseHelper._createInstance();// Named Constructor to create instance of DatabaseHelper

  factory DatabaseHelper(){
    if(_databasehelper==null){
      _databasehelper=DatabaseHelper._createInstance();//This is executed only once, singleton object
    }
    return _databasehelper;
  }
  Future<Database>get database async{
    if(_database ==null){
      _database = await initializeDatabase();
    }
    return _database;
  }


  Future<Database> initializeDatabase() async{
    // get the directory path for both Android and iOs to store database
    Directory directory=await getApplicationDocumentDirectory();
    String path =directory.path+'tasks.db';
    //Create Database in a given path
    var taskDatabase = awiat openDatabase(path, version:1,onCreate:_createDb);
    returns taskDatabase;
  }

  void _createDb(Database db, int newVersion)async{
    await db.execute('CREATE TABLE $notesTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }


  //Fetch Retrieve Objects from the database
  Future<List<Map<String,dynamic>>>getNotesMapList() async{
    Database db = await this.database;

    // var result=await db.rawQuery('SELECT * FROM $notesTable order by $colPriority ASC');//another means
    var result=await db.query(notesTable, orderBy: '$colPriority ASC');
    return result;
  }
  // Insert 
  Future<int>insertNote(Notes note)async{
    Database db=await this.database;
    var result=await db.insert(notesTable,note.toMap());
    return result;
  }
  // Update
  Future<int>updateNote(Notes note)async{
    var db=await this.database;
    var result=await db.update(notesTable,note.toMap(), where:'$colId = ?', whereArgs:[note.id]);
    return result;
  }
  // Delete
  Future<int>deleteNote(int id)async{
    var db=await this.database;
    var result=await db.rawDelete('DELETE FROM $notesTable WHERE $colId=$id');
    return result;
  }
  // Get number of tasks created
  Future<int> getCount() async{
    Database db= await this.database;
    List<Map<String,dynamic>> x = await db.rawQuery('SELECT COUNT (*) FROM $notesTable');
    int result =Sqflite.firstIntValue(x);
    return result;
  }

  // Getting the 'Map List'from the database and converting it to Note list
  Future<List<Notes>> getNotesList() async{
    var notesMapList=await getNotesMapList();//Get 'Map List' from database
    int count = notesMapList.length;//Count the number of map entries in the database table

    List<Notes>notesList = List<Notes>();
    // loop for creating  Notes List from Maps List
    for (int i = 0; i < count; i++) {
      notesList.add(Notes.fromMapObject(notesMapList[i]));
    }
    return notesList;

  }

}