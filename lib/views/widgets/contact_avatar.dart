import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/contact_model.dart';
import '../../utils/app_theme.dart';

class ContactAvatar extends StatelessWidget {
  final Contact contact;
  final double radius;
  final double fontSize;

  const ContactAvatar({
    super.key,
    required this.contact,
    this.radius = 24,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.avatarColorFor(contact.name);

    if (contact.avatarPath != null) {
      final file = File(contact.avatarPath!);
      if (file.existsSync()) {
        return CircleAvatar(radius: radius, backgroundImage: FileImage(file));
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Text(
        contact.initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
