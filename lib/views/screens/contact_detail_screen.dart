import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/contact_model.dart';
import '../../providers/contact_provider.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_theme.dart';

class ContactDetailScreen extends StatefulWidget {
  final Contact contact;

  const ContactDetailScreen({super.key, required this.contact});

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  late Contact _contact;

  @override
  void initState() {
    super.initState();
    _contact = widget.contact;
  }

  Future<void> _call() async {
    final uri = Uri(scheme: 'tel', path: _contact.phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _snack('Cannot make call from this device');
    }
  }

  Future<void> _sendSms() async {
    final uri = Uri(scheme: 'sms', path: _contact.phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _snack('Cannot send SMS from this device');
    }
  }

  Future<void> _toggleFavorite() async {
    final provider = context.read<ContactProvider>();
    final newState = await provider.toggleFavorite(_contact);
    setState(() => _contact = _contact.copyWith(isFavorite: newState));
  }

  Future<void> _editContact() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.editContact,
      arguments: _contact,
    );
    if (result is Contact) {
      setState(() => _contact = result);
    }
  }

  Future<void> _deleteContact() async {
    final confirmed = await _showDeleteDialog();
    if (!confirmed) return;

    final provider = context.read<ContactProvider>();
    final success = await provider.deleteContact(_contact.id);

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_contact.name} deleted'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<bool> _showDeleteDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Delete Contact',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            content: Text(
              'Are you sure you want to delete "${_contact.name}"?\nThis action cannot be undone.',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.danger,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildActionButtons(),
                  const SizedBox(height: 24),
                  _buildInfoCard(),
                  if (_contact.company != null &&
                      _contact.company!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildDetailCard('Company', [
                      _DetailRow(Icons.business_outlined, _contact.company!),
                    ]),
                  ],
                  if (_contact.address != null &&
                      _contact.address!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildDetailCard('Address', [
                      _DetailRow(Icons.location_on_outlined, _contact.address!),
                    ]),
                  ],
                  if (_contact.notes != null && _contact.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildDetailCard('Notes', [
                      _DetailRow(Icons.notes_rounded, _contact.notes!),
                    ]),
                  ],
                  const SizedBox(height: 16),
                  _buildDangerZone(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppTheme.surface,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Icon(
              _contact.isFavorite
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              key: ValueKey(_contact.isFavorite),
              color: _contact.isFavorite
                  ? AppTheme.warning
                  : AppTheme.textSecondary,
            ),
          ),
          onPressed: _toggleFavorite,
          tooltip: 'Toggle favorite',
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: _editContact,
          tooltip: 'Edit',
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.avatarColorFor(_contact.name).withOpacity(0.15),
                AppTheme.surface,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // Avatar
              Hero(
                tag: 'avatar_${_contact.id}',
                child:
                    _contact.avatarPath != null &&
                        File(_contact.avatarPath!).existsSync()
                    ? CircleAvatar(
                        radius: 60,
                        backgroundImage: FileImage(File(_contact.avatarPath!)),
                      )
                    : CircleAvatar(
                        radius: 60,
                        backgroundColor: AppTheme.avatarColorFor(_contact.name),
                        child: Text(
                          _contact.initials,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                _contact.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurface,
                ),
              ),
              if (_contact.company?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _contact.company!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _ActionButton(
          icon: Icons.call_rounded,
          label: 'Call',
          color: AppTheme.accent,
          onTap: _call,
        ),
        const SizedBox(width: 12),
        _ActionButton(
          icon: Icons.message_rounded,
          label: 'Message',
          color: AppTheme.primary,
          onTap: _sendSms,
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return _buildDetailCard('Contact Info', [
      _DetailRow(
        Icons.phone_outlined,
        _contact.phone,
        onTap: _call,
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: _contact.phone));
          _snack('Phone number copied');
        },
      ),
      if (_contact.email.isNotEmpty)
        _DetailRow(Icons.email_outlined, _contact.email),
    ]);
  }

  Widget _buildDetailCard(String title, List<_DetailRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
                letterSpacing: 1,
              ),
            ),
          ),
          ...rows.asMap().entries.map((e) {
            final isLast = e.key == rows.length - 1;
            return Column(
              children: [
                ListTile(
                  leading: Icon(
                    e.value.icon,
                    color: AppTheme.primary,
                    size: 22,
                  ),
                  title: Text(
                    e.value.text,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  onTap: e.value.onTap,
                  onLongPress: e.value.onLongPress,
                  dense: true,
                ),
                if (!isLast) const Divider(height: 1, indent: 56),
              ],
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.delete_outline_rounded,
          color: AppTheme.danger,
        ),
        title: const Text(
          'Delete Contact',
          style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w500),
        ),
        onTap: _deleteContact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _DetailRow {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _DetailRow(this.icon, this.text, {this.onTap, this.onLongPress});
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
