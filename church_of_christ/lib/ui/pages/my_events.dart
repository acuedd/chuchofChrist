

import 'dart:io';
import 'package:church_of_christ/data/models/database.dart';
import 'package:church_of_christ/data/models/event.dart';
import 'package:church_of_christ/data/models/user.dart';
import 'package:church_of_christ/ui/pages/add_event.dart';
import 'package:church_of_christ/ui/widgets/animated_content.dart';
import 'package:church_of_christ/ui/widgets/custom_page.dart';
import 'package:church_of_christ/ui/widgets/popup_settings.dart';
import 'package:church_of_christ/util/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MyEventScreen extends StatefulWidget{

  final User myUser;

  MyEventScreen({
    this.myUser
  });

  @override
  State createState() {
    return _MyEventScreen();
  }
}

class _MyEventScreen extends State<MyEventScreen>{
  var db = DbChurch();

  @override
  void initState() {
    super.initState();
  }

  Widget _getBodyBlanckPage(BuildContext context){

    return Scaffold(
          body: BlanckPage(
            title: "Mis eventos",
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                onPressed: (){
                  showSearch(context: context, delegate: CustomSearchDelegate(widget.myUser));
                },
              ),
              PopupSettins()
            ],
            body: StreamBuilder(
              stream: (widget.myUser != null && widget.myUser.isAdmin)?db.streamEvents():db.streamEventsPerUser(widget.myUser.uid),
              builder: (context, AsyncSnapshot snapshot){
                if(snapshot.hasData){
                  return ListView(
                    padding: EdgeInsets.only(top: 20.0),
                    children: db.buildEvents(snapshot.data.documents, widget.myUser),
                  );
                }
                return CircularProgressIndicator();
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: "btnAddEvents",
            child: Icon(Icons.add),
            tooltip: "Buscar",
            onPressed: (){
              ImagePicker.pickImage(source: ImageSource.gallery,maxHeight: 760, maxWidth: 1024).then((File image){
                Navigator.of(context).push(FadeRoute(AddEventScreen(user: widget.myUser,image: image, eventEditing: null,)));
              }).catchError((onError) => print(onError));
            },
          ),
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

  var db = DbChurch();

  @override
  Widget build(BuildContext context) {
    this._context = context;
    return new Slidable(
      actionPane: new SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: _getMainContainer(context),
      actions: <Widget>[

      ],
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: "Editar",
          //color: Colors.black45,
          icon: Icons.edit,
          onTap: () => _handleTapUp(),
        ),
        IconSlideAction(
          caption: "Eliminar",
          color: Colors.red,
          icon: Icons.delete,
          onTap: (){
            _deleteEvent();
          },
        ),
      ]
    );
  }

  Widget _getGestureBuild(BuildContext context){
    return new GestureDetector(
      onTap: _handleTapUp,
      child: _getMainContainer(context),
    );
  }

  Widget _getMainContainer(BuildContext context){
    return new Container(
      margin: const EdgeInsets.only(left: 10.0,right: 10.0,bottom: 10.0,top: 0.0),
      child:  new Material(
        borderRadius: new BorderRadius.circular(6.0),
        elevation: 2.0,
        child: _getListTitle(),
      ),
    );
  }

  _handleTapUp(){
    //print(myUser.uid);
    //print(myEvent.title);
    Navigator.of(_context).push(FadeRoute(AddEventScreen(user: myUser, eventEditing: myEvent,)));
  }

  _deleteEvent(){
    db.deleteEvent(myEvent, myUser);
    Scaffold
        .of(_context)
        .showSnackBar(SnackBar(content: Text("Se ha elimado el evento"),));
    //Navigator.pop(_scaffoldContext);
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

class CustomSearchDelegate extends SearchDelegate{
  User user;
  var db = DbChurch();

  CustomSearchDelegate(this.user);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: (){
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: (){
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if(query.length < 3 ){
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              "Tu búsqueda debe ser mayor a dos letras."
            ),
          ),
        ],
      );
    }

    return Column(
      children: <Widget>[
        StreamBuilder(
          stream: (user.isAdmin)? db.streamEvents() : db.streamEventsPerUser(user.uid),
          builder: (context, AsyncSnapshot snapshot){
            if(!snapshot.hasData){
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(child: CircularProgressIndicator(),)
                ],
              );
            }
            else{
              var queryResultSet = [];
              var tmpSearchStore = [];
              var eventsListSnapshot = snapshot.data.documents;

              eventsListSnapshot.forEach((p){
                queryResultSet.add(EventModel.fromFirestore(p));
              });

              queryResultSet.forEach((q){
                String searchValue = query.toLowerCase();
                if(q.title.toString().toLowerCase().contains(searchValue) || q.description.toString().toLowerCase().contains(searchValue) ){
                  tmpSearchStore.add(q);
                }
              });
              
              print(tmpSearchStore.length);
              print(tmpSearchStore);

              return Expanded(
                child: AnimatedContent(
                  show: snapshot.data.documents.length > 0,
                  child: ListView(
                  padding: EdgeInsets.only(top: 20.0),
                    children: db.buildEventsFromMap(tmpSearchStore, user),
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    //this method
    return Column();
  }
}