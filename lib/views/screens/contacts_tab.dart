import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/contact_model.dart';
import '../../providers/contact_provider.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_theme.dart';
import '../widgets/contact_list_tile.dart';
import '../widgets/empty_state.dart';

class ContactsTab extends StatelessWidget {
  const ContactsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.contacts.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        final contacts = provider.displayedContacts;

        if (contacts.isEmpty) {
          return EmptyState(
            icon: Icons.people_outline_rounded,
            title: provider.isSearching
                ? 'No results found'
                : 'No contacts yet',
            subtitle: provider.isSearching
                ? 'Try a different search term'
                : 'Tap the + button below\nto add your first contact',
            actionLabel: provider.isSearching ? null : 'Add Contact',
            onAction: provider.isSearching
                ? null
                : () => Navigator.pushNamed(context, AppRoutes.addContact),
          );
        }

        if (provider.isSearching) {
          return _buildFlatList(context, provider, contacts);
        }

        return _buildGroupedList(context, provider, provider.groupedContacts);
      },
    );
  }

  Widget _buildGroupedList(
    BuildContext context,
    ContactProvider provider,
    Map<String, List<Contact>> groups,
  ) {
    final keys = groups.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: keys.length,
      itemBuilder: (context, idx) {
        final key = keys[idx];
        final contacts = groups[key]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
              child: Text(
                key,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            ...contacts.map((c) => _buildTile(context, provider, c)),
          ],
        );
      },
    );
  }

  Widget _buildFlatList(
    BuildContext context,
    ContactProvider provider,
    List<Contact> contacts,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: contacts.length,
      itemBuilder: (_, i) => _buildTile(context, provider, contacts[i]),
    );
  }

  Widget _buildTile(
    BuildContext context,
    ContactProvider provider,
    Contact contact,
  ) {
    return ContactListTile(
      contact: contact,
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.contactDetail,
        arguments: contact,
      ),
      onFavoriteTap: () => provider.toggleFavorite(contact),
    );
  }
}
