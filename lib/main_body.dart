// import 'package:control_chart/ui/core/layout/app_bar.dart';
// import 'package:control_chart/ui/core/layout/main_menu.dart';
// import 'package:flutter/material.dart';

// class MainBody extends StatelessWidget {
//   MainBody({Key? key, required this.page}) : super(key: key);
//   Widget page;

//   @override
//   Widget build(BuildContext context) {

//     return Scaffold(
//       appBar: AppBar(title: const Text('AppBar without hamburger button')),
//       drawer: Drawer(
//                 child: ListView(
//                   padding: EdgeInsets.zero,
//                   children: [
//                     const DrawerHeader(
//                       decoration: BoxDecoration(color: Colors.blue),
//                       child: Text('Drawer Header'),
//                     ),
//                     ListTile(
//                       title: const Text('Item 1'),
//                       onTap: () {
//                       },
//                     ),
//                     ListTile(
//                       title: const Text('Item 2'),
//                       onTap: () {
//                       },
//                     ),
//                   ],
//                 ),
//               )
//     );
//   }
// }