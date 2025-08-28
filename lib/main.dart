import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SearchBloc>(
          create: (context) => SearchBloc(),
        ),
      ],

    child: MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.colorBgGrey,
        
        appBarTheme: const AppBarTheme(
        backgroundColor:  AppColors.colorBgGrey,
        toolbarHeight: 64.0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomeScreen(),
    ),
    );
  }
}
