import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickquiz/apidata/apidata.dart';
import 'package:quickquiz/global.dart';
import 'package:http/http.dart' as http;
import 'package:quickquiz/pages/networkerror_afterlogin.dart';
import 'package:quickquiz/pages/question_loading.dart';
import 'package:quickquiz/pages/quiz_questions.dart';
import 'package:quickquiz/ui/widgets/CustomShowDialog.dart';

void main() {
  runApp(
      new MaterialApp(
        home: new QuickQuiz(),
      )
  );
}

class QuickQuiz extends StatefulWidget {
  QuickQuiz(
      {Key key, this.time, this.id, this.title, this.code, this.created, this.description, this.perQMark, this.timer, this.marks})
      : super(key: key);

  final title;
  final code;
  final created;
  final description;
  final perQMark;
  final timer;
  final id;
  final time;
  final marks;

  @override
  State<StatefulWidget> createState() {
    return new QuickQuizState();
  }
}


class QuickQuizState extends State<QuickQuiz> {
  final TextEditingController _quizCodeController = new TextEditingController();

  final topAppBar = AppBar(
    elevation: 0.1,
    backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
    title: Text("QuickQuiz"),
    centerTitle: true,
    actions: <Widget>[
    ],
  );

  @override
  Widget build(BuildContext context) {
    final makeBody = Column(

      mainAxisAlignment: MainAxisAlignment.center,

      children: <Widget>[
        new WillPopScope(
          onWillPop: () async => true,
          child: new Container(
            child: ListView.builder(

              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                final makeListTile = ListTile(

                  // contentPadding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),

                  title: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: ListTile(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                    title: Text(
                      widget.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                    subtitle: ListTile(
                      contentPadding: EdgeInsets.fromLTRB(
                          20.0, 10.0, 20.0, 0.0),
                      title: Text(
                        widget.perQMark,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20.0,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                      subtitle: ListTile(

                        title: Text(
                          widget.timer,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),

                        ),
                        subtitle: ListTile(

                          title: Text(
                            widget.created,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),

                          ),
                          subtitle: ListTile(

                            title: _quizCodeField(),

                          ),
                        ),

                      ),
                      ),

                    ),
                    onTap: () {
                      startQuiz();
                    },
                  );

                  final makeCard = Card(

                  elevation: 8.0,
                  margin: new EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 0.0),

                  child: Container(

                    decoration: BoxDecoration(
                        color: Color.fromRGBO(64, 75, 96, .9)),

                    child: makeListTile,

                  ),

                );

                return makeCard;
              },
            ),

          ),


        ),
        new Container(
            padding: EdgeInsets.all(10.0),
            child: new Text("Tap On Card To Start", style: TextStyle(
                color: Colors.white.withOpacity(0.2)
            ),)
        )

      ],

    );
    return new Scaffold(
      appBar: topAppBar,
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      body: SingleChildScrollView(child: makeBody),
    );
  }


  startQuiz() {
    if (_quizCodeController.text != widget.code) {
      showDialog(
        context: context,
        builder: (context) =>
        new CustomAlertDialog(
          //title: new Text('Alert'),
          content:
          new Container(
            width: 160.0,
            height: 50.0,
            decoration: new BoxDecoration(
              shape: BoxShape.rectangle,
              color: const Color(0xFFFFFF),
              borderRadius: new BorderRadius.all(new Radius.circular(30.0)),
            ),
            child: new Column(
              children: <Widget>[
                new Text('Quiz Code does not match'),
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
    else {
      var router = new MaterialPageRoute(
          builder: (BuildContext context) =>
          new QuestionLoading(
            id: widget.id,
            marks: widget.marks,
            time: widget.time,
          )

      );
      Navigator.of(context).push(router);
    }
  }

  Widget _quizCodeField() {
    return new Container(
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
      width: MediaQuery.of(context).size.width,
      child: TextFormField(
        maxLines: 1,
        controller: _quizCodeController,
        decoration: InputDecoration(
          hintText: " ",
          hintStyle: TextStyle(
              fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.w500),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white,
            ),
          ),

          labelText: "Quiz Code",
          labelStyle: TextStyle(
              fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.w500),

        ),
        style: TextStyle(
            fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.w500),
        validator: (val) {
          if (val.length == 0) {
            return 'QuizCode can not be empty';
          } else {
            if (!val.contains(' ')) {
              return 'Invalid QuizCode';
            } else {
              return null;
            }
          }
        },
        onSaved: (val) => _quizCodeController.text = val,
      ),
    );
  }

  Future<String> getData() async {
    try {
      var qCount;
      var qRight;
      var myMark;
      var totalM;

      final questions = await http.get(
          Uri.encodeFull(APIData.questionApi + "${widget.id}"),
          headers: {
            HttpHeaders.AUTHORIZATION: fullData // ignore: deprecated_member_use
          });

      var url = APIData.resultApi + "/${widget.id}";
      // ignore: deprecated_member_use
      var ans = await http.get(
          url, headers: {HttpHeaders.AUTHORIZATION: fullData});
      var resultDetails = json.decode(ans.body);
      print(resultDetails);
      qCount = resultDetails['count'];
      qRight = resultDetails['right'];
      print(qCount);
      totalM = qCount * widget.marks;
      myMark = qRight * widget.marks;


      var que;
      List ques;
      que = json.decode(questions.body);
      print(questions.statusCode);
      if (questions.statusCode == 300) {
        showDialog(
          context: context,
          builder: (context) =>
          new AlertDialog(
            title: new Text('Wait'),
            content: new Text('Your Quiz Will Began In Few Seconds'),

          ),
        );
        Navigator.push(context, new MaterialPageRoute(builder: (context) =>
        new Result(
          id: widget.id,
          perQMark: widget.marks,
          qCount: qCount,
          totalM: totalM,
          myMark: myMark,
        )));
      } else {
        ques = que['questions'];
        quizQuestion() {
          Navigator.push(context, new MaterialPageRoute(builder: (context) =>
          new QuizQuestion(
            id: widget.id,
            timer: widget.time,
            catQues: ques,
            perQMark: widget.marks,
            qCount: qCount,
            totalM: totalM,
          )));
        }
        noQuestion() {
          showDialog(
            context: context,
            builder: (context) =>
            new AlertDialog(
              title: new Text('Alert'),
              content: new Text('No Question Data'),
            ),
          );
          Timer(Duration(seconds: 2), () {
            Navigator.pop(context);
            Navigator.pop(context);
          });
        }

        ques.isEmpty ? noQuestion() : quizQuestion();
      }
    } on SocketException catch (_) {
      var router = new MaterialPageRoute(
          builder: (BuildContext context) => new NoNetwork());
      Navigator.of(context).push(router);
      print('not connected');
    }

    return null;
  }
}



