import 'package:flutter/material.dart';

class HomeChatItem {
  final String name;
  final String message;
  final String timeText;
  final String dateText;
  final int? unreadCount;
  final bool isOnline;
  final String? statusChip;
  final Color? statusColor;
  final bool hasDoubleCheck;
  final String? imageUrl;

  const HomeChatItem({
    required this.name,
    required this.message,
    required this.timeText,
    required this.dateText,
    required this.isOnline,
    this.unreadCount,
    this.statusChip,
    this.statusColor,
    this.hasDoubleCheck = false,
    this.imageUrl,
  });
}
