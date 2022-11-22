import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/controllers/task_controller.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/services/notification_services.dart';
import 'package:todo_app/services/theme_services.dart';
import 'package:todo_app/ui/theme.dart';
import 'package:todo_app/ui/widgets/buttons.dart';
import 'package:todo_app/ui/widgets/task_page.dart';
import 'package:todo_app/ui/widgets/task_tile.dart';
import 'package:todo_app/ui/edit_stored_task.dart';

class HomePage extends StatefulWidget{
  const HomePage({Key? key}): super(key: key);
  @override
  _HomePageState createState()=> _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  final _taskController = Get.put(TaskController());
  var notifyHelper;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notifyHelper=NotifyHelper();
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();
    _taskController.getTasks();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: _appBar(),
      backgroundColor: context.theme.backgroundColor,
      body: Column(
        children: [
          _appTaskBar(),
          _addDateBar(),
          SizedBox(height: 10,),
          _showTasks(),
        ],
      ),
    );
  }
  _showTasks(){
    return Expanded(
        child:Obx((){
          return ListView.builder(
              itemCount: _taskController.taskList.length,
              itemBuilder: (_,index) {
                _taskController.getTasks();
                Task task = _taskController.taskList[index];
                DateTime tempDate = DateFormat.yMd().parse(task.date.toString());
                DateTime date = DateFormat.jm().parse(task.startTime.toString());
                var myTime = DateFormat("HH:mm").format(date);
                int hour = int.parse(myTime.toString().split(":")[0]);
                int minutes = int.parse(myTime.toString().split(":")[1]);
                int reminder = int.parse(task.remind.toString());

                if ( minutes < reminder){
                  hour = hour - 1;
                  minutes = minutes + 60;
                }else{
                  minutes = minutes - reminder;
                }

                if (task.repeat == 'Daily') {
                  notifyHelper.scheduledNotification(hour,minutes,task);
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    child: SlideAnimation(
                      child: FadeInAnimation(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showBottomSheet(context, task);
                              },
                              child: TaskTile(task),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else if (task.date == DateFormat.yMd().format(_selectedDate)) {
                  notifyHelper.scheduledNotification(hour,minutes,task);
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    child: SlideAnimation(
                      child: FadeInAnimation(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showBottomSheet(context, task);
                              },
                              child: TaskTile(task),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                else if ((task.repeat =='Weekly')&& (DateFormat.EEEE().format(tempDate) == DateFormat.EEEE().format(_selectedDate))){
                  notifyHelper.scheduledNotification(hour,minutes,task);
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    child: SlideAnimation(
                      child: FadeInAnimation(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showBottomSheet(context, task);
                              },
                              child: TaskTile(task),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
              }
                else if((DateFormat.d().format(tempDate) == DateFormat.d().format(_selectedDate))){
                  notifyHelper.scheduledNotification(hour,minutes,task);
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    child: SlideAnimation(
                      child: FadeInAnimation(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showBottomSheet(context, task);
                              },
                              child: TaskTile(task),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                else{
                  return Container();
                }
              }
          );
        }),
    );
  }
  _showBottomSheet(BuildContext context,Task task){
    Get.bottomSheet(
      Expanded(
        child: Container(
          padding: const EdgeInsets.only(top: 4),
          height: task.isCompleted==1?
          MediaQuery.of(context).size.height*0.24:MediaQuery.of(context).size.height*0.32,
          color: Get.isDarkMode?darkGreyClr:Colors.white,
          child: Column(
            children: [
              Container(
                height: 6,
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Get.isDarkMode?Colors.grey[600]:Colors.grey[300],

                ),
              ),
              Spacer(),
              task.isCompleted==1?Container():  _bottomSheetButton(
                  label: "Task Completed",
                  onTap: (){
                    _taskController.markTaskAsCompleted(task.id!);
                    _taskController.getTasks();
                    Get.back();
                  },
                context: context,
                  clr: primaryClr,
                ),
              task.isCompleted==1?Container():
              _bottomSheetButton(
                label: "Edit Task",
                onTap: (){
                  Get.to(()=>EditTask(task: task));
                },
                context: context,
                clr: yellowClr,
              ),
              _bottomSheetButton(
                label: "Delete Task",
                onTap: (){
                  notifyHelper.cancelScheduledNotification(task.id!);
                  _taskController.delete(task);
                  _taskController.getTasks();
                  Get.back();
                },
                context: context,
                clr: Colors.red[300]!,
              ),
              SizedBox(height: 10,),
              _bottomSheetButton(
                label:"Close",
                onTap: (){
                  Get.back();
                },
                isClose: true,
                context: context,
                clr: Colors.red[300]!,
              ),
              Spacer(),
              ],
          ),
        ),
      )
    );
  }
  _bottomSheetButton({
    required String label,
    required Function()? onTap,
    required Color clr,
    required BuildContext context,
    bool isClose=false
}){
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 40,
        width: MediaQuery.of(context).size.width*0.9,
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: isClose==true?Get.isDarkMode?Colors.black:Colors.grey[300]!:clr,
          ),
          borderRadius: BorderRadius.circular(20),
          color: isClose==true?Colors.grey[300]:clr,
        ),
        child: Center(
            child: Text(label,style: isClose?labelStyle:labelStyle.copyWith(color: Colors.white),)
        ),
      ),
    );
  }
  _addDateBar(){
    return Container(
      margin: const EdgeInsets.only(left: 20,top: 20),
      child: DatePicker(
        DateTime.now(),
        height: 100,
        width: 80,
        initialSelectedDate: DateTime.now(),
        selectionColor: primaryClr,
        selectedTextColor: Colors.white,
        dateTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        dayTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        monthTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        onDateChange: (date){
         setState(() {
           _selectedDate=date;
         });
        },
      ),
    );
  }
  _appTaskBar(){
    return Container(
      margin: const EdgeInsets.only(left: 20,right: 20,top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat.yMMMMd().format(DateTime.now()),
                  style: subHeadingStyle,
                ),
                Text("Today",style: headingStyle,)
              ],
            ),
          ),
          MyButton(label: "+ Add Task",onTap:() async {
            await Get.to(()=>TaskAddPage());
            _taskController.getTasks();
          }),
        ],
      ),
    );
  }
  _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      leading: GestureDetector(
        onTap: (){
          ThemeService().switchTheme();
         notifyHelper.displayNotification(
              title: 'Theme changed',
              body: Get.isDarkMode?"Activated light Mode Theme":"Activated Dark Mode Theme"
          );
        },
        child: Icon(Get.isDarkMode?Icons.sunny:Icons.nightlight_round,
          size: 30,
          color: Get.isDarkMode?Colors.white:Colors.black,),
      ),
      actions: [
        PopupMenuButton(
            icon: Icon(Icons.person,
              size: 30,
              color: Get.isDarkMode?Colors.white:Colors.black,),
            itemBuilder: (context){
              return[
                PopupMenuItem<int>(
                  value: 0,
                  child: IconButton(icon: Icon(Icons.logout,
                    size: 25,
                    color: Get.isDarkMode?Colors.white:Colors.black,
                  ),
                    onPressed: () {
                      SystemNavigator.pop();
                    },),
                ),
              ];
            }
            ),
        SizedBox(width: 20,),
      ],
    );
  }
}
