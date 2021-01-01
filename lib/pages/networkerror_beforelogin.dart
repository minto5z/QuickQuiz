import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quickquiz/loading/loading_screen.dart';
import 'package:quickquiz/ui/widgets/common_scaffold.dart';

class NoNetworkL extends StatefulWidget {
  final String name;

  NoNetworkL({Key key, this.name}) : super(key: key);

  @override
  NoNetworkLState createState() => NoNetworkLState();
}

class NoNetworkLState extends State<NoNetworkL> {

  var refreshKey = GlobalKey<RefreshIndicatorState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();

  var _connectionStatus = 'Unknown';
  Connectivity connectivity;
  StreamSubscription<ConnectivityResult> subscription;

  @override
  void initState() {
    super.initState();
    connectivity = new Connectivity();
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
          _connectionStatus = result.toString();
          print(_connectionStatus);
          if (result == ConnectivityResult.wifi ||
              result == ConnectivityResult.mobile) {
            var router = new MaterialPageRoute(
                builder: (BuildContext context) =>
                new LoadingScreen());
            Navigator.of(context).push(router);
          }else{
            setState(() {});
          }
        });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future<String> getData() async {
    try{
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var router = new MaterialPageRoute(
            builder: (BuildContext context) => new LoadingScreen());
        Navigator.of(context).push(router);}
    }on SocketException catch (_) {
      print('not connected');
    }
    return null;
  }

  Widget bodyData(){

    return new Scaffold(
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      appBar: AppBar(
        elevation: defaultTargetPlatform == TargetPlatform.android ? 0.0 : 0.0,
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        title: Text("QuickQuiz"),
        centerTitle: true,
        automaticallyImplyLeading: false,
//        actions: <Widget>[
//      IconButton(
//        icon: Icon(Icons.list),
//        onPressed: () {},
//      )
//        ],
      ),
      body: RefreshIndicator(
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

                      Text("Check Network Connection", style: new TextStyle(
                        color: Colors.red,
                        fontSize: 20.0,
                      ),),
                      SizedBox(
                        height: 30.0,
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // ),
        onRefresh: refreshList,
      ),
    );

  }

  Future<Null> refreshList() async {
    refreshKey.currentState?.show(atTop: true);
    await Future.delayed(Duration(seconds: 2));
    getData();
  }

  Widget _scaffold() => CommonScaffold(
    scaffoldKey: scaffoldKey,
    bodyData: bodyData(),
    floatBtn:false,
  );

  @override
  Widget build(BuildContext context) {
    return _scaffold();

    // return
  }


}

