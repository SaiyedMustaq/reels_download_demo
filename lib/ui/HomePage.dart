import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/DownloadController.dart';
import 'ReelDownloadPage.dart';
import 'StoryDownloadPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DownloadController downloadController = Get.put(DownloadController());
  List<Widget> pages = [const ReelDownloadPage(), const StoryDownloadPage()];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(text: "Reels Download"),
              Tab(text: "Story Download"),
            ],
          ),
        ),
        body: TabBarView(children: pages),
      ),
    );
  }
}
