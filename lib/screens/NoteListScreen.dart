import 'package:flutter/material.dart';
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
  
  //=============================SHOW AVAILABLE TABLE
  showTable()async{
    final result = await DatabaseHelper.showTables(db);
    print(result);
  }
  @override
  void initState() {
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
          IconButton(onPressed: (){_isLoading=false; fetchData();}, icon: Icon(Icons.list))
        ],
      ),
      body: Container(
        child: _isLoading
            ? Center(child: LinearProgressIndicator(),)
            : noteList.length>0
            ? Text(noteList.toString())
        // ListView.builder(
        //     itemCount: noteList.length,
        //     itemBuilder: (context,index){
        //       final note = noteList[index];
        //       return Card(
        //         margin: EdgeInsets.symmetric(horizontal: 15,vertical: 7),
        //         color: Colors.white,
        //         elevation: 2.0,
        //         child: ListTile(
        //           leading: CircleAvatar(
        //               backgroundColor: getPriorityColor(note.priority),
        //               child: getPriorityIcon(note.priority)
        //           ),
        //           title: Text(
        //               '${note.title}'
        //           ),
        //           subtitle: Text(
        //               '${note.description}'
        //           ),
        //           trailing: GestureDetector(
        //             onTap: (){
        //              
        //             },
        //             child: Icon(Icons.delete),
        //           ),
        //           onTap: (){
        //
        //           },
        //         ),
        //       );
        //     }
        // )
            : Center(child: Text('Empty Notes'),),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>NoteDetailScreen('Add Note',db)));
        },
        child: Icon(Icons.add),
        tooltip: 'Add Note',
      ),
    );
  }
  // Returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;

      default:
        return Colors.yellow;
    }
  }

  // Returns the priority icon
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
  
}
