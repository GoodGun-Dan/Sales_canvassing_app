import 'package:flutter/material.dart';

import '../services/language_service.dart';

/// Pemilih bahasa yang dapat digunakan pada semua dashboard berdasarkan role.
class LanguageMenu extends StatelessWidget {
  const LanguageMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      tooltip: context.tr('language'),
      onSelected: LanguageService.setLanguage,
      itemBuilder: (_) => [
        PopupMenuItem(value: 'id', child: Text(context.tr('indonesian'))),
        PopupMenuItem(value: 'en', child: Text(context.tr('english'))),
      ],
    );
  }
}
