

import 'dart:io';
import 'package:church_of_christ/data/models/database.dart';
import 'package:church_of_christ/data/models/event.dart';
import 'package:church_of_christ/data/models/user.dart';
import 'package:church_of_christ/data/models/user_repository.dart';
import 'package:church_of_christ/ui/pages/add_event.dart';
import 'package:church_of_christ/ui/pages/login_page.dart';
import 'package:church_of_christ/ui/widgets/custom_page.dart';
import 'package:church_of_christ/ui/widgets/loading_splash.dart';
import 'package:church_of_christ/ui/widgets/popup_settings.dart';
import 'package:church_of_christ/util/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MyEvents extends StatefulWidget {

  MyEvents({
    Key key,
  });

  @override
  State createState() {
    return _MyEvents();
  }
}

class _MyEvents extends State<MyEvents> {

  @override
  Widget build(BuildContext context) {

    return _handleCurrentSession();
  }

  Widget _handleCurrentSession(){
    return Consumer(
      builder: (context, UserRepository user, _) {
        switch(user.status){

          case Status.Uninitialized:
            return Splash();
            break;
          case Status.Authenticated:
            return
              MyEventScreen(uid:user.user.uid);
            break;
          case Status.Authenticating:
          case Status.Unauthenticated:
            return LoginPage();
            break;
        }
      },
    );
  }
}


class MyEventScreen extends StatefulWidget{

  final String uid;

  MyEventScreen({
    this.uid
  });

  @override
  State createState() {
    return _MyEventScreen();
  }
}

class _MyEventScreen extends State<MyEventScreen>{
  User myUser;

  Widget _getBodyBlanckPage(BuildContext context){
    var db = DbChurch();
    db.getUser(widget.uid).then((User user){
      setState(() {
        myUser = user;
      });
    }).catchError((onError) => print(onError));

    return Consumer<DbChurch>(
        builder: (context, model, child) => Scaffold(
          body: BlanckPage(
            title: FlutterI18n.translate(context, 'acuedd.events.myevents.title'),
            actions: <Widget>[
              PopupSettins()
            ],
            body: StreamBuilder(
              stream: db.streamEventsPerUser(widget.uid),
              builder: (context, AsyncSnapshot snapshot){
                if(snapshot.hasData){
                  return ListView(
                    padding: EdgeInsets.only(top: 20.0),
                    children: db.buildEvents(snapshot.data.documents, myUser),
                  );
                }
                return Text("Ocurrió un error al cargar");
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.add),
            tooltip: FlutterI18n.translate(context, 'acuedd.other.tooltip.search'),
            onPressed: (){
              ImagePicker.pickImage(source: ImageSource.gallery).then((File image){
                Navigator.of(context).push(FadeRoute(AddEventScreen(user: myUser,image: image, eventEditing: null,)));
              }).catchError((onError) => print(onError));
            },
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      builder: (context) => DbChurch(),
      child: _getBodyBlanckPage(context),
    );
  }
}

class ItemEventsSearch extends StatelessWidget {

  EventModel myEvent;
  BuildContext _context;
  User myUser;

  ItemEventsSearch({
    this.myEvent,
    this.myUser,
  });

  @override
  Widget build(BuildContext context) {
    this._context = context;

    return new GestureDetector(
      onTap: _handleTapUp,
      child: new Container(
        margin: const EdgeInsets.only(left: 10.0,right: 10.0,bottom: 10.0,top: 0.0),
        child:  new Material(
          borderRadius: new BorderRadius.circular(6.0),
          elevation: 2.0,
          child: _getListTitle(),
        ),
      ),
    );
  }

  _handleTapUp(){
    print(myUser.uid);
    print(myEvent.title);
    Navigator.of(_context).push(FadeRoute(AddEventScreen(user: myUser, eventEditing: myEvent,)));
  }

  Widget _getListTitle(){
    return new Container(
      height: 95.0,
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Hero(tag: myEvent.title, child: _getImgWidget(myEvent.urlImage)),
          _getColumText(myEvent.title, DateFormat.yMMMMd().format(myEvent.dateTime), myEvent.description)
        ],
      ),
    );
  }

  Widget _getColumText(title, date, description){
    return new Expanded(
      child: new Container(
        margin: new EdgeInsets.all(5.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _getTitleWidget(title),
            _getDateWidget(date),
            _getDescriptionWidget(description),
          ],
        ),
      ),
    );
  }

  Widget _getTitleWidget(String curencyName){
    return new Text(
      curencyName,
      maxLines: 1,
      style: new TextStyle(fontWeight: FontWeight.bold, fontFamily: "Lato"),
    );
  }

  Widget _getDescriptionWidget(String description){
    return new Container(
      margin: new EdgeInsets.only(top: 5.0),
      child: new Text(description,maxLines: 2,),
    );
  }

  Widget _getDateWidget(String date){
    return new Text(
      date,
      style: new TextStyle(color: Colors.grey, fontSize: 10.0),
    );
  }

  Widget _getImgWidget(String url){
    return new Container(
      width: 95.0,
      height: 95.0,
      child: new ClipRRect(
        borderRadius: new BorderRadius.only(
          topLeft: const Radius.circular(6.0),
          bottomLeft: const Radius.circular(6.0)
        ),
        child: _getImageNetwork(url),
      ),
    );
  }

  Widget _getImageNetwork(String url){

    try{
      if(url.isNotEmpty) {

        return new FadeInImage.assetNetwork(
          placeholder: 'assets/images/place_holder.jpg',
          image: url,
          fit: BoxFit.cover,);

      }else{
        return new Image.asset('assets/images/place_holder.jpg');
      }

    }catch(e){
      return new Image.asset('assets/images/place_holder.jpg');
    }

  }
}