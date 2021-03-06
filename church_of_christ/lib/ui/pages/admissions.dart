
import 'package:church_of_christ/data/models/database.dart';
import 'package:church_of_christ/data/models/event.dart';
import 'package:church_of_christ/data/models/user.dart';
import 'package:church_of_christ/ui/widgets/header_text.dart';
import 'package:church_of_christ/ui/widgets/my_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdmissionsWidget extends StatefulWidget{

  final EventModel eventModel;
  final User userLogged;

  AdmissionsWidget({
    Key kye,
    this.eventModel,
    this.userLogged,
  });

  @override
  State createState() {
    return _AdmissionsWidget();
  }
}

class _AdmissionsWidget extends State<AdmissionsWidget>{
  TextStyle style = TextStyle(fontFamily: 'Lato', fontSize: 15.0);
  final _formKey = GlobalKey<FormState>();
  BuildContext _scaffoldContext;

  final _textNameController = TextEditingController();
  final _textChuchController = TextEditingController();
  final _textPriceController = TextEditingController();
  final _textAgeController = TextEditingController();

  final db = DbChurch();

  String civilStatusValue = 'soltero';
  String civilStatusSymbol = '';

  String genderValue = 'male';
  String genderSymbol = '';

  @override
  void initState() {
    super.initState();
    //_textTitleController.text = widget.eventEditing.title;
    _textPriceController.text = widget.eventModel.price.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Admisiones"),
          centerTitle: false,
          actions: <Widget>[
            FlatButton(
              textColor: Colors.white,
              onPressed: () {
                save(context);
              },
              child: Text("Guardar"),
              shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
            ),
          ],
        ),
        body: new Builder(
          builder: (BuildContext context) {
            _scaffoldContext = context;
            return Form(
              key: _formKey,
              child: Center(
                    child: ListView(
                        children: <Widget>[
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextField(
                              controller: _textNameController,
                              style: style,
                              decoration: InputDecoration(
                                labelText: "Nombre",
                                //border: OutlineInputBorder()
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextField(
                              controller: _textChuchController,
                              style: style,
                              decoration: InputDecoration(
                                labelText: "Iglesia",
                                //border: OutlineInputBorder()
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextField(
                              controller: _textAgeController,
                              style: style,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "Edad",
                                //border: OutlineInputBorder()
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("Género"),
                                MyDropdown(currencyValue: genderValue, onChanged: _onGenderChanged, assetFile: 'assets/data/gender.json',),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("Estado civil"),
                                MyDropdown(currencyValue: civilStatusValue, onChanged: _onCivilStatusChanged, assetFile: 'assets/data/civilStatus.json',),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextField(
                              controller: _textPriceController,
                              style: style,
                              //readOnly: true,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: "Contribución - ${widget.eventModel.currency}",
                                //border: OutlineInputBorder()
                              ),
                            ),
                          ),
                        ])
                ),
            );
          })
    );
  }

  _onCivilStatusChanged(val, symbol) {
    setState(() {
      civilStatusValue = val;
      civilStatusSymbol = symbol;
    });
  }

  _onGenderChanged(val, symbol) {
    setState(() {
      genderValue = val;
      genderSymbol = symbol;
    });
  }

  void save(BuildContext context){
    final FormState form = _formKey.currentState;

    if(form.validate()){
      form.save();

      Scaffold
          .of(_scaffoldContext)
          .showSnackBar(SnackBar(content: Text("Procesando datos"),duration: Duration(minutes: 4),));

      RegisterEvent registerEvent = RegisterEvent(
          name: _textNameController.text,
          church: _textChuchController.text,
          currency: widget.eventModel.currency,
          price: double.parse(_textPriceController.text),
          eventid: widget.eventModel.id,
          userid: widget.userLogged.uid,
          nameUserReg: widget.userLogged.name,
          age: int.parse( _textAgeController.text ),
          civilStatus: civilStatusValue,
          gender: genderValue,
      );

      db.addAdmission(registerEvent).whenComplete((){
        print("GUARDO LA ADMISION");
        Scaffold.of(_scaffoldContext).removeCurrentSnackBar();
        Scaffold
            .of(_scaffoldContext)
            .showSnackBar(
            SnackBar(
              content: Text("Se ha guardado la información del evento. Ahora vuelve a ingresar para poner el horario"),
            )
        );
        Navigator.pop(_scaffoldContext);
      });

    }
  }
}