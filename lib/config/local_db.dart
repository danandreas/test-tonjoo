import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../local_db/localUser.dart';

class LocalDb extends GetxController {
  GetStorage box = GetStorage();

  late Isar isarUsers;

  initialDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final isarUser = await Isar.open(
      [LocalUserSchema],
      name: "db_user",
      directory: dir.path,
    );
    isarUsers = isarUser;
  }

}
