import 'package:flutter/material.dart';
import 'package:task_assistant/screens/note_details.dart';
import 'dart:async';
import 'package:task_assistant/models/notes.dart';
import 'package:task_assistant/data/database_helper.dart';
// import 'package:sqflite/sqflite.dart';

class NotesList extends StatefulWidget {
  @override
  _NotesListState createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Notes> notesList;
  int count = 0;
  @override
  Widget build(BuildContext context) {
    if (notesList == null) {
      notesList = List<Notes>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: getNotesListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('Floating Action Button Clicked');
          navigateToNoteDetails(Notes('','',2),'Add Task');
        },
        tooltip: 'Add A Task',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNotesListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                // backgroundColor:Colors.blue;
                // child: Icon(Icons.keyboard_arrow_right),
                backgroundColor:
                    getPriorityColor(this.notesList[position].priority),
                child: getPriorityIcon(this.notesList[position].priority),
              ),
              title: Text(this.notesList[position].title, style: titleStyle),
              subtitle: Text(this.notesList[position].date),
              trailing: GestureDetector(
                child: Icon(
                  Icons.delete,
                  color: Colors.blueGrey,
                ),
                onTap: (){
                  _deleteTask(context, notesList[position]);
                },
              ),
              onTap: () {
                debugPrint('List Tapped');
                navigateToNoteDetails(this.notesList[position],'Edit Task');
              },
            ),
          );
        });
  }

  //Return priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.blue;
        break;

      default:
        return Colors.blue;
    }
  }

  //Return priority icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;
      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void _deleteTask(BuildContext context, Notes notes) async {
    int result = await databaseHelper.deleteNote(notes.id);
    if (result != 0) {
      _showSnackBar(context, 'Task Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToNoteDetails(Notes notes,String title)async {
  bool result=await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetails(notes,title);
    }));

    if(result==true){
      updateListView();
    }
  }

  void updateListView(){
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();//Creating an instance of the database
    dbFuture.then((database){

      Future<List<Notes>> notesListFuture= databaseHelper.getNotesList();
      notesListFuture.then((notesList){
        setState(() {
          this.notesList=notesList;
          this.count=notesList.length;
        });
      });
    });
  }
}
