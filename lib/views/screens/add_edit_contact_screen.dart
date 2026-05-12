import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/contact_model.dart';
import '../../providers/contact_provider.dart';
import '../../utils/app_theme.dart';

class AddEditContactScreen extends StatefulWidget {
  final Contact? contact;

  const AddEditContactScreen({super.key, this.contact});

  @override
  State<AddEditContactScreen> createState() => _AddEditContactScreenState();
}

class _AddEditContactScreenState extends State<AddEditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _companyCtrl;
  late final TextEditingController _notesCtrl;

  String? _avatarPath;
  bool _isSaving = false;
  bool get _isEditing => widget.contact != null;

  @override
  void initState() {
    super.initState();
    final c = widget.contact;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _phoneCtrl = TextEditingController(text: c?.phone ?? '');
    _emailCtrl = TextEditingController(text: c?.email ?? '');
    _addressCtrl = TextEditingController(text: c?.address ?? '');
    _companyCtrl = TextEditingController(text: c?.company ?? '');
    _notesCtrl = TextEditingController(text: c?.notes ?? '');
    _avatarPath = c?.avatarPath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _companyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await _showImageSourceDialog();
    if (source == null) return;

    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() => _avatarPath = picked.path);
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Choose photo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: AppTheme.primary,
                ),
              ),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.photo_library_rounded,
                  color: AppTheme.primary,
                ),
              ),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            if (_avatarPath != null)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppTheme.danger,
                  ),
                ),
                title: const Text('Remove photo'),
                onTap: () {
                  setState(() => _avatarPath = null);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final provider = context.read<ContactProvider>();

    Contact? result;

    if (_isEditing) {
      result = await provider.updateContact(
        contact: widget.contact!,
        name: _nameCtrl.text,
        phone: _phoneCtrl.text,
        email: _emailCtrl.text,
        address: _addressCtrl.text.isEmpty ? null : _addressCtrl.text,
        company: _companyCtrl.text.isEmpty ? null : _companyCtrl.text,
        notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
        avatarPath: _avatarPath,
      );
    } else {
      result = await provider.addContact(
        name: _nameCtrl.text,
        phone: _phoneCtrl.text,
        email: _emailCtrl.text,
        address: _addressCtrl.text.isEmpty ? null : _addressCtrl.text,
        company: _companyCtrl.text.isEmpty ? null : _companyCtrl.text,
        notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
        avatarPath: _avatarPath,
      );
    }

    setState(() => _isSaving = false);

    if (!mounted) return;

    if (result != null) {
      _showSnack(_isEditing ? 'Contact updated' : 'Contact added');
      Navigator.pop(context, result);
    } else {
      _showSnack(
        provider.errorMessage ?? 'Failed to save contact',
        isError: true,
      );
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppTheme.danger : AppTheme.accent,
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
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Contact' : 'New Contact'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primary,
                    ),
                  )
                : TextButton(
                    onPressed: _save,
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Avatar picker
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: _avatarPath != null
                        ? CircleAvatar(
                            radius: 52,
                            backgroundImage: FileImage(File(_avatarPath!)),
                          )
                        : CircleAvatar(
                            radius: 52,
                            backgroundColor: AppTheme.primaryLight,
                            child: Text(
                              _nameCtrl.text.isNotEmpty
                                  ? _nameCtrl.text[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Required fields ──────────────────────────────────────────────
            _sectionLabel('Basic Info'),
            const SizedBox(height: 12),
            _buildField(
              controller: _nameCtrl,
              label: 'Full Name',
              icon: Icons.person_outline_rounded,
              required: true,
              validator: context.read<ContactProvider>().validateName,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}), // refresh avatar initial
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _phoneCtrl,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              required: true,
              validator: context.read<ContactProvider>().validatePhone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _emailCtrl,
              label: 'Email Address',
              icon: Icons.email_outlined,
              validator: context.read<ContactProvider>().validateEmail,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 24),
            _sectionLabel('More Details'),
            const SizedBox(height: 12),

            _buildField(
              controller: _companyCtrl,
              label: 'Company',
              icon: Icons.business_outlined,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _addressCtrl,
              label: 'Address',
              icon: Icons.location_on_outlined,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _notesCtrl,
              label: 'Notes',
              icon: Icons.notes_rounded,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppTheme.primary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }
}
