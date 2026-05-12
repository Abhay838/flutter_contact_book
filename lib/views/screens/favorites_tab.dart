import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/contact_provider.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_theme.dart';
import '../widgets/contact_list_tile.dart';
import '../widgets/empty_state.dart';

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.contacts.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        final favorites = provider.favorites;

        if (favorites.isEmpty) {
          return const EmptyState(
            icon: Icons.star_outline_rounded,
            title: 'No favorites yet',
            subtitle: 'Star a contact to add them here\nfor quick access',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          itemCount: favorites.length + 1,
          itemBuilder: (context, idx) {
            if (idx == 0) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
                child: Text(
                  '${favorites.length} favourite${favorites.length != 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }

            final contact = favorites[idx - 1];
            return ContactListTile(
              contact: contact,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.contactDetail,
                arguments: contact,
              ),
              onFavoriteTap: () async {
                await provider.toggleFavorite(contact);
              },
            );
          },
        );
      },
    );
  }
}
