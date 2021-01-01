import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:quickquiz/pages/home.dart';
import 'package:quickquiz/apidata/apidata.dart';
import 'package:quickquiz/global.dart';
import 'package:quickquiz/profile/profile_one_page.dart';
import 'package:quickquiz/ui/widgets/CustomShowDialog.dart';
import 'package:quickquiz/ui/widgets/common_scaffold.dart';
import 'package:path_provider/path_provider.dart';

File jsonFile;
Directory dir;
String fileName = "myJSONFile.json";
bool fileExists = false;
Map<dynamic, dynamic> fileContent;
var acct;



class ProfileEdit extends StatefulWidget {
  final String name;

  ProfileEdit({Key key, this.name}) : super(key: key);

  @override
  ProfileEditState createState() => ProfileEditState();
}

class ProfileEditState extends State<ProfileEdit> {



  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _confirmPasswordController =  new TextEditingController();
  final TextEditingController _mobileController =  new TextEditingController();
  final TextEditingController _addressController =  new TextEditingController();
  final TextEditingController _cityController =  new TextEditingController();


  String msg ='';
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();


  @override
  void initState() {
    _emailController.text = email;
    _nameController.text = name;
    if(mobile == 'N/A'){
      _mobileController.text = '';
    }else{
      _mobileController.text = mobile;
    }
    if(city == 'N/A'){
      _cityController.text = '';
    }else{
      _cityController.text = city;
    }
    if(address == 'N/A'){
      _addressController.text = '';
    }else{
      _addressController.text = address;
    }
    super.initState();
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + fileName);
      fileExists = jsonFile.existsSync();
      if (fileExists) {
        this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));

      }

    });
  }


  void _submit() {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
      if(_passwordController.text != _confirmPasswordController.text){

        showDialog(
          context: context,
          builder: (context) => new CustomAlertDialog(
            title: new Text('Alert..!',textAlign: TextAlign.left,),
            content:
            new Container(
              width: 260.0,
              height: 50.0,
              decoration: new BoxDecoration(
                shape: BoxShape.rectangle,
                color: const Color(0xFFFFFF),
                borderRadius: new BorderRadius.all(new Radius.circular(30.0)),
              ),
              child: new Column(
                children: <Widget>[
                  new Text('Password & Confirm Password does not match'),
                ],
              ),
            ),
          ),
        );
      }
      else{
        profileLoad();
        profileedit();
      }

    }
  }


  Future<String> profileedit() async{

try{
  final edit = await http.post(
    // ignore: deprecated_member_use
      APIData.userProfileApi, headers: {HttpHeaders.AUTHORIZATION: fullData}, body: {
    "name": _nameController.text,
    "email": _emailController.text,
    "password": _passwordController.text,
    "mobile": _mobileController.text,
    "address": _addressController.text,
    "city": _cityController.text,
    "role": "S",
  });
  print(edit);
  if(edit.statusCode == 200){

    writeToFile("user", _emailController.text);
    writeToFile("pass", _passwordController.text);

    final response = await http.get(APIData.quizCatApi,
        // ignore: deprecated_member_use
        headers: {HttpHeaders.AUTHORIZATION: fullData});

    var dataUser= json.decode(response.body);
    var userDetail=  dataUser['users'];
    // userRole=  userDetail['role'];
    userId= userDetail['id'];
    var userName= userDetail['name'];
    var userEmail= userDetail['email'];
    var userMobile= userDetail['mobile'];
    var userAddress= userDetail['address'];
    var userCity= userDetail['city'];
    topicsData=dataUser['topics'];
    qData=dataUser['questions'];
    print(userDetail);
    print(edit.statusCode);
    setState(() {
      name= userName;
      nameInitial= userName[0];
      email= userEmail;
      if(userMobile == null){
        mobile="N/A";
      }else{
        mobile=userMobile;
      }
      if(userAddress == null){
        address="N/A";
      }else{
        address=userAddress;
      }
      if(userCity == null){
        city="N/A";
      }else{
        city=userCity;
      }
    });

    var router = new MaterialPageRoute(
        builder: (BuildContext context) => new ProfileOnePage(
          name: name, email: email, nameInitial: nameInitial,
        ));
    Navigator.of(context).push(router);
    print(fullData);
    print(edit.body);

  }else{
    if(edit.statusCode == 500){
      loginError();
    }
  }
  return (edit.body);
}catch(e){
  noNetwork();
  return null;
}




  }

  void loginError() {
    final snackBar = new SnackBar(
      content: new Text("Already Exists"),
    );
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void profileLoad() {
    final snackBar = new SnackBar(
      content: new Text("Please Wait..."),
    );
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void noNetwork() {
    final snackBar = new SnackBar(
      content: new Text("Please Check Network Connection!"),
    );
    scaffoldKey.currentState.showSnackBar(snackBar);
  }


  Widget _nameField() {
    return new Container(
      padding: EdgeInsets.symmetric(vertical: 5.0,horizontal: 30.0),
      child: TextFormField(
        maxLines: 1,
        controller: _nameController,
        decoration: InputDecoration(
          hintText: "Enter your Name",
          labelText: "Name",
        ),
      validator: (val){
        if(val.length == 0){
          return 'Name can not be empty';
        }else {
          return null;
        }
      },
        onSaved: (val) => _nameController.text = val,
      ),
    );
  }

  Widget _emailField() {
    return new Container(
      padding: EdgeInsets.symmetric(vertical: 5.0,horizontal: 30.0),
      child: TextFormField(
        maxLines: 1,
        controller: _emailController,
        decoration: InputDecoration(
          hintText: "Enter your Email",
          labelText: "Email",
        ),
        validator: (val){
          if(val.length == 0){

            return 'Email can not be empty';

          }else{

            if(!val.contains('@')){

              return 'Invalid Email';

            }else {

              return null;

            }
          }
        },
        onSaved: (val) => _emailController.text = val,
      ),
    );
  }


  Widget _passwordField() {
    return new Container(
      padding: EdgeInsets.symmetric(vertical: 5.0,horizontal: 30.0),
      child: new TextFormField(
        decoration: new InputDecoration(labelText: "Password"),
        validator: (val){
          if(val.length < 6){
            if(val.length == 0){

              return 'Password can not be empty';

            }else{

              return 'Password too short';

            }
          }else{

            return null;

          }
        },
        onSaved: (val) => _passwordController.text = val,
        obscureText: true,
      ),
    );
  }


  Widget _confirmpasswordField() {
    return new Container(
      padding: EdgeInsets.symmetric(vertical: 5.0,horizontal: 30.0),
      child: TextFormField(
        controller: _confirmPasswordController,
        decoration: new InputDecoration(
            hintText: 'Confirm Password',
            labelText: 'Confirm Password',
            contentPadding:
            EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0)),
        obscureText: true,
        validator: (val){
          if(val.length < 6){
            if(val.length == 0){
              return 'Password can not be empty';
            }
            else{
              return 'Password too short';
            }
          }
          else{
            return null;
          }
        },
        onSaved: (val) => _confirmPasswordController.text = val,
      ),

    );
  }

  Widget _mobileField() {
    return new Container(
      padding: EdgeInsets.symmetric(vertical: 5.0,horizontal: 30.0),
      child: TextField(
        controller: _mobileController,
        decoration: new InputDecoration(
            hintText: 'Enter Mobile Number',
            labelText: 'Mobile No.',
            contentPadding:
            EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0)),

      ),
    );
  }

  Widget _cityField() {
    return new Container(
      padding: EdgeInsets.symmetric(vertical: 5.0,horizontal: 30.0),
      child: TextField(
        controller: _cityController,
        decoration: new InputDecoration(
            hintText: 'Enter Your City',
            labelText: 'City',
            contentPadding:
            EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0)),

      ),
    );
  }

  Widget _addressField() {
    return new Container(
      padding: EdgeInsets.symmetric(vertical: 5.0,horizontal: 30.0),
      child: TextFormField(
        controller: _addressController,
        decoration: new InputDecoration(
            hintText: 'Enter Your Address',
            labelText: 'Address',
            contentPadding:
            EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0)),

      ),
    );
  }





  void createFile(Map<String, String> content, Directory dir, String fileName) {
    print("Creating file!");
    File file = new File(dir.path + "/" + fileName);
    file.createSync();
    setState(() {
      fileExists = true;
    });
    file.writeAsStringSync(json.encode(content));
    this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));

    //  print(fileContent);
  }

  void writeToFile(String key, String value) {
    print("Writing to file!");
    Map<String, String> content = {key: value};
    if (fileExists) {
      print("File exists");
      Map<dynamic, dynamic> jsonFileContent = json.decode(jsonFile.readAsStringSync());
      jsonFileContent.addAll(content);
      jsonFile.writeAsStringSync(json.encode(jsonFileContent));
    } else {
      print("File does not exist!");
      createFile(content, dir, fileName);
    }
    setState(() {
      acct = value;
    });
    print(acct);
    // print(acct);
    //  this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));
    this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));
    print(fileContent);

    //  print(fileContent["admin@info.com"]);
  }
Widget bodyData(){

  return new Form(
    key: formKey,
   // child:  Scaffold(
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        child: Center(

          child: new ListView(

            children: <Widget>[

              new Container(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[

                    _nameField(),

                    _emailField(),

                    _passwordField(),

                    _confirmpasswordField(),

                    _mobileField(),

                    _cityField(),

                    _addressField(),

                    SizedBox(
                      height: 30.0,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 5.0,horizontal: 30.0),
                      width: double.infinity,
                      child: RaisedButton(
                        padding: EdgeInsets.all(12.0),
                        shape: StadiumBorder(),
                        child: Text(
                          "SUBMIT",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.green,
                        onPressed: () {
                          _submit();
                          //  profileData();
                          // _login();
                        },
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
   // ),
  );
}

  Widget _scaffold() => CommonScaffold(
    scaffoldKey: scaffoldKey,
    bodyData: bodyData(),
    floatBtn:false,
    quizAppBar: true,
  );

  @override
  Widget build(BuildContext context) {
   return _scaffold();

   // return
  }


}

