import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'distraction_log.g.dart';

/// Represents a distraction recorded during a focus session.
@Collection()
class DistractionLog {
  @Id()
  int? id;

  /// Reference to the parent focus session
  @Index()
  late int sessionId;

  /// When the distraction occurred
  @Index()
  late DateTime timestamp;

  /// Category of distraction
  late String category;

  /// Optional description of the distraction
  String? description;

  /// How long the distraction lasted in seconds
  int durationSeconds;

  DistractionLog({
    this.id,
    required this.sessionId,
    required this.timestamp,
    required this.category,
    this.description,
    this.durationSeconds = 0,
  });
}

/// Predefined distraction categories
class DistractionCategory {
  static const String phone = 'phone';
  static const String social = 'social';
  static const String thoughts = 'thoughts';
  static const String environment = 'environment';
  static const String other = 'other';

  static const List<String> all = [
    phone,
    social,
    thoughts,
    environment,
    other,
  ];

  static String getDisplayName(String category) {
    switch (category) {
      case phone:
        return 'Phone';
      case social:
        return 'Social Media';
      case thoughts:
        return 'Thoughts';
      case environment:
        return 'Environment';
      case other:
        return 'Other';
      default:
        return category;
    }
  }

  static IconData getIcon(String category) {
    switch (category) {
      case phone:
        return Icons.phone_android;
      case social:
        return Icons.people;
      case thoughts:
        return Icons.psychology;
      case environment:
        return Icons.nature;
      case other:
        return Icons.more_horiz;
      default:
        return Icons.error_outline;
    }
  }
}