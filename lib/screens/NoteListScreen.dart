import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notekeeper/StaticMethod.dart';
import 'package:notekeeper/models/Note.dart';
import 'package:notekeeper/screens/NoteDetailScreen.dart';
import 'package:notekeeper/utils/DatabaseHelper.dart';
import 'package:sqflite/sqlite_api.dart';
class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  List<dynamic> noteList=[];
  bool _mounted=false;
  bool _isLoading = false;
  late Database db;
  
  //=============================DATABASE INITIALIZATION
  initDb()async{
    final result = await DatabaseHelper.initDb();
    db = result;
    print('instance of database is ${result.toString()}');
    await DatabaseHelper.createTable(db);
    fetchData();
  }
  
  //=============================DATA FETCHING
  fetchData()async{
    if(_mounted){
      setState(() {
        _isLoading=true;
      });
    }
    _mounted=true;
    final result = await DatabaseHelper.getData(db);
    print('available data on table is ${result.toString()}');
    if(_mounted){
      noteList = result;
      setState(() {
        _isLoading=false;
      });
    }
  }
  
  //=============================DELETE PARTICULAR NOTE
  deleteNote(noteId)async{
    final result = await DatabaseHelper.deleteExistingNote(noteId, db);
    StaticMethod.showToastMsg('note deleted', Colors.green,context);
    fetchData();
  }
  
  //=============================SHOW AVAILABLE TABLE
  showTable()async{
    final result = await DatabaseHelper.showTables(db);
    print(result);
  }
  @override
  void initState() {
    print('initstate called');
    initDb();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    print(noteList);
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){_isLoading=false; fetchData();}, icon: Icon(Icons.refresh))
        ],
      ),
      body: Container(
        child: _isLoading
            ? Center(child: LinearProgressIndicator(),)
            : noteList.length>0
            ? 
        ListView.builder(
            itemCount: noteList.length,
            itemBuilder: (context,index){
              final note = noteList[index];
              DateTime createdAt = DateTime.parse(note['createdAt']);
              String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(createdAt);
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 15,vertical: 7),
                color: Colors.white,
                elevation: 2.0,
                child: ListTile(
                  leading: CircleAvatar(
                      backgroundColor: getPriorityColor(note['priority']),
                      child: getPriorityIcon(note['priority'])
                  ),
                  title: Text(
                      '${note['title']}'
                  ),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${formattedDate}'
                      ),
                      Text(
                          '${note['description']}'
                      ),
                    ],
                  ),
                  trailing: GestureDetector(
                    onTap: (){
                      deleteNote(note['id']);
                    },
                    child: Icon(Icons.delete),
                  ),
                  onTap: (){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>NoteDetailScreen('Edit Note', db, note['id'])));
                    },
                ),
              );
            }
        )
            : Center(child: Text('Empty Notes'),),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>NoteDetailScreen('Add Note', db, 0)));
        },
        child: Icon(Icons.add),
        tooltip: 'Add Note',
      ),
    );
  }
  // Returns the priority color
  Color getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
        break;
      case 'Low':
        return Colors.yellow;
        break;

      default:
        return Colors.yellow;
    }
  }

  // Returns the priority icon
  Icon getPriorityIcon(String priority) {
    switch (priority) {
      case "High":
        return Icon(Icons.play_arrow);
        break;
      case "Low":
        return Icon(Icons.keyboard_arrow_right);
        break;

      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }
  
}
