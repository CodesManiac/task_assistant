class Notes {
  int _id;
  String _title;
  String _description;
  String _date;
  int _priority;

  Notes(this._title, this._date, this._priority,
      [this._description]); //description is optional
  Notes.withId(this._title, this._date, this._priority,
      [this._description]); //named constructor

  int get id => _id;
  String get title => _title;
  String get description => _description;
  String get date => _date;
  int get priority => _priority;

  set title(String newTitle) {
    if (newTitle.length <= 50) {
      this._title = newTitle;
    }
  }

  set description(String newDescription) {
    if (newDescription.length <= 255) {
      this._description = newDescription;
    }
  }

  set priority(int newPriority) {
    if (newPriority >= 1 && newPriority <= 2) {
      this._priority = newPriority;
    }
  }

  set date(String newDate) {
    this._date = newDate;
  }

  // Converting a note object into a map object
  Map<String, dynamic> toMap() { //dynamic for any datatype
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map['title'] = _title;
    map['description'] = _description;
    map['priority'] = _priority;
    map['date'] = _date;
    return map;
  }

  // Extract  a note obejct from Map object
  Notes.fromMapObject(Map<String, dynamic>map){
    this._id=map['id'];
    this._title= map['title'];
    this._description=map['description'];
    this._priority=map['priority'];
    this._date=map['date'];
  }
}
