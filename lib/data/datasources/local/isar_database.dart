import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/entities/distraction_log.dart';
import '../../domain/entities/app_settings.dart';

/// Isar database configuration and initialization.
class IsarDatabase {
  static Isar? _instance;

  /// Get the Isar instance.
  static Isar get instance {
    if (_instance == null) {
      throw StateError('Isar database not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  /// Initialize the Isar database.
  static Future<Isar> initialize() async {
    if (_instance != null) return _instance!;

    final dir = await getApplicationDocumentsDirectory();

    _instance = await Isar.open(
      [
        FocusSessionSchema,
        DistractionLogSchema,
        AppSettingsSchema,
      ],
      directory: dir.path,
      inspector: true, // Enable inspector for debugging
    );

    // Ensure default settings exist
    await _ensureDefaultSettings(_instance!);

    return _instance!;
  }

  /// Close the database.
  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }

  /// Ensure default settings exist.
  static Future<void> _ensureDefaultSettings(Isar isar) async {
    final existing = await isar.appSettings.get(1);
    if (existing == null) {
      await isar.writeTxn(() async {
        await isar.appSettings.put(AppSettings.defaults());
      });
    }
  }
}