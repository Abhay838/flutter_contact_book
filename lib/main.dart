import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/contact_provider.dart';
import 'utils/app_routes.dart';
import 'utils/app_theme.dart';
import 'views/screens/add_edit_contact_screen.dart';
import 'views/screens/contact_detail_screen.dart';
import 'views/screens/home_screen.dart';
import 'models/contact_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ContactsApp());
}

class ContactsApp extends StatelessWidget {
  const ContactsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ContactProvider>(
          create: (_) => ContactProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Contacts',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,

        initialRoute: AppRoutes.home,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppRoutes.home:
              return _fadeRoute(const HomeScreen(), settings);

            case AppRoutes.addContact:
              return _slideRoute(const AddEditContactScreen(), settings);

            case AppRoutes.editContact:
              final contact = settings.arguments as Contact;
              return _slideRoute(
                AddEditContactScreen(contact: contact),
                settings,
              );

            case AppRoutes.contactDetail:
              final contact = settings.arguments as Contact;
              return _slideRoute(
                ContactDetailScreen(contact: contact),
                settings,
              );

            default:
              return _fadeRoute(const HomeScreen(), settings);
          }
        },
      ),
    );
  }

  static PageRoute _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }

  static PageRoute _slideRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}
