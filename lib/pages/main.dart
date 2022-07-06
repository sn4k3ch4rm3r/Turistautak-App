import 'package:flutter/material.dart';
import 'package:turistautak/pages/map/map_page.dart';
import 'package:turistautak/pages/select_route.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late PageController _pageController;
  int _selectedPage = 0;
  static final List<Widget> _pages = [
    const MapPage(),
    const SelectRoutePage(),
  ];

  @override
  void initState() {
    _pageController = PageController(initialPage: _selectedPage);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: _selectedPage == 0 ? const NeverScrollableScrollPhysics() : const PageScrollPhysics(),
        onPageChanged: (int index) => setState(() => _selectedPage = index),
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedPage,
        height: 65,
        onDestinationSelected: (int index) {
          setState(() => _selectedPage = index);
          _pageController.animateToPage(
            _selectedPage,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
          );  
        },
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
        ],
      ),
    );
  }
}