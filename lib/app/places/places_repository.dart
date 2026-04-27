import '../../framework/db/app_database.dart';
import 'model/place.dart';

class PlacesRepository {
  PlacesRepository(this._db);

  final AppDatabase _db;

  static const _table = 'places';

  Future<int> insert(Place place) async {
    final db = await _db.database;
    final map = place.toMap()..remove('id');
    return db.insert(_table, map);
  }

  Future<List<Place>> getAll() async {
    final db = await _db.database;
    final rows = await db.query(_table, orderBy: 'created_at DESC');
    return rows.map(Place.fromMap).toList();
  }

  Future<Place?> getById(int id) async {
    final db = await _db.database;
    final rows = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Place.fromMap(rows.first);
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
