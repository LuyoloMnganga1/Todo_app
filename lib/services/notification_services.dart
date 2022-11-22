import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:todo_app/models/task.dart';
import 'package:todo_app/ui/notification_details.dart';

class NotifyHelper{
  FlutterLocalNotificationsPlugin
  flutterLocalNotificationsPlugin = new
  FlutterLocalNotificationsPlugin(); //

  Future<void> initializeNotification() async {
    _configureLocalTimeZone();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings("appicon");

    final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);



      final InitializationSettings initializationSettings =
      InitializationSettings(
      iOS: initializationSettingsIOS,
      android:initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onSelectNotification: selectNotification );

  }
  scheduledNotification(int hour ,int minutes, Task task) async {

    await flutterLocalNotificationsPlugin.zonedSchedule(
        task.id!.toInt(),
        task.title,
        task.note,
        _convertTime(hour,minutes),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'your channel name', 'your channel description')),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents:task.repeat.toString()=='Monthly'?DateTimeComponents.dayOfMonthAndTime:
        task.repeat.toString()=='Weekly'?DateTimeComponents.dayOfWeekAndTime:
        task.repeat.toString()=='None'?DateTimeComponents.dateAndTime:DateTimeComponents.time,
      payload: "${task.title}|"+"${task.note}|"+"${task.startTime}|"+"${task.endTime}|"+"${task.color}|",
    );

  }
  displayNotification({required String title, required String body}) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel name', 'your channel description',
        importance: Importance.max, priority: Priority.high);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: title,
    );
  }
  void requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  Future<void> cancelScheduledNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
  Future onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    Get.dialog(Text("Welcome to flutter"));
  }
  Future selectNotification(String? payload) async {
    if(payload =='Theme changed'){
    }else {
      Get.to(() => NotificationPage(label: payload));
    }
  }
  tz.TZDateTime _convertTime(int hour,int minutes){
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local,now.year,now.month,now.day,hour,minutes);
    if(scheduledDate.isBefore(now)){
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
  Future<void> _configureLocalTimeZone() async{
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }
}