import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
class NotificationPage extends StatelessWidget {
  final String? label;
  const NotificationPage({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: this.label.toString().split("|")[4]=='0'?Color(0xFF4e5ae8):this.label.toString().split("|")[4]=='1'?Color(0xFFff4667):Color(0xFFFFB746),
          leading: IconButton(
            onPressed: ()=>Get.back(),
            icon: Icon(Icons.arrow_back,
            color: Colors.white,),
          ),
          title: Text(this.label.toString().split("|")[0],
            style: TextStyle(color: Colors.white,fontSize: 18),),
        ),
      body: Padding(
        padding: EdgeInsets.only(top: 16),
        child: Container(
          padding:
          EdgeInsets.symmetric(horizontal: 20),
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(bottom: 12),
          child: Container(
            padding: EdgeInsets.all(16),
            //  width: SizeConfig.screenWidth * 0.78,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: this.label.toString().split("|")[4]=='0'?Color(0xFF4e5ae8):this.label.toString().split("|")[4]=='1'?Color(0xFFff4667):Color(0xFFFFB746),
            ),
            child: Row(
                children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: Colors.grey[200],
                          size: 18,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "" + this.label.toString().split("|")[2]+" - " +this.label.toString().split("|")[3],
                          style: GoogleFonts.lato(
                            textStyle:
                            TextStyle(fontSize: 13, color: Colors.grey[100]),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      this.label.toString().split("|")[1],
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(fontSize: 15, color: Colors.grey[100]),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
