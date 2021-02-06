

class User {
  String id;
  String name;
  bool isModerator;

  /// some parameters about the game;
  double fontSize;
  bool isLightTheme;

  Map<String,List<int>> scoresByQuizMap;

  User(String id, String name, bool isModerator, double fontSize, bool isLightTheme,  Map<String,List<int>> scoresByQuizMap, ) {
    this.id = id;
    this.name = name;
    this.isModerator = isModerator;
    this.fontSize = fontSize;
    this.isLightTheme = isLightTheme;
    this.scoresByQuizMap = scoresByQuizMap;

  }


}