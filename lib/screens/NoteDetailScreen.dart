import 'package:flutter/material.dart';
import 'package:notekeeper/utils/DatabaseHelper.dart';
import 'package:sqflite/sqlite_api.dart';
class NoteDetailScreen extends StatefulWidget {
  String appBarTitle;
  Database db;
  NoteDetailScreen(this.appBarTitle, this.db);

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState(this.appBarTitle, this.db);
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  //=================================================PASSING DATA HANDLER
  String appBarTitle;
  Database db;
  _NoteDetailScreenState(this.appBarTitle,this.db);
  
  static var _priorities = ['High','Low'];
  String selectedPriority = 'Low';
  
  
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  FocusNode titleFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();
  
  addNewNote()async{
    var data={
      "title":titleController.text,
      "description":descriptionController.text,
      "createdAt":DateTime.now().toString(),
      "priority":selectedPriority,
    };
    final result = await DatabaseHelper.addNewNotes(db,data);
    print(result);
  }
  
  deleteExistingTable()async{
    final result = await DatabaseHelper.deleteTable('notekeeper_table', db);
    print(result);
  }
  
  showTables()async{
    final result = await DatabaseHelper.showTables(db);
    print(result);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10,vertical:7),
        child: ListView(
          children: [
            //=========================================PRIORITY DRODOWN
            ListTile(
              title: DropdownButton(
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
            ),
            //=========================================TITLE TEXTFIELD
            Padding(
                padding: EdgeInsets.only(top: 15,bottom: 15),
              child: TextField(
                controller: titleController,
                focusNode: titleFocusNode,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5)
                  )
                ),
                onChanged: (value){
                  
                },
              ),
            ),
            //=========================================DESCRIPTION TEXTFIELD
            Padding(
              padding: EdgeInsets.only(top: 15,bottom: 15),
              child: TextField(
                controller: descriptionController,
                focusNode: descriptionFocusNode,
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
                         onPressed: (){addNewNote();},
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
                          deleteExistingTable();
                        },
                        child: Text('Delete',style: TextStyle(color: Colors.white),),
                      )
                  )
                ],
              ),
            )
          ],
        ),
      ) ,
    );
  }
}
