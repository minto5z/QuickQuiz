import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:quickquiz/apidata/apidata.dart';
import 'package:quickquiz/global.dart';
import 'package:quickquiz/pages/home.dart';
import 'package:quickquiz/signup/signup.dart';
import 'package:path_provider/path_provider.dart';

File jsonFile;
Directory dir;
String fileName = "myJSONFile.json";
bool fileExists = false;
Map<dynamic, dynamic> fileContent;
var acct;



class LoginForm extends StatefulWidget {
  final String name;

  LoginForm({Key key, this.name}) : super(key: key);

  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {


  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  bool _isButtonDisabled;

 // String msg ='';
 // final scaffoldKey = new GlobalKey<ScaffoldState>();
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
        _login();
        profileLoad();
        }
  }

  void loginError() {
    Scaffold.of(context).showSnackBar(
      new SnackBar(
        backgroundColor: Colors.red,
        content: new Container(
          height: 50.0,
          child: new Column(
            children: <Widget>[
              new Text("The user credentias were incorrect..!" , style: new TextStyle(fontSize: 20.0,fontWeight: FontWeight.w700),),
            ],
          ),
        ),
        //content: new Text("Please Wait..."),
      ),
    );
  }

  void profileLoad() {
    Scaffold.of(context).showSnackBar(
      new SnackBar(
        content: new Text("Please Wait..."),
      ),
    );
  }

  void noNetwork() {
    Scaffold.of(context).showSnackBar(
      new SnackBar(
        content: new Text('Please Check Network Connection!'),
      ),
    );
  }



  Future<String> _login() async {
    try{

        final accessToken = await http.post(APIData.tokenApi, body: {
          "email": _emailController.text, "password": _passwordController.text,

        });
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

              print(dataUser);
              print(userDetail);
              var router = new MaterialPageRoute(
                  builder: (BuildContext context) => new QuizHome(
                    name: name, email: email, nameInitial: nameInitial,
                  ));
              Navigator.of(context).push(router);
              print("welcome admin");
              setState(() {
                message= "welcome admin";
              });
              writeToFile("user", _emailController.text);
              writeToFile("pass", _passwordController.text);

              setState(() {
                name= userName;
                email= userEmail;
                nameInitial= userName[0];
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
              setState(() {
                _isButtonDisabled = true;
              });

            }
            else{
                loginError();
//                setState(() {
//                  msg ='${user['message']}!';
//                });
//              print(msg);
            }

        return null;

    }catch(e){

        noNetwork();
        return null;

      }


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

  @override
  Widget build(BuildContext context) {
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

                new Image.asset('images/logo.png', scale: 2.0,
                  width: 120.0,
                  height: 120.0,
                  color: Colors.green.withOpacity(1.0),
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
                  "Sign in to continue",
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
//                      Text(msg, style: new TextStyle(
//                        color: Colors.red,
//                        fontSize: 20.0,
//                      ),),

                      SizedBox(
                        height: 10.0,
                      ),
                      _emailField(),

                      _passwordField(),

                      SizedBox(
                        height: 30.0,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 30.0),
                        width: double.infinity,
                        child: RaisedButton(
                          padding: EdgeInsets.all(12.0),
                          shape: StadiumBorder(),
                          child: Text(
                            "LOGIN",
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
                              text: "If you don't have an account?",
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
                              builder: (BuildContext context) => new SignUp());
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
      );

  }

}

