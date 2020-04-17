import 'package:flutter/material.dart';
import 'package:gg_app/views/surveys.dart';
import 'package:gg_app/views/mensa.dart';
import 'package:gg_app/views/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SharedPreferences sharedPreferences;
  bool _isLoggedIn = false; 

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.getString("user.token") == null) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
    } else {
      setState(() {
        this._isLoggedIn = true;
      });
    }
  }

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
            if(this._isLoggedIn)
              new UserAccountsDrawerHeader(
                accountName: new Text(sharedPreferences.getString("user.name")),
                accountEmail: new Text(sharedPreferences.getString("user.email"))
              )
            else
              new Text("not logged in"),
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
              title: new Text("Logout"),
              trailing: new Icon(Icons.lock),
              onTap: () => {
                sharedPreferences.clear(),
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false),
              },
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
