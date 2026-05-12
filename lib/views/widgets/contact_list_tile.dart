import 'package:flutter/material.dart';
import '../../models/contact_model.dart';
import '../../utils/app_theme.dart';
import 'contact_avatar.dart';

class ContactListTile extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onDeleteTap;

  const ContactListTile({
    super.key,
    required this.contact,
    required this.onTap,
    this.onFavoriteTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            ContactAvatar(contact: contact, radius: 24, fontSize: 16),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.onSurface,
                      letterSpacing: 0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (contact.phone.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      contact.phone,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (onFavoriteTap != null)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: IconButton(
                  key: ValueKey(contact.isFavorite),
                  icon: Icon(
                    contact.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: contact.isFavorite
                        ? AppTheme.warning
                        : AppTheme.textSecondary,
                    size: 22,
                  ),
                  onPressed: onFavoriteTap,
                  splashRadius: 20,
                  tooltip: contact.isFavorite
                      ? 'Remove from favorites'
                      : 'Add to favorites',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
