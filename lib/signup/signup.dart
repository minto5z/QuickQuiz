import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickquiz/apidata/apidata.dart';
import 'package:quickquiz/global.dart';
import 'package:quickquiz/main.dart';
import 'package:quickquiz/pages/home.dart';
import 'package:quickquiz/ui/widgets/CustomShowDialog.dart';
import 'package:quickquiz/ui/widgets/common_scaffold.dart';
import 'package:path_provider/path_provider.dart';


class SignUp extends StatefulWidget {
  final String name;

  SignUp({Key key, this.name}) : super(key: key);

  @override
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUp> {

  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _confirmPasswordController =  new TextEditingController();
  bool _isButtonDisabled;

  String msg ='';
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();


  @override
  void initState() {
    super.initState();
    _isButtonDisabled = false;
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
            //title: new Text('Alert'),
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
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('Ok'),
              ),
            ],
          ),
        );
      }
      else{
        profileLoad();
        registration();
      }

    }
  }


  Future<String> registration() async{
    try{
    var url=APIData.registerApi;
    final register= await http.post(url, body: {
      "name": _nameController.text,
      "email": _emailController.text,
      "password": _passwordController.text,
    });
    if(register.statusCode == 200){
      print(register.statusCode);
      writeToFile("user", _emailController.text);
      writeToFile("pass", _passwordController.text);
      loginFromFIle();
      setState(() {
        _isButtonDisabled = true;
      });
    }else{
      if(register.statusCode == 302){
        loginError();
        print(register.statusCode);
      }else{
        wentWrong();
        print(register.statusCode);
      }
    }
    return null;
    }catch(e){
      noNetwork();
      return null;
    }
  }
  File _image;
  Future _getImage() async{
    final image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
       _image = image;
    });

  }

  void loginError() {
    final snackBar = new SnackBar(
      content: new Text("Already Exists"),
    );
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void wentWrong() {
    final snackBar = new SnackBar(
      content: new Text("Something Went Wrong"),
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



  Future<String> loginFromFIle() async{
    if (fileExists) {
      print(fileContent);
      final accessToken = await http.post(APIData.tokenApi, body: {
        "email": fileContent['user'], "password": fileContent['pass'],

      });
      print(accessToken.body);
      print(accessToken.body);
      var user = json.decode(accessToken.body);
      if(accessToken.statusCode == 200){

        final response = await http.get(APIData.quizCatApi,
            // ignore: deprecated_member_use
            headers: {HttpHeaders.AUTHORIZATION: "Bearer ${user['access_token']}!"});

        setState(() {
          fullData="Bearer ${user['access_token']}!";
        });

        dataUser= json.decode(response.body);
        userDetail=  dataUser['users'];
        userRole=  userDetail['role'];
        userId= userDetail['id'];
        userName= userDetail['name'];
        userEmail= userDetail['email'];
        userMobile= userDetail['mobile'];
        userAddress= userDetail['address'];
        userCity= userDetail['city'];
        topicsData=dataUser['topics'];
        qData=dataUser['questions'];
        print(userDetail);
        setState(() {
          name= userName;
          nameInitial= userName[0];
          email= userEmail;
          if(userRole == 'A'){
            role = "Admin";
          }else{
            role = "Student";
          }
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
            builder: (BuildContext context) => new QuizHome(
              name: name,
              email: email,
              nameInitial: nameInitial,
            ));
        Navigator.of(context).push(router);
      }
      return (accessToken.body);
    } else {
      var router = new MaterialPageRoute(
          builder: (BuildContext context) => new Home());
      Navigator.of(context).push(router);
    }
    return (null);
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

    this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));
    print(fileContent);

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


  Widget _confirmPasswordField() {
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

  Widget bodyData(){

    return new Form(
      onWillPop: () async {
        return false;
      },
      key: formKey,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
        child: Center(

          child: new ListView(

            children: <Widget>[

              // new Image.asset('images/logo.png', scale: 2.0,
              //   width: 120.0,
              //   height: 120.0,
              //   color: Colors.green.withOpacity(1.0),
              // ),
              // Container(
              //     decoration: BoxDecoration(
              //         color: Colors.white,
              //         border: Border.all(color: Colors.grey),
              //         borderRadius: BorderRadius.circular(100.0),
              //         boxShadow: [BoxShadow(color: Colors.blueAccent)]),
              //     width: 120,
              //     height: 120,
              //     margin: EdgeInsets.all(24.0),
              //     child: IconButton(
              //       icon: _image ==null ? Icon(Icons.person_add_outlined) : Image.file(_image),
              //       iconSize: 120,
              //       onPressed: _getImage,
              //     ),
              // ),

              RawMaterialButton(
                onPressed: _getImage,
                elevation: 2.0,
                fillColor: Colors.white,
                child: _image ==null ? SizedBox(width: MediaQuery.of(context).size.width*0.25, height: MediaQuery.of(context).size.height*0.25, child: Icon(Icons.person_add_outlined,size: MediaQuery.of(context).size.height*0.10,)) : Image.file(_image),
                padding: EdgeInsets.all(15.0),
                shape: CircleBorder(),
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                "Welcome to Quick-Quiz",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold,
                    fontFamily: "AvenirNext",
                    color: Colors.green),
              ),
              SizedBox(
                height: 5.0,
              ),
              Text(
                "Register to continue",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(
                height: 30.0,
              ),

              new Container(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[

                    _nameField(),

                    _emailField(),

                    _passwordField(),

                    _confirmPasswordField(),

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
                          "REGISTER",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.green,
                        onPressed: () {
                         // ignore: unnecessary_statements
                         _isButtonDisabled ? null : _submit();

                        },
                      ),
                    ),
                    new InkWell(
                      child: new RichText(
                        text: new TextSpan(children: [
                          new TextSpan(
                            text: "Already have an account?",
                            style: new TextStyle(
                                color: Colors.black,
                                fontSize: 16.5,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600),
                          ),
                          new TextSpan(
                            text: 'Click Here. ',
                            style: new TextStyle(
                                color: Colors.green,
                                fontSize: 17.5,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold),
                          )
                        ]),
                      ),
                      onTap: () {
                        var router = new MaterialPageRoute(
                            builder: (BuildContext context) => new Login());
                        Navigator.of(context).push(router);
                      },
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
    quizAppBar: false,
  );

  @override
  Widget build(BuildContext context) {
    return _scaffold();

    // return
  }


}

