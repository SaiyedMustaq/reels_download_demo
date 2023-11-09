import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart' as wb;

import '../model/InstaPostWithLogin.dart';
import '../model/insta_post_without_login.dart';
import '../ui/InstaLogin.dart';

class DownloadController extends GetxController {
  var processing = false.obs;
  List allVideos = [].obs;
  bool isLogin = false;
  String? path;
  var box = GetStorage();
  Dio dio = Dio();

  Future<String?> _startDownload(String link, BuildContext context) async {
    print("LINK==>$link");
    // Asking for video storage permission
    await Permission.storage.request();
    isLogin = false;
    // Checking for Cookies
    final cookieManager = wb.WebviewCookieManager();
    final gotCookies =
        await cookieManager.getCookies('https://www.instagram.com/');
    print("Cookies -->$gotCookies");
    // is Cookie found then set isLogin to true
    if (gotCookies.isNotEmpty) isLogin = true;

    // Build the url
    var linkParts = link.replaceAll(" ", "").split("/");
    var url = '${linkParts[0]}//${linkParts[2]}/${linkParts[3]}/${linkParts[4]}'
        "?__a=1&__d=dis";

    // Make Http requiest to get the download link of video
    var httpClient = HttpClient();
    String? videoURL;
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      for (var element in gotCookies) {
        request.cookies.add(Cookie(element.name, element.value));
      }
      var response = await request.close();
      if (response.statusCode == HttpStatus.OK) {
        var json = await response.transform(utf8.decoder).join();
        var data = jsonDecode(json);
        print("DATA==>${data}");
        if (isLogin) {
          InstaPostWithLogin postWithLogin = InstaPostWithLogin.fromJson(data);
          videoURL = postWithLogin.items?.first.videoVersions?.first.url;
        } else {
          InstaPostWithoutLogin post = InstaPostWithoutLogin.fromJson(data);
          videoURL = post.graphql?.shortcodeMedia?.videoUrl;
        }
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => InstaLogin()));
      }
    } catch (exception) {
      print("Exception $exception");
      // Login to instagram in case of Cookie expire or download any private account's video
      Navigator.push(context, MaterialPageRoute(builder: (_) => InstaLogin()));
    }

    //Download video & save
    if (videoURL == null) {
      return null;
    } else {
      var appDocDir = await getTemporaryDirectory();
      String savePath = "${appDocDir.path}/${generateRandomString(10)}.mp4";
      await dio.download(videoURL, savePath);
      if (Platform.isAndroid) {
        return savePath;
      } else {
        final result =
            await ImageGallerySaver.saveFile(savePath, isReturnPathOfIOS: true);
        return result['filePath'].toString().replaceAll(RegExp('file://'), '');
      }
    }
  }

  String generateRandomString(int len) {
    var r = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }

  Future<String?> getPath() async {
    final tempPath = await getExternalStorageDirectory();
    List<String> pathList = tempPath.toString().split("/");
    var newPath = "";
    for (int i = 1; i < pathList.length; i++) {
      String folder = pathList[i];
      if (folder != "Android") {
        newPath += "/$folder";
      } else {
        break;
      }
    }
    return "$newPath/mustaq";
  }

  downloadReal(String link, BuildContext context) async {
    processing.value = true;
    try {
      path = null;
      update();
      await _startDownload(link, context).then((value) {
        if (value == null) throw Exception();
        path = value;
        update();
        List allVideosPath = box.read("allVideo") ?? [];
        allVideosPath.add(path);
        box.write("allVideo", allVideosPath);
      });
    } catch (e) {}
    processing.value = false;
  }
}
