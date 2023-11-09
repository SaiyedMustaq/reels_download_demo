import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:get_storage/get_storage.dart';

import '../controller/DownloadController.dart';
import 'GenrateVideoFromPath.dart';
import 'InstaLogin.dart';

class ReelDownloadPage extends StatefulWidget {
  const ReelDownloadPage({super.key});

  @override
  _ReelDownloadPageState createState() => _ReelDownloadPageState();
}

class _ReelDownloadPageState extends State<ReelDownloadPage> {
  DownloadController downloadController = Get.put(DownloadController());
  TextEditingController urlController = TextEditingController();
  var box = GetStorage();
  bool loadingVideos = true;

  @override
  void initState() {
    downloadController.allVideos = box.read("allVideo") ?? [];
    loadingVideos = false;
    super.initState();
  }

  openInstaLoginBottom() {
    showBottomSheet(
        context: context,
        enableDrag: false,
        backgroundColor: Colors.grey.shade500,
        builder: (BuildContext context) {
          return SizedBox(
            height: 300,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => InstaLogin()));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20.0)),
                    child: const Text(
                      "Login to instagram",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: TextField(
                controller: urlController,
                autocorrect: true,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    filled: true,
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
                    hintText: "Paste instagram reel link here",
                    fillColor: Colors.white70,
                    prefixIcon: const Icon(Icons.link),
                    suffixIcon: IconButton(
                        onPressed: () => urlController.clear(),
                        icon: const Icon(Icons.close))),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(
                  () => SizedBox(
                    height: 100,
                    child: downloadController.processing.value
                        ? const Center(child: CupertinoActivityIndicator())
                        : Center(
                            child: InkWell(
                              onTap: () => downloadController.downloadReal(
                                  urlController.text, context),
                              child: Container(
                                height: 40,
                                width: 150,
                                decoration: const BoxDecoration(
                                    color: Colors.deepPurple,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: const Center(
                                    child: Text("Download",
                                        style: TextStyle(color: Colors.white))),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Center(
                  child: InkWell(
                    onTap: () => {
                      FlutterClipboard.paste().then((value) {
                        urlController.text = value;
                      })
                    },
                    child: Container(
                      height: 40,
                      width: 150,
                      decoration: const BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: const Center(
                          child: Text("Past",
                              style: TextStyle(color: Colors.white))),
                    ),
                  ),
                ),
              ],
            ),
            GetBuilder<DownloadController>(builder: (logic) {
              return logic.allVideos.isNotEmpty
                  ? Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 1 / 1.3,
                        children: List<Widget>.generate(
                            logic.allVideos.length,
                            (index) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GenrateVideoFrompath(
                                      logic.allVideos[index]),
                                )),
                      ),
                    )
                  : Container();
            })
          ],
        ),
      ),
    );
  }
}
