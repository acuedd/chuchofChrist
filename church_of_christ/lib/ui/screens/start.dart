

import 'package:church_of_christ/data/models/church.dart';
import 'package:church_of_christ/data/models/event.dart';
import 'package:church_of_christ/data/models/settings.dart';
import 'package:church_of_christ/data/models/user_repository.dart';
import 'package:church_of_christ/ui/tabs/churchs.dart';
import 'package:church_of_christ/ui/tabs/events.dart';
import 'package:church_of_christ/ui/tabs/music.dart';
import 'package:church_of_christ/ui/tabs/settings.dart';
import 'package:church_of_christ/ui/screens/sign_in_screen.dart';
import 'package:church_of_christ/ui/widgets/dialog_presentation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // Reading app shortcuts input
    final QuickActions quickActions = QuickActions();
    quickActions.initialize((type){
      switch (type){
        case 'events':
          setState( ()=> _currentIndex = 0);
          break;
        case 'Music':
          setState( ()=> _currentIndex = 1);
          break;
        case 'settings':
          setState( ()=> _currentIndex = 2);
          break;
        default:
          setState( ()=> _currentIndex = 0);
      }
    });


    Future.delayed(Duration.zero, () async {

      // Show the Register page
      final SharedPreferences prefs = await SharedPreferences.getInstance();  

      // First time app boots
      if (prefs.getBool('register_seen') == null)
        prefs.setBool('register_seen', false);
      if (prefs.getString('register_date') == null)
        prefs.setString(
          'register_date',
          DateTime.now().toIso8601String(),
        );

      // If it's time to show the dialog
      if (!prefs.getBool('register_seen') &&
          DateTime.now().isAfter(
            DateTime.parse(prefs.getString('register_date')),
          )) {
          showDialog(
            context: context,
            builder: (context)=> PresentationDialog.home(context, (){
              //TODO
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider.value(
                      value: UserRepository.instance(),
                      child: SignInScreen(),
                    ),
                  )
              );
            }, "Sign in up"),
          ).then((result){
            // Then, we'll analize what happened
            if (!(result ?? false))
              prefs.setString(
                'register_date',
                DateTime.now().add(Duration(days: 14)).toIso8601String(),
              );
            else
              prefs.setBool('register_seen', true);
          });
      }

      //Settings app shortcuts
      quickActions.setShortcutItems(<ShortcutItem>[
        ShortcutItem(
          type: 'events',
          localizedTitle: "Eventos",
          icon: 'action_upcoming',
        ),
        ShortcutItem(
          type: 'churchs',
          localizedTitle: "Iglesias",
          icon: 'action_vehicle',
        )
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<SingleChildCloneableWidget> _models = [
      ChangeNotifierProvider(
        builder: (context) => EventModelProvider(),
        child: EventsScreen(),
      ),
      ChangeNotifierProvider(
        builder: (context)=> UserRepository.instance(),
        child: MusicScreen(),
      ),
      ChangeNotifierProvider(
        builder: (context) => SettingsModel(),
        child: SettingsScreen(),
      )
    ];

    return MultiProvider(
      providers: _models,
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _models),
        bottomNavigationBar: BottomNavigationBar(
          selectedLabelStyle: TextStyle(fontFamily: 'Lato'),
          unselectedLabelStyle: TextStyle(fontFamily: 'Lato'),
          type: BottomNavigationBarType.fixed,
          onTap: (index) => setState( ()=> _currentIndex = index),
          currentIndex: _currentIndex,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              title: Text("Eventos"),
              icon: Icon(Icons.event),
            ),
            BottomNavigationBarItem(
              title: Text("IDC Music"),
              icon: Icon(Icons.music_note),
            ),
            BottomNavigationBarItem(
              title: Text("General"),
              icon: Icon(Icons.settings),
            ),
          ],
        ),
      ),
    );
  }
}