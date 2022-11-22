import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/ui/theme.dart';
import 'package:todo_app/ui/widgets/buttons.dart';
import 'package:todo_app/ui/widgets/input_field.dart';
import 'package:todo_app/controllers/task_controller.dart';
class TaskAddPage extends StatefulWidget {
  const TaskAddPage({Key? key}) : super(key: key);

  @override
  State<TaskAddPage> createState() => _TaskAddPageState();
}

class _TaskAddPageState extends State<TaskAddPage> {
  final TaskController _taskController = Get.put(TaskController());
  TextEditingController _titleController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _endTime = "10:00 PM";
  String _startTime = DateFormat('hh:mm a').format(DateTime.now()).toString();
  int _selectedRiminder = 5;
  List<int> reminderList = [5,10,15,20,25,30,60];
  String _selectedRepeat = "None";
  List<String> repeatList = ["None","Daily","Weekly","Monthly"];
  int _selectedColor =0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: _appBar(context),
      body: Container(
        padding: const EdgeInsets.only(left: 20,right: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
                Text("Add Task",
                style: headingStyle,
                ),
              MyInputField(title: "Title", hint: "Enter your title",controller: _titleController,),
              MyInputField(title: "Note", hint: "Enter your note",controller: _noteController,),
              MyInputField(title: "Date", hint: DateFormat.yMd().format(_selectedDate),
                widget: IconButton(
                  icon: Icon(Icons.calendar_today_outlined,
                  color: Colors.grey,
                  ),
                  onPressed: (){
                    _getDateFromUser();
                  },
                ),),
              Row(

                children: [
                  Expanded(
                      child: MyInputField(title: "Start Time" ,hint: _startTime,
                        widget: IconButton(
                          icon: Icon(Icons.access_time_rounded,color: Colors.grey,),
                          onPressed: (){
                            _getTimeFromUser(isStartTime: true);
                          },),)),
                  SizedBox(width: 12,),
                  Expanded(
                      child: MyInputField(title: "End Time" ,hint: _endTime,
                        widget: IconButton(
                          icon: Icon(Icons.access_time_rounded,color: Colors.grey,),
                          onPressed: (){
                            _getTimeFromUser(isStartTime: false);
                          },),))
                ],
              ),
              MyInputField(title: "Remind", hint: "$_selectedRiminder minutes early",
              widget: DropdownButton(
                icon: Icon(Icons.keyboard_arrow_down,
                color: Colors.grey,
                ),
                iconSize: 32,
                elevation: 4,
                style: subLabelStyle,
                underline: Container(height: 0,),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRiminder = int.parse(newValue!);
                  });
                },
                items: reminderList.map<DropdownMenuItem<String>>((int value){
                  return DropdownMenuItem<String>(
                      value: value.toString(),
                      child: Text(value.toString()),
                  );
                }).toList(),
              ),
              ),
              MyInputField(title: "Repeat", hint: _selectedRepeat,
                widget: DropdownButton(
                  icon: Icon(Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                  iconSize: 32,
                  elevation: 4,
                  style: subLabelStyle,
                  underline: Container(height: 0,),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRepeat = newValue!;
                    });
                  },
                  items: repeatList.map<DropdownMenuItem<String>>((String? value){
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value!,style: TextStyle(color: Colors.grey),),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 18,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _colorPanel(),
                  MyButton(label: "Create Task", onTap: ()=>_validateData()),
                ],
              ),
              SizedBox(height: 25,),
            ],
          ),
        ),
      ),
    );
  }
  _validateData(){
    if(_titleController.text.isNotEmpty && _noteController.text.isNotEmpty){
      _addTaskToDB();
      Get.back();
    }else if(_titleController.text.isEmpty || _noteController.text.isEmpty){
      Get.snackbar("Required", "All field are required!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.red,
        icon: Icon(Icons.warning_amber_outlined,color: Colors.red,)
      );
    }
  }
  _addTaskToDB() async {
    int  value = await _taskController.addTask(
        task:Task(
          title: _titleController.text,
          note: _noteController.text,
          date: DateFormat.yMd().format(_selectedDate),
          startTime: _startTime,
          endTime: _endTime,
          remind: _selectedRiminder,
          repeat: _selectedRepeat,
          color: _selectedColor,
          isCompleted: 0,
        )
    );
  }
  _appBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      leading: GestureDetector(
        onTap: (){
          Get.back();
        },
        child: Icon(Icons.arrow_back_ios,
          size: 30,
          color: Get.isDarkMode?Colors.white:Colors.black,),
      ),
      actions: [
        PopupMenuButton(
            icon: Icon(Icons.person,
            size: 30, color: Get.isDarkMode?Colors.white:Colors.black,),
            itemBuilder: (context){
              return[];
            }
        ),
        SizedBox(width: 20,),
      ],
    );
  }
  _colorPanel(){
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Color",style: labelStyle,),
        SizedBox(height: 8.0,),
        Wrap(
          children:List<Widget>.generate(
              3, (int index){
            return GestureDetector(
              onTap: (){
                setState(() {
                  _selectedColor = index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: index==0?primaryClr:index==1?pinkClr:yellowClr,
                  child: _selectedColor==index?Icon(Icons.done,
                    color: Colors.white,
                    size: 16,):Container(),
                ),
              ),
            );
          }) ,
        )

      ],
    );
  }
  _getDateFromUser() async {
    DateTime? _pickerDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015),
        lastDate: DateTime(2200)
    );
    if(_pickerDate!=null){
      setState(() {
        _selectedDate= _pickerDate;
      });
    }else{

    }
  }
  _getTimeFromUser({required bool isStartTime}) async {
    var pickedTime = await _showTimePicker();
    String _formatedTime = pickedTime.format(context);
    if(pickedTime==null){

    }else if(isStartTime==true){
      setState(() {
        _startTime = _formatedTime;
      });
    }else if(isStartTime==false){
      setState(() {
        _endTime = _formatedTime;
      });
    }
  }
  _showTimePicker(){
    return showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
        context: context,
        initialTime: TimeOfDay(
            hour: int.parse(_startTime.split(":")[0]),
            minute: int.parse(_startTime.split(":")[1].split(" ")[0])
        )
    );
  }
}
