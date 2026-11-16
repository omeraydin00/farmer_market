import 'package:material_ui/material_ui.dart';

class ThemeProvider with ChangeNotifier {
  bool isDark = false;

  ThemeMode get currentMode => isDark ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    isDark = !isDark;
    notifyListeners();
  }
}
