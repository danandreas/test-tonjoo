import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:flutter_andreas/local_db/listUser.dart';
import 'package:flutter_andreas/pages/user_list_model.dart';
import 'package:path_provider/path_provider.dart';

class UserListController extends GetxController {
  RxBool isLoading = false.obs;
  UserListModel userListModel = UserListModel();
  TextEditingController searchController = TextEditingController();

  late Isar isar;

  List<ListUser> listUser = [];

  makeIsarDB(UserListModel response) async {
    final dir = await getApplicationSupportDirectory();
    if (dir.existsSync()) {
      final dataIsar = Isar.openSync([
        ListUserSchema,
      ], directory: dir.path, inspector: true, name: 'local_content');
      isar = dataIsar;
      importjson(isar, response);
    }
  }

  importjson(Isar isar, UserListModel response) async {
    importContent(response, isar);
  }

  importContent(UserListModel response, Isar isar) async {
      await isar.writeTxn(() async {
        await isar.listUsers.put(ListUser(
          id: response.id,
          username: response.username,
          lastName: response.lastName,
          email: response.email,
          gender: response.gender,
          avatar: response.avatar,
        ));
      });
    callLocalDbContent();
  }

  callLocalDbContent() async {
    final dataDB = await isar.listUsers.where().findAll();
    listUser = dataDB;
    update();
  }

  // getDataUsertList() async {
  //   isLoading.value = true;

  //   var data = UserListModel.fromJson(jsonDecode(response.body));
  //   if (data.isDefinedAndNotNull) {
  //     userListModel = data;
  //     makeIsarDB(data);
  //   } else {
  //     Get.snackbar("Error", data.toString(),
  //         backgroundColor: Colors.red,
  //         colorText: Colors.white,
  //         snackPosition: SnackPosition.TOP);
  //   }

  //   Future.delayed(const Duration(seconds: 1), () {
  //     isLoading.value = false;
  //   });
  // }

  // @override
  // void onInit() {
  //   super.onInit();
  //   getDataUsertList();
  // }
}
