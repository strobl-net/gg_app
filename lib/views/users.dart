import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:gg_app/.env.dart' as env;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}


class _UsersPageState extends State<UsersPage> {
  SharedPreferences sharedPreferences;
  bool _isLoading = false;
  var users;
  var profiles;


  _fetchUsersAndProfile() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() => {
      _isLoading = true,
    });
    var baseUrl = env.environment['baseUrl'];
    final url = "$baseUrl/api/profiles/";
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Token " + sharedPreferences.getString("user.token")
      }
    );

    if (response.statusCode == 200) {
      profiles = jsonDecode(response.body);
      setState(() => {
        _isLoading = false,
        print(profiles)
      });
      
    } else {
      print(response.body);
    }
  }


  @override
  void initState() {
    SharedPreferences.getInstance().then((sharedPreferences) {
      setState(() =>{
        this.sharedPreferences = sharedPreferences  ,
        _fetchUsersAndProfile(),
      });
    });
    super.initState();
  }

  @override
  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Users"),
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.refresh),
          onPressed: () => {
            _fetchUsersAndProfile(),
          })
        ],
      ),
      body: Center(
        child: _isLoading ? new CircularProgressIndicator() :
        new ListView.builder(
          itemCount: this.profiles != null ? this.profiles.length : 0,
          itemBuilder: (context, i) {
            final profile = this.profiles[i];
            return new FlatButton(
              onPressed: () => {
                print("hello")
              }, 
              child: new Column(
                children: <Widget>[
                  new Card(
                    child: Column(
                      children: <Widget> [
                        if (profile["is_teacher"])
                          new ListTile(
                            leading: new Icon(Icons.star),
                            title: new Text(profile["user"]),
                            subtitle: new Text("teacher"),
                          )  
                        else if (profile["is_super_student"])
                          new ListTile(
                            leading: new Icon(Icons.person),
                            title: new Text(profile["user"]),
                            subtitle: new Text("is super student"),
                          )
                        else if (profile["is_tech"])
                          new ListTile(
                            leading: new Icon(Icons.person),
                            title: new Text(profile["user"]),
                            subtitle: new Text("is tech student"),
                          )

                        else
                          new ListTile(
                            leading: new Icon(Icons.person_outline),
                            title: new Text(profile["user"]),
                            subtitle: new Text("is a normal student"),
                          )
                      ]
                    )
                  )
                ],
              )
            );
          }
        )
      ),
    );
  }
}