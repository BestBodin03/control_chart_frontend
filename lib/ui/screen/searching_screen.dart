import 'package:control_chart/ui/screen/screen_content/searching_screen_content/searching_content.dart';
import 'package:flutter/material.dart';

class SearchingScreen extends StatelessWidget {
  const SearchingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SearchingScreenBody();
  }
}

class SearchingScreenBody extends StatelessWidget {
  const SearchingScreenBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SearchingContent();
  }
}
