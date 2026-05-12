import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/contact_provider.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_theme.dart';
import 'contacts_tab.dart';
import 'favorites_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late final AnimationController _fabAnim;

  final List<Widget> _tabs = const [ContactsTab(), FavoritesTab()];

  @override
  void initState() {
    super.initState();
    _fabAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactProvider>().loadContacts();
    });
  }

  @override
  void dispose() {
    _fabAnim.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    _fabAnim.reset();
    _fabAnim.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactProvider>(
      builder: (context, provider, _) {
        final isSearching = provider.isSearching;

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.surface,
            title: _buildTitle(),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppTheme.divider),
            ),
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _tabs[_selectedIndex],
          ),
          bottomNavigationBar: _buildBottomNav(),
          floatingActionButton: _selectedIndex == 0
              ? ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _fabAnim,
                    curve: Curves.elasticOut,
                  ),
                  child: FloatingActionButton.extended(
                    onPressed: () async {
                      await Navigator.pushNamed(context, AppRoutes.addContact);
                    },
                    icon: const Icon(Icons.person_add_rounded),
                    label: const Text('New Contact'),
                    heroTag: 'fab_add',
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.contacts_rounded,
            color: AppTheme.primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        const Text('Contacts'),
      ],
    );
  }

  Widget _buildBottomNav() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onTabChanged,
      animationDuration: const Duration(milliseconds: 400),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.people_outline_rounded),
          selectedIcon: Icon(Icons.people_rounded),
          label: 'Contacts',
        ),
        NavigationDestination(
          icon: Icon(Icons.star_outline_rounded),
          selectedIcon: Icon(Icons.star_rounded),
          label: 'Favorites',
        ),
      ],
    );
  }
}
