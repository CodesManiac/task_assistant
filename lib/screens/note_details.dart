import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import 'package:task_assistant/data/database_helper.dart';
import 'package:task_assistant/models/notes.dart';
// import 'package:intl/intl.dart';

class NoteDetails extends StatefulWidget {
  String appBarTitle;
  final Notes notes;

  NoteDetails(this.notes, this.appBarTitle);

  @override
  _NoteDetailsState createState() =>
      _NoteDetailsState(this.notes, this.appBarTitle);
}

class _NoteDetailsState extends State<NoteDetails> {
  var _formKey = GlobalKey<FormState>();

  static var _priorities = ['High Priority', 'Low Priority'];
  DatabaseHelper _databaseHelper = DatabaseHelper();
  String appBarTitle;
  Notes notes;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  _NoteDetailsState(this.notes, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = notes.title;
    descriptionController.text = notes.description;

    return WillPopScope(
      onWillPop: () {
        backToNotesList();
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  backToNotesList();
                }),
          ),
          body: Form(
            key: _formKey,
            child: Padding(
                padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
                child: ListView(
                  children: <Widget>[
                    ListTile(
                        title: DropdownButton(
                            items: _priorities.map((String _dropDownItem) {
                              return DropdownMenuItem<String>(
                                value: _dropDownItem,
                                child: Text(_dropDownItem),
                              );
                            }).toList(),
                            style: textStyle,
                            value: convertPriorityToString(notes.priority),
                            onChanged: (selectedValue) {
                              setState(() {
                                debugPrint('The user selected $selectedValue');
                                convertPriorityToInt(selectedValue);
                              });
                            })),

                    // Second element
                    Padding(
                      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: TextFormField(
                        controller: titleController,
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Please enter task title';
                          }
                          return value;
                        },
                        style: textStyle,
                        onChanged: (value) {
                          debugPrint('Title Field has been edited by the user');
                          updateTitle();
                        },
                        decoration: InputDecoration(
                            labelText: 'Title',
                            labelStyle: textStyle,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                      ),
                    ),

                    // third element
                    Padding(
                      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: TextFormField(
                        controller: descriptionController,
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Please enter task description';
                          }
                          return value;
                        },
                        style: textStyle,
                        onChanged: (value) {
                          debugPrint(
                              'Description text Field has been edited by the user');
                          updateDescription();
                        },
                        decoration: InputDecoration(
                            labelText: 'Description',
                            labelStyle: textStyle,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                      ),
                    ),
                    //row last element
                    Padding(
                      padding: EdgeInsets.only(top: 15.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: RaisedButton(
                                  color: Theme.of(context).primaryColorDark,
                                  textColor:
                                      Theme.of(context).primaryColorLight,
                                  child: Text(
                                    'Save',
                                    textScaleFactor: 1.5,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (_formKey.currentState.validate()) {
                                        debugPrint('Clicked Save button');
                                        _save();
                                      } else {
                                        _showAlertDialog('Status',
                                            "You can't Save an empty task, Some fields are missing");
                                      }
                                    });
                                  })),

                          Container(width: 5.0), //for space between buttons

                          Expanded(
                              child: RaisedButton(
                                  color: Theme.of(context).primaryColorDark,
                                  textColor:
                                      Theme.of(context).primaryColorLight,
                                  child: Text(
                                    'Delete',
                                    textScaleFactor: 1.5,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (_formKey.currentState.validate()) {
                                        debugPrint('Clicked Delete button');
                                        _delete();
                                      }else{
                                        _showAlertDialog("status", "You can't delete an empty task");
                                      }
                                    });
                                  }))
                        ],
                      ),
                    )
                  ],
                )),
          )),
    );
  }

  void backToNotesList() {
    Navigator.pop(context, true);
  }

  // Converting priority from String to int so to be able to save it into the database
  void convertPriorityToInt(String value) {
    switch (value) {
      case 'High Priority':
        notes.priority = 1;
        break;
      case 'Low Priority':
        notes.priority = 2;
        break;
    }
  }

  // Converting priority from int value to String before displaying it in the user dropdown
  String convertPriorityToString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; //High Priority
        break;
      case 2:
        priority = _priorities[1]; //Low Priority
        break;
    }
    return priority;
  }

  // Updating the title
  void updateTitle() {
    notes.title = titleController.text;
  }

  // Updating the description textfield
  void updateDescription() {
    notes.description = descriptionController.text;
  }

  // saving data to the databae
  void _save() async {
    backToNotesList();

    notes.date = DateFormat.yMMd().format(DateTime.now());

    int result;
    if (notes.id != null) {
      //Update
      result = await _databaseHelper.updateNote(notes);
    } else {
      //Insert
      result = await _databaseHelper.insertNote(notes);
    }

    if (result != 0) {
      _showAlertDialog('Status', 'Task Saved Successfully');
    } else {
      _showAlertDialog('Status', 'Could not save Task');
    }
  }

  //Deleting task from database
  void _delete() async {
    backToNotesList();
    // if user is trying to delete a new Task (he has come to the details page by clicking on the fab icon)
    if (notes.id == null) {
      _showAlertDialog('Stautus', 'No task was deleted');
      return;
    }
    // User is trying to delete old note that already has a valid id
    int result = await _databaseHelper.deleteNote(notes.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Task Deleted Successfully');
    } else {
      _showAlertDialog(
          'Status', 'An Error occured while trying to Delete Task');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
