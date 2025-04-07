import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme_manager.dart';
import 'core/llm/llm_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => LLMProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return Consumer<ThemeManager>(
            builder:
                (context, themeManager, _) => MaterialApp.router(
                  title: 'AI Phone Bench',
                  theme: themeManager.currentTheme,
                  routerConfig: AppRouter.router,
                  debugShowCheckedModeBanner: false,
                ),
          );
        },
      ),
    );
  }
}
