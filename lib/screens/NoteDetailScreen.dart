import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:notekeeper/StaticMethod.dart';
import 'package:notekeeper/screens/NoteListScreen.dart';
import 'package:notekeeper/utils/DatabaseHelper.dart';
import 'package:sqflite/sqlite_api.dart';
class NoteDetailScreen extends StatefulWidget {
  String appBarTitle;
  Database db;
  int noteId;
  NoteDetailScreen(this.appBarTitle, this.db,this.noteId);

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState(this.appBarTitle, this.db,this.noteId);
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  //=================================================PASSING DATA HANDLER
  String appBarTitle;
  Database db;
  int noteId;
  _NoteDetailScreenState(this.appBarTitle,this.db,this.noteId);
  
  static var _priorities = ['High','Low'];
  String selectedPriority = 'Low';
  String priority = '';
  Map<String,dynamic> noteDetail={};
  String formattedDate='';
  bool _isLoading = false;
  bool _mounted = false;
  
  
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  FocusNode titleFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();
  
  //============================FETCH NOTE DETAILS
  fetchNoteDetail(noteId)async{
    _mounted=true;
    if(_mounted){
      setState(() {
        _isLoading=true;
      });
    }
    final result = await DatabaseHelper.getDataById(noteId, db);
    if(result.length>0){
      noteDetail = result[0];
      _mounted=true;
      if(_mounted){
        setState(() {
          _isLoading=false;
        });
      }
    }else{
      _mounted=true;
      if(_mounted){
        setState(() {
          _isLoading=false;
        });
      }
    }
    //print('note detail is $result');
  }
  
  //===========================ADD NEW NOTE
  addNewNote()async{
    var data={
      "title":titleController.text,
      "description":descriptionController.text,
      "createdAt":DateTime.now().toString(),
      "priority":selectedPriority,
    };
    final result = await DatabaseHelper.addNewNotes(db,data);
    if(result>0){
      StaticMethod.showToastMsg('Note Added', Colors.green, context);
      fetchNoteDetail(result);
    }
    //print('add new note result is $result');
  }
  
  //===========================UPDATE EXISTING NOTE
  updateExistingNote(context)async{
    final data = {
      "title":titleController.text,
      "description":descriptionController.text,
      "createdAt":DateTime.now().toString(),
      "priority":selectedPriority
    };
    final result = await DatabaseHelper.updateExistingNote(data, noteId, db);
    if(result==1){
      fetchNoteDetail(noteId);
      StaticMethod.showToastMsg('note updated', Colors.green,context);
    }
    //print('updated result is $result');
  }

  //=============================DELETE PARTICULAR NOTE
  deleteNote(noteId)async{
    final result = await DatabaseHelper.deleteExistingNote(noteId, db);
    StaticMethod.showToastMsg('note deleted', Colors.green,context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>NoteListScreen()));
  }
  
  //==========================DELETE EXISTING TABLE
  deleteExistingTable()async{
    final result = await DatabaseHelper.deleteTable('notekeeper_table', db);
   // print('deleting existing table result is $result');
  }
  
  //==========================SHOW ALL TABLE
  showTables()async{
    final result = await DatabaseHelper.showTables(db);
   // print('show table result is : $result');
  }
  
  
  @override
  void initState() {
    fetchNoteDetail(noteId);
    super.initState();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }
  
  
  @override
  Widget build(BuildContext context) {
    if(noteDetail.isNotEmpty){
      titleController.text = noteDetail['title'];
      descriptionController.text=noteDetail['description'];
      priority = noteDetail['priority'];
      DateTime createdAt = DateTime.parse(noteDetail['createdAt']);
      formattedDate = DateFormat('dd-MM-yyyy HH:mm').format(createdAt);
    }
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>NoteListScreen()));
      },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            centerTitle: true,
          ),
          body: _isLoading
              ? Center(child: CircularProgressIndicator(),)
              :Padding(
            padding: EdgeInsets.symmetric(horizontal: 10,vertical:7),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  //=========================================PRIORITY DRODOWN
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Select Priority'),
                          SizedBox(width: 10,),
                          Card(
                            color: Colors.white,
                            elevation: 0.5,
                            child: Container(
                                height: 35,
                                width: MediaQuery.of(context).size.width*0.3,
                                child: Center(
                                  child: DropdownButton(
                                    alignment: Alignment.center,
                                    underline: Container(),
                                    items: _priorities.map((String dropDownStringItem){
                                      return DropdownMenuItem<String>(
                                        value: dropDownStringItem,
                                        child: Text(dropDownStringItem),
                                      );
                                    }).toList(),
                                    value: selectedPriority,
                                    onChanged: (value){
                                      setState(() {
                                        selectedPriority = value!;
                                      });
                                    },
                                  ),
                                )
                            ),
                          ),
                          SizedBox(width: 20,),
                          Text('$priority priority',style: TextStyle(color: priority=='High'?Colors.red : Colors.orange,fontWeight: FontWeight.w500),),
                        ],
                      ),
                      Text(
                          '$formattedDate'
                      )
                    ],
                  ),
                  //=========================================TITLE TEXTFIELD
                  Padding(
                    padding: EdgeInsets.only(top: 15,bottom: 15),
                    child: TextFormField(
                      controller: titleController,
                      focusNode: titleFocusNode,
                      decoration: InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5)
                          )
                      ),
                      validator: (value){
                        if(value!.isEmpty){
                          return "title should not be empty";
                        }
                        return null;
                      },
                    ),
                  ),
                  //=========================================DESCRIPTION TEXTFIELD
                  Padding(
                    padding: EdgeInsets.only(top: 15,bottom: 15),
                    child: TextFormField(
                      controller: descriptionController,
                      focusNode: descriptionFocusNode,
                      maxLines: 4,
                      decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5)
                          )
                      ),
                      onChanged: (value){

                      },
                    ),
                  ),
                  //=========================================BUTTONS ROW
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Row(
                      children: [
                        Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)
                                  ),
                                  backgroundColor: Theme.of(context).primaryColor
                              ),
                              onPressed: (){
                                if (_formKey.currentState!.validate()) {
                                  if(noteId>0){
                                    updateExistingNote(context);
                                  }else{
                                    addNewNote();
                                  }
                                }
                              },
                              child: Text('Save',style: TextStyle(color: Colors.white),),
                            )
                        ),
                        SizedBox(width: 10,),
                        Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)
                                  ),
                                  backgroundColor: Theme.of(context).primaryColor
                              ),
                              onPressed: (){
                                if(noteId>0){
                                  deleteNote(noteId);
                                }else{
                                  StaticMethod.showToastMsg('Nothing to delete', Colors.green, context);
                                }
                              },
                              child: Text('Delete',style: TextStyle(color: Colors.white),),
                            )
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ) ,
        )
    );
  }
}
