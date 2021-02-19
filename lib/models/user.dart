

class User {
  String id;
  String name;
  bool isModerator;

  /// some parameters about the game;
  double fontSize;
  bool isLightTheme;
  String currentGameId;


  User(String id, String name, bool isModerator, double fontSize, bool isLightTheme, String currentGameId ) {
    this.id = id;
    this.name = name;
    this.isModerator = isModerator;
    this.fontSize = fontSize;
    this.isLightTheme = isLightTheme;
    this.currentGameId = currentGameId;

  }


}