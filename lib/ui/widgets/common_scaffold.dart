import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quickquiz/profile/profile_edit.dart';
import 'package:quickquiz/ui/widgets/common_drawer.dart';

class CommonScaffold extends StatelessWidget {
  final appTitle;
  final Widget bodyData;
  final showDrawer;
  final backGroundColor;
  final scaffoldKey;
  final centerDocked;
  final floatBtn;
  final quizAppBar;

  CommonScaffold(
      {this.appTitle,
      this.bodyData,
      this.showDrawer = false,
      this.floatBtn = false,
      this.backGroundColor,
      this.scaffoldKey,
      this.centerDocked = false,
      this.quizAppBar = false,
  });



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey != null ? scaffoldKey : null,
      backgroundColor: backGroundColor != null ? backGroundColor : null,
      appBar: quizAppBar ? AppBar(
        elevation: defaultTargetPlatform == TargetPlatform.android ? 0.0 : 0.0,
        //backgroundColor: Colors.yellow,
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        title: Text("QuickQuiz"),
        centerTitle: true,
      //  automaticallyImplyLeading: false,
//        actions: <Widget>[
//      IconButton(
//        icon: Icon(Icons.list),
//        onPressed: () {},
//      )
//        ],
      ) : null,
      drawer: showDrawer ? CommonDrawer() : null,
      body: bodyData,
      floatingActionButton: floatBtn ? FloatingActionButton(
       backgroundColor: Colors.green,
        foregroundColor: Colors.yellow,

       tooltip:"logout",

        onPressed: () {

           var router = new MaterialPageRoute(
               builder: (BuildContext context) => new ProfileEdit(

               )
           );
           Navigator.of(context).push(router);
        },
        child: Icon(Icons.edit),

      ) : null,
      floatingActionButtonLocation: centerDocked
          ? FloatingActionButtonLocation.centerDocked
          : FloatingActionButtonLocation.endFloat,
    );
  }
}
