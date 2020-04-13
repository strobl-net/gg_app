import 'dart:convert';

import 'package:flutter/material.dart';
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

  SingleSurveyPage({this.survey});

  @override
  _SingleSurveyPageState createState() => _SingleSurveyPageState();
}


class _SingleSurveyPageState extends State<SingleSurveyPage> {
  bool _isLoading = false;
  var survey;
  var survey_answer;

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
    Widget build(BuildContext context) {
      setState(() => {
        this.survey = widget.survey,
      });
      print('-----');
      print(this.survey['questions'].length);
      return new Scaffold(
        appBar: new AppBar(
          title: Text(widget.survey["name"]),
        ),
        body: Center(
          child: new ListView.builder(
            itemCount: this.survey["questions"] != null ? this.survey["questions"].length : 0,
            itemBuilder: (context, i) {
              final question = this.survey["questions"][i];
              return new Text(question["question"]);
            })
        )
      );
    }
}