import 'dart:io';
import 'package:flutter/material.dart';
import 'package:quickquiz/main.dart';
import 'package:quickquiz/pages/home.dart';
import 'package:quickquiz/profile/profile_one_page.dart';
import 'package:quickquiz/global.dart';
import 'package:quickquiz/ui/widgets/CustomShowDialog.dart';

class CommonDrawer extends StatefulWidget {
  CommonDrawer({Key key, this.name, this.email, this.nameInitial}) : super(key: key);
  final String name;
  final String email;
  final String nameInitial;
  @override
  CommonDrawerState createState() => CommonDrawerState();
}

class CommonDrawerState extends State<CommonDrawer> {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: new ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: new Text(name),
            accountEmail: new Text(email),
            currentAccountPicture: new CircleAvatar(
              backgroundColor: Colors.green,
              child: new Text(nameInitial),
            ),
            decoration: BoxDecoration(
                color: Color.fromRGBO(58, 66, 86, 1.0)
            ),
            margin: EdgeInsets.all(0.0),
          ),


          new ListTile(

            title: new Text("Home"),
            trailing: new Icon(Icons.home),
            onTap: (){
              Navigator.pop(context);
              var router = new MaterialPageRoute(
                  builder: (BuildContext context) => new QuizHome(
                    name: name, email: email, nameInitial: nameInitial,
                  ));
              Navigator.of(context).push(router);
            },
          ),

          new Divider(
            height: 5.0,
          ),

          new ListTile(
            title: new Text("My Profile"),
            trailing: new Icon(Icons.person),
            onTap: (){

              var router = new MaterialPageRoute(
                  builder: (BuildContext context) => new ProfileOnePage(
                    name: name, email: email, nameInitial: nameInitial,
                  ));
              Navigator.of(context).push(router);
            },
          ),

          new ListTile(
            title: new Text("Sign Out"),
            trailing: new Icon(Icons.settings_power),
            onTap: (){
              deleteFile();
              var router = new MaterialPageRoute(
                  builder: (BuildContext context) => new Home());
              Navigator.of(context).push(router);
            },
          ),

          new ListTile(
            title: new Text("Quit"),
            trailing: new Icon(Icons.close),
            onTap: (){
              showDialog(
                context: context,
                builder: (context) => new CustomAlertDialog(
                  title: new Text('Are you sure?',textAlign: TextAlign.center,),
                  content:
                  new Container(
                    width: 260.0,
                    height: 30.0,
                    decoration: new BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: const Color(0xFFFFFF),
                      borderRadius: new BorderRadius.all(new Radius.circular(30.0)),
                    ),
                    child: new Column(
                      children: <Widget>[
                        new Text('Do you want to exit'),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    new FlatButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: new Text('No'),
                    ),
                    new FlatButton(
                      onPressed: () => exit(0),
                      child: new Text('Yes'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void deleteFile() {
    print("Deleting file!");
    File file = new File(dir.path + "/" + fileName);
    file.delete();
    setState(() {
      fileExists = false;
    });

  }
}
