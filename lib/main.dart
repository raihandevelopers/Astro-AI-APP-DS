import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'locale_meta.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/onboarding.dart';
import 'screens/profile_setup.dart';
import 'state.dart';
import 'theme.dart';
import 'widgets/splash.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Use system photo picker so gallery pick needs no READ_MEDIA_* permissions.
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    final impl = ImagePickerPlatform.instance;
    if (impl is ImagePickerAndroid) {
      impl.useAndroidPhotoPicker = true;
    }
  }
  runApp(const MyFutureApp());
}

class MyFutureApp extends StatelessWidget {
  const MyFutureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..boot(),
      child: Consumer<AppState>(
        builder: (context, app, _) {
          return MaterialApp(
            title: 'MyFuture',
            debugShowCheckedModeBanner: false,
            theme: buildTheme(),
            locale: app.locale,
            supportedLocales: supportedAppLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const Gate(),
          );
        },
      ),
    );
  }
}

class Gate extends StatefulWidget {
  const Gate({super.key});

  @override
  State<Gate> createState() => _GateState();
}

class _GateState extends State<Gate> {
  bool _checkingOnboarding = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _loadOnboarding();
  }

  Future<void> _loadOnboarding() async {
    final show = await shouldShowOnboarding();
    if (!mounted) return;
    setState(() {
      _showOnboarding = show;
      _checkingOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (app.booting || _checkingOnboarding) {
      return const AppSplash();
    }
    if (app.user == null) {
      if (_showOnboarding) {
        return OnboardingScreen(
          onDone: () => setState(() => _showOnboarding = false),
        );
      }
      return const LoginScreen();
    }
    if (!app.user!.profileComplete) {
      return const PopScope(
        canPop: false,
        child: ProfileSetupScreen(),
      );
    }
    return const ShellScreen();
  }
}
