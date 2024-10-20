import 'package:flutter_starter_cli/string_utils.dart';
import 'package:flutter_starter_cli/utils.dart';

class Launcher {
  static String componentViewFirstLaunch({required String projectName}) {
    return '''
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:$projectName/di/providers.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  void initState() {
    super.initState();
    ref.read(homeViewModelProvider).fetchPost();
  }

  @override
  Widget build(BuildContext context) {
    final homeViewModel = ref.watch(homeViewModelProvider);
    final listOfPosts = homeViewModel.posts;
    final isLoading = homeViewModel.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home View'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: listOfPosts.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(listOfPosts[index]),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        onPressed: () {
          ref.read(homeViewModelProvider).fetchPost();
        },
      ),
    );
  }
}

    ''';
  }

  static String componentView({
    required String projectName,
    required String nameComponent,
    required String providerName,
  }) {
    return '''
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:$projectName/di/providers.dart';

class ${StringUtils.capitalizeFirst(nameComponent)}View extends ConsumerStatefulWidget {
  const ${StringUtils.capitalizeFirst(nameComponent)}View({super.key});

  @override
  ConsumerState<${StringUtils.capitalizeFirst(nameComponent)}View> createState() => _${StringUtils.capitalizeFirst(nameComponent)}ViewState();
}

class _${StringUtils.capitalizeFirst(nameComponent)}ViewState extends ConsumerState<${StringUtils.capitalizeFirst(nameComponent)}View> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final $providerName}ViewModel = ref.watch($providerName}ViewModelProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('${StringUtils.capitalizeFirst(nameComponent)} View'),
      ),
    );
  }
}
    ''';
  }

  static String componentViewModelFirstLaunch({required String projectName}) {
    return '''
import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  List<String> _posts = [];
  bool _isLoading = false;

  List<String> get posts => _posts;

  set posts(List<String> newValue) {
    _posts = newValue;
    notifyListeners();
  }

  bool get isLoading => _isLoading;

  set isLoading(bool newValue) {
    _isLoading = newValue;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> fetchPost() async {
    isLoading = true;
    try {
      await Future.delayed(const Duration(seconds: 3));
      posts = ['post 1', 'post 2', 'post 3'];
    } catch (e) {
      print(e);
    } finally {
      isLoading = false;
    }
    notifyListeners();
  }
}

    ''';
  }

  static String componentViewModel({
    required String projectName,
    required String nameComponent,
  }) {
    return '''
import 'package:flutter/material.dart';

class ${StringUtils.capitalizeFirst(nameComponent)}ViewModel extends ChangeNotifier {

}
    ''';
  }

  static String provider({required projectName}) {
    return '''
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:$projectName/view_models/home_view_model.dart';

final homeViewModelProvider = ChangeNotifierProvider<HomeViewModel>((ref) {
  return HomeViewModel();
});

    ''';
  }

  static String postModel({required modelName}) {
    return '''
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class ${StringUtils.capitalizeFirst(modelName)}Model {
  final int id;

  const ${StringUtils.capitalizeFirst(modelName)}Model({
    required this.id,
  });
}
    ''';
  }

  static String router({required projectName}) {
    return '''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:$projectName/views/app_shell.dart';
import 'package:$projectName/views/example_pages.dart';
import 'package:$projectName/views/home_view.dart';

enum AppPagesRoutes {
  home('/home'),
  profile('/profile'),
  settings('/settings');

  const AppPagesRoutes(this.path);

  final String path;
}

class AppRouter {
  static GoRouter get router => GoRouter(
    routes: _routes,
    initialLocation: AppPagesRoutes.home.path,
  );

  static final List<RouteBase> _routes = [
    StatefulShellRoute.indexedStack(
      builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
          ) {
        return AppShell(child: navigationShell);
      },
      branches: _branches,
    ),
  ];

  // Rami per la navigazione con GoRouter
  static final List<StatefulShellBranch> _branches = [
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppPagesRoutes.home.path,
          builder: (context, state) => const HomeView(),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppPagesRoutes.profile.path,
          builder: (context, state) => const ExampleProfileView(),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppPagesRoutes.settings.path,
          builder: (context, state) => const ExampleSettingsView(),
        ),
      ],
    ),
  ];
}

  ''';
  }

  static String appShell({required projectName}) {
    return '''
import 'package:flutter/material.dart';
import 'package:$projectName/widgets/navigation_bar.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const NavigationBarWidget(),
    );
  }
}

    ''';
  }

  static String examplePages({required projectName}) {
    return '''
import 'package:flutter/material.dart';

class ExampleProfileView extends StatelessWidget {
  const ExampleProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example Profile'),
      ),
      body: const Center(
        child: Text('This is an example page.'),
      ),
    );
  }
}

class ExampleSettingsView extends StatelessWidget {
  const ExampleSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example Settings'),
      ),
      body: const Center(
        child: Text('This is an example page.'),
      ),
    );
  }
}

    ''';
  }

  static String main({required projectName}) {
    return '''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:$projectName/l10n/l10n.dart';
import 'package:$projectName/router/routes.dart';

class App extends StatelessWidget {
  App({super.key});

  final GoRouter _router = AppRouter.router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: _router.routeInformationParser,
      routeInformationProvider: _router.routeInformationProvider,
      routerDelegate: _router.routerDelegate,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

    ''';
  }

  static String editMainFiles({required projectName}) {
    return '''
import 'package:$projectName/bootstrap.dart';
import 'package:$projectName/main.dart';

void main() {
  bootstrap(App.new);
}

    ''';
  }

  static String navigationBar({required projectName}) {
    return '''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:$projectName/router/routes.dart';

class NavigationBarWidget extends StatelessWidget {
  const NavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);

    return BottomNavigationBar(
      currentIndex: _calculateSelectedIndex(
        router: router,
        context: context,
      ),
      onTap: (index) {
        _onItemTapped(
          index: index,
          context: context,
        );
      },
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }

  int _calculateSelectedIndex({
    required GoRouter router,
    required BuildContext context,
  }) {
    final location = GoRouterState.of(context).matchedLocation;

    if (location.startsWith(AppPagesRoutes.home.path)) {
      return 0;
    }
    if (location.startsWith(AppPagesRoutes.profile.path)) {
      return 1;
    }
    if (location.startsWith(AppPagesRoutes.settings.path)) {
      return 2;
    }
    return 0;
  }

  void _onItemTapped({
    required int index,
    required BuildContext context,
  }) {
    switch (index) {
      case 0:
        context.go(AppPagesRoutes.home.path);
      case 1:
        context.go(AppPagesRoutes.profile.path);
      case 2:
        context.go(AppPagesRoutes.settings.path);
    }
  }
}


    ''';
  }

  static String bootstrap = '''
  runApp(ProviderScope(child: builder() as Widget));
''';
}
