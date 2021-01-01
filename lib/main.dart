import 'package:flutter/material.dart';
import 'package:quickquiz/loading/loading_screen.dart';
import 'package:quickquiz/login/login.dart';
import './signup/signup.dart';

void main() {
    runApp(
        new MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Quick Quiz',
          home: LoadingScreen(),
          color: Colors.green,
        ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(


      body: new Container(
        alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB(0.0, 90.0, 0.0, 0.0),
        child: Center(
          child: new ListView(


            children: <Widget>[

              new Image.asset('images/logo.png',scale: 2.0,width: 120.0,height: 120.0, color: Colors.green.withOpacity(1.0),
              ),

              SizedBox(
                height: 10.0,
              ),
              Text(
                "Welcome to Quick-Quiz",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold,fontFamily: "AvenirNext",color: Colors.green),
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
                height: 50.0,
              ),

              new ListTile(
                title: new MaterialButton(
                    height: 50.0,
                    color: Colors.green.shade400,
                    textColor: Colors.white,
                    child: new Text("Login"),
                    onPressed: () {
                      var router = new MaterialPageRoute(
                          builder: (BuildContext context) => new LoginState());
                      Navigator.of(context).push(router);
                    }),
              ),
              new ListTile(
                title: new MaterialButton(
                    height: 50.0,
                    color: Colors.white,
                    textColor: Colors.black,
                    child: new Text("Register"),
                    onPressed: () {
                      var router = new MaterialPageRoute(
                          builder: (BuildContext context) => new SignUp());
                      Navigator.of(context).push(router);
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }

}

class Login extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login',
      home: new LoginState(),

    );
  }
}

class LoginState  extends StatefulWidget {
  @override
  _LoginState  createState() => new _LoginState ();
}


class _LoginState extends State<LoginState> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     body: LoginForm()
    );
  }
}





