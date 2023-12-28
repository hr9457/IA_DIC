import 'package:flutter/material.dart';
import 'package:ia_proyecto/main.dart';
import 'package:ia_proyecto/screens/screens.dart';



class MenuOption {

  final String route;
  final String name;
  final Widget screen;

  MenuOption({
    required this.route,
    required this.name, 
    required this.screen
  });  

}


class AppRoutes {

  static const initialRoute = 'home';
  static final menuOptions = <MenuOption>[
    //MenuOption(route: 'home', name: 'HomeScreen', screen: const HomeScreen(), icono: Icons.home),
    MenuOption(route: 'home', name: 'Pagina principal', screen: const MyHomePage()),
    MenuOption(route: 'camera', name: 'Reconocimiento por camara', screen: const camaraScreen()),
    // MenuOption(route: 'upload', name: 'Reconocimiento por imagen', screen: const ImageUploadScreen()),
    // Camera
  ];

  static Map<String, Widget Function(BuildContext)> getAppRoutes() {

    Map<String, Widget Function(BuildContext)> appRoutes = {};
    appRoutes.addAll({ 'home' : (BuildContext context) => const MyHomePage()});

    for (final option in menuOptions) {
      appRoutes.addAll({option.route : (BuildContext context) => option.screen,});
    }
    
    return appRoutes;
  }

  static Route<dynamic> onGenerateRoute( RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => const MyHomePage()
    );
  }

}