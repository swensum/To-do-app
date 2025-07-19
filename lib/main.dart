import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:todo_list/providers/NotificationProvider.dart';
import 'package:todo_list/providers/category_provider.dart';
import 'package:todo_list/utils/theme.dart';
import './providers/task_provider.dart';
import './routes/app_routes.dart';

void main() async {
   tz.initializeTimeZones();
   WidgetsFlutterBinding.ensureInitialized();
    await NotificationProvider().init(); 
 
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MultiProvider(
      providers: [
        
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
         ChangeNotifierProvider(create: (_) => NotificationProvider()..init()),
      ],
      child: MaterialApp(
        title: 'Advanced To-Do List',
        theme: AppTheme.lightTheme,
   
        themeMode: ThemeMode.system,
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutes.generateRoute,
        debugShowCheckedModeBanner: false,
        
      ),
    );
  }
}
