import 'package:church_of_christ/data/models/database.dart';
import 'package:church_of_christ/data/models/user.dart';
import 'package:church_of_christ/data/models/user_repository.dart';
import 'package:church_of_christ/ui/widgets/button_green.dart';
import 'package:church_of_christ/ui/widgets/gradient_back.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  double screenWidht;

  @override
  Widget build(BuildContext context) {
      screenWidht = MediaQuery.of(context).size.width;
    final user = Provider.of<UserRepository>(context);


    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Login",
          style: TextStyle(fontFamily: 'Lato'),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          GradientBack(height: null),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Container(
                    margin: EdgeInsets.only(
                      left: 50.0,
                      right: 50.0,
                    ),
                    width: screenWidht,
                    child: Text("Bienvenido \n Esta es tu aplicación \n de la iglesia",
                      style: TextStyle(
                          fontSize: 37.0,
                          fontFamily: "Lato",
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),

              ButtonGreen(text: "Registrate con gmail",
                onPressed: () async {
                  user.signOut();
                  if (await user.signInWithGoogle()){
                    final dbUser = DbChurch();

                    dbUser.getUser(user.user.uid).then((User user){

                    }).catchError((error){
                      dbUser.updateUserData(
                          User(
                            uid: user.  user.uid,
                            name: user.user.displayName,
                            email: user.user.email,
                            photoURL: user.user.photoUrl,
                            isAdmin: false,
                            baptismDate: DateTime.now(),
                            baptized: false,
                            birthday: DateTime.now(),
                          )
                      ).then(( _ ) async{
                          final SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setString(
                            'register_date',
                            DateTime.now().add(Duration(days: 14)).toIso8601String(),
                          );
                          prefs.setBool('register_seen', true);
                      });
                    });
                  }
                  else{
                    print("SOMETHINGS WRONG!!");
                  }
                },
                width: 300.0,
                height: 50.0,
                colors: [
                  Color(0xFFa7ff84),//arriba
                  Color(0xFF1cbb78)//bajo
                ],
              )

            ],
          )
        ],
      ),
    );
  }
}
