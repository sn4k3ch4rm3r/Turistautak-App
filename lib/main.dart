import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turistautak/shared/sate/layer_provider.dart';
import 'package:turistautak/shared/themes.dart';
import 'package:turistautak/pages/main.dart';
import 'package:turistautak/utils/database_handler.dart';
import 'package:turistautak/shared/map_layers.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent));

  FlutterMapTileCaching.initialise(await RootDirectory.normalCache);

  for (MapLayer layer in MapLayers.all) {
    final StoreDirectory store = FlutterMapTileCaching.instance(layer.name);
    if (!(await store.manage.readyAsync)) {
      await store.manage.createAsync();
      await store.metadata.addAsync(key: 'sourceUrl', value: layer.name);
      await store.metadata.addAsync(key: 'validDuration', value: '14');
      await store.metadata.addAsync(key: 'behaviour', value: 'cacheFirst');
      await store.metadata.addAsync(key: 'type', value: layer.overlay ? 'overlay' : 'base');
    }
  }

  LocationPermission currentPermission = await Geolocator.checkPermission();
  if (currentPermission == LocationPermission.denied) {
    currentPermission = await Geolocator.requestPermission();
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => LayerProvider()),
    ],
    child: const Application(),
  ));
}

class Application extends StatelessWidget {
  const Application({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp(
          title: 'Turistautak',
          theme: Themes.lightTheme(lightDynamic),
          darkTheme: Themes.darkTheme(darkDynamic),
          home: const MainPage(),
        );
      },
    );
  }

  Future<dynamic> getOpenRoute() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? routeName = prefs.getString('CurrentRoute');
    if (routeName == null) return 'none';
    return DatabaseProvider.db.getRoute(routeName);
  }
}
