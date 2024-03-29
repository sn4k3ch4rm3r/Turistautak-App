import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turistautak/models/route.dart';
import 'package:turistautak/pages/download/download.dart';
import 'package:turistautak/pages/download/progress.dart';
import 'package:turistautak/pages/map/map_page.dart';
import 'package:turistautak/pages/route_selector/route_selector.dart';
import 'package:turistautak/shared/map_layers.dart';
import 'package:turistautak/shared/sate/download.dart';
import 'package:turistautak/shared/sate/map_data.dart';
import 'package:turistautak/utils/database_handler.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late PageController _pageController;
  late MapDataProvider provider = Provider.of<MapDataProvider>(context, listen: false);
  int _selectedPage = 0;

  @override
  void initState() {
    _pageController = PageController(initialPage: _selectedPage);
    WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
      provider.startDownload = () {
        _goToPage(2);
      };
    });
    super.initState();
    _getOpenRoute().then((value) => provider.route = value);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const MapPage _mapPage = MapPage();
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (int index) => setState(() => _selectedPage = index),
        children: [
          _mapPage,
          SelectRoutePage(
            onSelected: () => _goToPage(0),
          ),
          Consumer<DownloadProvider>(
            builder: (context, provider, _) => provider.downloadProgress.length == 0
              ? const DownloadPage()
              : const DownloadProgressPage()
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedPage,
        height: 65,
        onDestinationSelected: (int index) => _goToPage(index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Térkép',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route),
            label: 'Útvonalak',
          ),
          NavigationDestination(
            icon: Icon(Icons.download_outlined),
            selectedIcon: Icon(Icons.download),
            label: 'Letöltés',
          )
        ],
      ),
    );
  }

  void _goToPage(int index) {
    setState(() => _selectedPage = index);
    _pageController.animateToPage(
      _selectedPage,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  Future<RouteModel?> _getOpenRoute() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? routeName = prefs.getString('CurrentRoute');
    if (routeName == null) return null;
    return DatabaseProvider.db.getRoute(routeName);
  }
}