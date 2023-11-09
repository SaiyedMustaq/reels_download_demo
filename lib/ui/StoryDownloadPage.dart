import 'package:flutter/material.dart';

class StoryDownloadPage extends StatefulWidget {
  const StoryDownloadPage({super.key});

  @override
  State<StoryDownloadPage> createState() => _StoryDownloadPageState();
}

class _StoryDownloadPageState extends State<StoryDownloadPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [Text("Story")],
      ),
    );
  }
}
