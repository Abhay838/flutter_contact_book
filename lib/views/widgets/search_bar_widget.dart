import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  const SearchBarWidget({
    super.key,
    required this.onChanged,
    required this.onClose,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        style: const TextStyle(fontSize: 16, color: AppTheme.onSurface),
        decoration: InputDecoration(
          hintText: 'Search contacts...',
          filled: true,
          fillColor: AppTheme.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (_, value, __) {
              return value.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppTheme.textSecondary,
                      ),
                      onPressed: _clear,
                      splashRadius: 18,
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppTheme.textSecondary,
                      ),
                      onPressed: widget.onClose,
                      splashRadius: 18,
                    );
            },
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 16,
          ),
        ),
      ),
    );
  }
}
