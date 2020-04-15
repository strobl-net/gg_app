import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;


class SurveyPage extends StatefulWidget {
  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  bool _isLoading = false;
  var surveys;

  _fetchSurveys() async {
    setState(() => {
      _isLoading = true,
    });
    print("starting to fetch data");
    final url = "http://192.168.2.121:8000/api/surveys/";
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() => {
        this.surveys = data,
        _isLoading = false,
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSurveys();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Surveys"),
        actions: <Widget> [
          new IconButton(icon: new Icon(Icons.refresh),
          onPressed: () => {
            _fetchSurveys()
          })
        ],
      ),
      body: Center(
        child: _isLoading ? new CircularProgressIndicator() :
          new ListView.builder(
            itemCount: this.surveys != null ? this.surveys.length : 0,
            itemBuilder: (context, i) {
              final survey = this.surveys[i];
              return new FlatButton(
                onPressed: () => {
                  Navigator.push(context, 
                    new MaterialPageRoute(
                      builder: (context) => new SingleSurveyPage(
                        survey: survey)
                    )),
                },
                child: new Column(
                  children: <Widget>[
                    new Card(
                      child: Column (
                        children: <Widget>[
                          new ListTile(
                            leading: new Icon(Icons.alarm_add),
                            title: new Text(survey["name"]),
                            subtitle: new Text(survey["description"]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          )
      ),
    );
  }
}


class SingleSurveyPage extends StatefulWidget {
  final survey;

  SingleSurveyPage({Key key, @required this.survey}) : super(key: key);

  @override
  _SingleSurveyPageState createState() => _SingleSurveyPageState(survey);
}


class _SingleSurveyPageState extends State<SingleSurveyPage> {
  bool _isLoading = false;
  var survey;
  List optionsList;
  List surveyAnswers;
  List<TextEditingController> textController;

  _SingleSurveyPageState (this.survey);

  _putAnswer() async {
    setState(() => {
      _isLoading = true,
    });
    final url = "http://192.168.2.121:8000/api/answers/";
    final response = await http.put(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() => {
        this.survey = data,
        _isLoading = false,
      });
    }
  }
  @override
  void dispose() {
    for(var textController in this.textController) {
      textController.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    this.surveyAnswers = [for(var i=0; i<this.survey["questions"].length; i++) ""];
    this.textController = [for(var i=0; i<this.survey["questions"].length; i++) new TextEditingController()];
    this.optionsList = [for(var i=0; i<this.survey["questions"].length; i++) -1];
    for (var controller in this.textController) {
        controller.addListener(this.setTextValues);
    }
  }

  void setTextValues() {
    for (var i=0; i<this.survey["questions"].length; i++) {
      if (this.survey["questions"][i]["type"] == "text" || this.survey["questions"][i]["type"] == "number") {
        this.surveyAnswers[i] = textController[i].text;
        setState(() {
        });
      }
    }
  }

  bool checkCorrect() {
    for (var i=0; i<this.survey["questions"].length; i++) {
      if (this.survey["questions"][i]["type"] == "text" || this.survey["questions"][i]["type"] == "number"){
        if (this.surveyAnswers[i] == ""){
          return false;
        }
      }
      if (this.survey["questions"][i]["type"] == "radio"){
        if (this.surveyAnswers[i] == null || this.surveyAnswers[i] == "" || this.surveyAnswers[i] == -1){
          return false;
        }
      }  
    }
    return true;
  }

  @override
    Widget build(BuildContext context) {
      return new Scaffold (
        appBar: new AppBar(
          title: Text(this.survey["name"]),
        ),
        body: new Column (
          children: <Widget>[
            new Expanded(
              child: new ListView.builder(
                itemCount: this.survey["questions"] != null ? this.survey["questions"].length : 0,
                itemBuilder: (context, i) {
                  final question = this.survey["questions"][i];
                  return new Container(
                    margin: const EdgeInsets.all(8.0),
                    child: new Column(
                      children: <Widget>[
                        new Container(
                          alignment: Alignment(-1.0, 0.0),
                          color: Colors.amber,
                          child: new Text(question["question"] + (question["required"]? " *" : "")),
                        ),
                        if (question["type"] == "text")
                          new Container(
                            color: Colors.white,
                            child: new TextField(
                              controller: this.textController[i],
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Your Answer'
                            ), 
                            )
                          )
                        else if (question["type"] == "number")
                          new Container(
                            color: Colors.white,
                            child: new TextField(
                              controller: this.textController[i],
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                WhitelistingTextInputFormatter.digitsOnly
                              ],
                            )
                          )
                        else if (question["type"] == "radio")
                          for (var option in question["options"])
                            new RadioListTile<int>(
                              title: new Text(option["name"]),
                              value: option["value"],
                              groupValue: this.optionsList[i],
                              onChanged: (int value) {
                                setState(() => {
                                  this.optionsList[i] = value,
                                  this.surveyAnswers[i] = value.toString(),
                                  print(this.surveyAnswers)
                                });
                              }
                            )
                        else
                          new Text("Invalid / No Type given")
                      ],
                    )
                  ); 
                },
              ),
            ),
          
          new RaisedButton(
            onPressed: checkCorrect()? () => {
              print("To send:"),
              print(this.surveyAnswers),
              print("--------------"),
            } : null,
            child: Text(
              'Submit',
              style: TextStyle(fontSize: 20)
            ),
          ),
        ],
      )
    );
  }
}