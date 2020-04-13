import 'package:flutter/material.dart';
import 'package:gg_app/views/surveys.dart';
import 'package:gg_app/views/mensa.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        backgroundColor: Colors.redAccent,
      ),
      drawer: new Drawer(
        child: new ListView(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountName: new Text("TryAnle"),
              accountEmail: new Text("TryAngle@Test.com")
            ),
            new ListTile(
              title: new Text("Surveys"),
              trailing: new Icon(Icons.question_answer),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new SurveyPage())),
            ),
            new ListTile(
              title: new Text("Mensa"),
              trailing: new Icon(Icons.fastfood),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new MensaPage())),
            ),
            new Divider(),
            new ListTile(
              title: new Text("Close"),
              trailing: new Icon(Icons.cancel),
              onTap: () => Navigator.of(context).pop()
            )
          ],
        ),
      ),
      body: Center(
        child: new Text("HomePage")
      ),
    );
  }
}
