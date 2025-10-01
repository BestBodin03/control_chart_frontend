import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/ui/core/shared/searching_form.dart';
import 'package:control_chart/ui/core/layout/app_drawer/search_show_chart.dart';
import 'package:flutter/material.dart';

import '../home_screen_content/home_content_var.dart';

class SearchingContent extends StatefulWidget {
  const SearchingContent({
    super.key, 
    this.initialProfile});

  final HomeContentVar? initialProfile;

  @override
  SearchingContentState createState() => SearchingContentState();
}

class SearchingContentState extends State<SearchingContent> {
  @override
  Widget build(BuildContext context) {
    debugPrint('In Searching Content: ${widget.initialProfile}');
    final settingApi = SettingApis();
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 32.0, bottom: 32.0, top: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchingForm(initialProfile: widget.initialProfile, settingApis: settingApi),
            const SizedBox(width: 16.0),
            const SearchShowChart(),
          ],
        ),
      ),
    );
  }
}
