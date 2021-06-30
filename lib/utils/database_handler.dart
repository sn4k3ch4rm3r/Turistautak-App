import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:turistautak/models/route.dart';

class DatabaseProvider {
  DatabaseProvider._();
  static final DatabaseProvider db = DatabaseProvider._();
  static Database _database;

  Future<Database> get database async {
    if(_database != null) {
      return _database;
    }
    _database = await initDB();
    return _database;
  }

  initDB() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'map.db'),
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE routes(
          name TEXT PRIMARY KEY,
          length DOUBLE,
          elevationGain INTEGER,
          elevationLoss INTEGER,
          GPXData TEXT)'''
        );
      },
      version: 1,
    );
  }

  insertRoute(RouteModel route) async {
    final db = await database;
    await db.insert('routes', route.toMap());
  }

  Future<List<RouteModel>> getRoutes() async {
    final db = await database;
    var res = await db.query('routes');
    if (res.length == 0) {
      return null;
    }
    List<RouteModel> routes = <RouteModel>[];
    for (Map map in res) {
      RouteModel route = RouteModel(map['name'], map['length'], map['elevationGain'], map['elevationLoss'], map['GPXData']);
      routes.add(route);
    }
    return routes;
  }
}