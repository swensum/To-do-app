import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
     fontFamily: 'Space Grotesk', 
    primaryColor: Colors.deepOrangeAccent,
    primaryColorLight: Color.fromARGB(66, 255, 109, 64),
    secondaryHeaderColor: Color.fromARGB(255, 6, 125, 8),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    textTheme: const TextTheme(
     bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black),
      bodySmall: TextStyle(fontSize: 14.0, color: Color.fromARGB(255, 77, 76, 76)),
      titleLarge: TextStyle( color: Colors.blueGrey,),
    ),
    iconTheme:  IconThemeData(color: Colors.grey.shade700,),
     primaryIconTheme: IconThemeData(color: Colors.grey.shade400),
     cardColor: const Color.fromARGB(156, 25, 49, 183),
  );
  static const Color namedGrey = Colors.grey;
  static const Color borderColor = Color.fromARGB(55, 200, 217, 220);
   static const Color dimmedCardColor = Color.fromARGB(100, 25, 49, 183); 
    static const Color dimmedCardColor2 =Color.fromARGB(59, 222, 222, 227);
   static const Color barColor= Color.fromARGB(97, 68, 137, 255);
   static const Color barColor2=Color.fromARGB(131, 158, 158, 158);
   static const Color fillColor= Color.fromARGB(69, 213, 220, 221);
   static const Color background=Color.fromARGB(6, 33, 149, 243);
    static const Color dimmedCardColor3 = Color.fromARGB(84, 170, 201, 218);
     static const Color futureColor=Colors.blue;
      static const Color boxColor=Color.fromARGB(13, 25, 49, 183);
      static const Color boxColor2= Color.fromARGB(13, 25, 49, 183);
       static  Color titleColor=Colors.blueGrey.withOpacity(0.7);
}
