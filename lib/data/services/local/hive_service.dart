import 'package:hive/hive.dart';

class HiveService {
  /// Open any box by name
  static Future<Box> openBox(String boxName) async {
    return await Hive.openBox(boxName);
  }

  /// Save data by key
  static Future<void> saveData(String boxName, String key, dynamic value) async {
    final box = await openBox(boxName);
    await box.put(key, value);
  }

  /// Get data by key
  static dynamic getData(String boxName, String key, {dynamic defaultValue}) {
    final box = Hive.box(boxName);
    return box.get(key, defaultValue: defaultValue);
  }

  /// Update data by merging maps (only works if stored value is a Map)
  static Future<void> updateMapData(
      String boxName, String key, Map<String, dynamic> newData) async {
    final box = Hive.box(boxName);
    final currentData = box.get(key) ?? {};
    if (currentData is Map) {
      final updatedData = {...currentData, ...newData};
      await box.put(key, updatedData);
    } else {
      throw Exception("Stored value is not a Map, cannot merge.");
    }
  }

  /// Delete data by key
  static Future<void> deleteData(String boxName, String key) async {
    final box = Hive.box(boxName);
    await box.delete(key);
  }

  /// Clear all data in a box
  static Future<void> clearBox(String boxName) async {
    final box = Hive.box(boxName);
    await box.clear();
  }

  /// Check if key exists
  static bool hasKey(String boxName, String key) {
    final box = Hive.box(boxName);
    return box.containsKey(key);
  }
}
