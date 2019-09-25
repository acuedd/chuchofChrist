/// Has all urls used in the app as static const strings.

class Url {

  // Map URL
  static const String lightMap =
      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png';
  static const String darkMap =
      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';


  //Share
  // Share details message
  static const String shareDetails = '#ChurchOfChristRm16:16 $appStore';


  // About page
  static const String changelog =
      'https://raw.githubusercontent.com/acuedd/chuchofChrist/master/CHANGELOG.md';
  static const String authorStore =
      'https://play.google.com/store/apps/developer?id=acuedd';
  static const String appStore =
      'https://play.google.com/store/apps/details?id=com.acuedd.conferenciasquiche';
  static const String authorPatreon = 'https://www.patreon.com/acuedd';
  static const Map<String, String> authorEmail = {
    'subject': 'acuedd',
    'address': 'acuedd@gmail.com',
  };

}