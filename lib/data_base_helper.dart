import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'pos_system.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Future<void> _onCreate(Database db, int version) async {
  //   await db.execute('''
  //     CREATE TABLE meals (
  //       id INTEGER PRIMARY KEY AUTOINCREMENT,
  //       name TEXT,
  //       price REAL,
  //       image TEXT
  //     )
  //   ''');
  //   await db.execute('''
  //     CREATE TABLE customers (
  //       id INTEGER PRIMARY KEY AUTOINCREMENT,
  //       name TEXT,
  //       date TEXT
  //     )
  //   ''');
  //   await db.execute('''
  //     CREATE TABLE invoices (
  //       id INTEGER PRIMARY KEY AUTOINCREMENT,
  //       customerId INTEGER,
  //       mealId INTEGER,
  //       quantity INTEGER,
  //       discount REAL,
  //       FOREIGN KEY (customerId) REFERENCES customers(id),
  //       FOREIGN KEY (mealId) REFERENCES meals(id)
  //     )
  //   ''');
  // }

  // Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  //   if (oldVersion < 2) {
  //     await db.execute('ALTER TABLE meals ADD COLUMN image TEXT');
  //   }
  // }
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE meals (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      price REAL,
      image TEXT
    )
  ''');
    await db.execute('''
    CREATE TABLE customers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      day_id INTEGER,
      name TEXT,
      date TEXT
    )
  ''');
    await db.execute('''
    CREATE TABLE invoices (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      customerId INTEGER,
      mealId INTEGER,
      quantity INTEGER,
      discount REAL,
      FOREIGN KEY (customerId) REFERENCES customers(id),
      FOREIGN KEY (mealId) REFERENCES meals(id)
    )
  ''');
    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT,
      password TEXT,
      role TEXT
    )
  ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE meals ADD COLUMN image TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        password TEXT,
        role TEXT
      )
    ''');
    }
  }

  Future<int> registerUser(
      String username, String password, String role) async {
    final db = await database;

    // Check if the username already exists
    final List<Map<String, dynamic>> existingUser = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (existingUser.isNotEmpty) {
      throw Exception('Username already exists');
    }

    // Ensure only one admin
    if (role == 'admin') {
      final List<Map<String, dynamic>> adminCheck = await db.query(
        'users',
        where: 'role = ?',
        whereArgs: ['admin'],
      );
      if (adminCheck.isNotEmpty) {
        throw Exception('Admin already exists');
      }
    }

    return await db.insert('users', {
      'username': username,
      'password': password,
      'role': role,
    });
  }

  Future<int> updateMeal(Map<String, dynamic> meal) async {
    Database db = await database;
    return await db.update(
      'meals',
      meal,
      where: 'id = ?',
      whereArgs: [meal['id']],
    );
  }

  Future<int> deleteMeal(int id) async {
    Database db = await database;
    return await db.delete(
      'meals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>?> loginUser(
      String username, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

//   Future<void> _onCreate(Database db, int version) async {
//   await db.execute('''
//     CREATE TABLE meals (
//       id INTEGER PRIMARY KEY AUTOINCREMENT,
//       name TEXT,
//       price REAL,
//       image TEXT
//     )
//   ''');
//   await db.execute('''
//     CREATE TABLE customers (
//       id INTEGER PRIMARY KEY AUTOINCREMENT,
//       day_id INTEGER,
//       name TEXT,
//       date TEXT
//     )
//   ''');
//   await db.execute('''
//     CREATE TABLE invoices (
//       id INTEGER PRIMARY KEY AUTOINCREMENT,
//       customerId INTEGER,
//       mealId INTEGER,
//       quantity INTEGER,
//       discount REAL,
//       FOREIGN KEY (customerId) REFERENCES customers(id),
//       FOREIGN KEY (mealId) REFERENCES meals(id)
//     )
//   ''');
// }

// Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
//   if (oldVersion < 2) {
//     await db.execute('ALTER TABLE meals ADD COLUMN image TEXT');
//   }
//   if (oldVersion < 3) {
//     await db.execute('ALTER TABLE customers ADD COLUMN day_id INTEGER');
//   }
// }

  Future<Map<String, dynamic>> getMealById(int mealId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'meals',
      where: 'id = ?',
      whereArgs: [mealId],
    );
    if (result.isNotEmpty) {
      return result.first;
    } else {
      throw Exception('Meal not found');
    }
  }

  Future<int> insertMeal(Map<String, dynamic> meal) async {
    Database db = await database;
    return await db.insert('meals', meal);
  }

  Future<List<Map<String, dynamic>>> getMeals() async {
    Database db = await database;
    return await db.query('meals');
  }

  // Future<int> insertCustomer(Map<String, dynamic> customer) async {
  //   Database db = await database;

  //   // Get today's date as a string
  //   String todayDate = DateTime.now().toIso8601String().split('T').first;

  //   // Check if there is already a customer entry for today
  //   final List<Map<String, dynamic>> existingCustomer = await db.query(
  //     'customers',
  //     where: 'date = ?',
  //     whereArgs: [todayDate],
  //   );

  //   // Insert the new customer regardless of existing entries for the date
  //   customer['date'] = todayDate;
  //   return await db.insert('customers', customer);
  // }

  Future<int> insertCustomer(Map<String, dynamic> customer) async {
    final db = await database;

    // Get today's date as a string
    String todayDate = DateTime.now().toIso8601String().split('T').first;

    // Get the current max day_id for today
    final List<Map<String, dynamic>> maxDayIdResult = await db.rawQuery('''
      SELECT MAX(day_id) as max_day_id 
      FROM customers 
      WHERE date = ?
    ''', [todayDate]);

    int nextDayId = (maxDayIdResult.first['max_day_id'] as int? ?? 0) + 1;

    // Insert the new customer with the next day_id
    customer['day_id'] = nextDayId;
    customer['date'] = todayDate;
    return await db.insert('customers', customer);
  }

  // Method to refresh available customer dates
  Future<List<DateTime>> getAvailableDates() async {
    final db = await database;
    final result = await db
        .rawQuery('SELECT DISTINCT date FROM customers ORDER BY date DESC');
    return result.map((row) => DateTime.parse(row['date'] as String)).toList();
  }

  Future<List<Map<String, dynamic>>> getCustomers() async {
    Database db = await database;
    return await db.query('customers');
  }

  Future<int> insertInvoice(Map<String, dynamic> invoice) async {
    Database db = await database;
    return await db.insert('invoices', invoice);
  }

  Future<List<Map<String, dynamic>>> getInvoices() async {
    Database db = await database;
    return await db.query('invoices');
  }

  // Future<List<DateTime>> getAvailableDates() async {
  //   final db = await database;
  //   final result = await db
  //       .rawQuery('SELECT DISTINCT date FROM customers ORDER BY date DESC');
  //   return result.map((row) => DateTime.parse(row['date'] as String)).toList();
  // }

  Future<Map<String, dynamic>> getDailyReport(DateTime date) async {
    final db = await database;
    String selectedDate = date.toIso8601String().split('T').first;

    // Get the number of customers for the selected date
    final customersResult = await db.rawQuery('''
      SELECT COUNT(*) AS customerCount 
      FROM customers 
      WHERE date LIKE '$selectedDate%'
    ''');

    // Get the total amount for the selected date
    final totalAmountResult = await db.rawQuery('''
      SELECT SUM(price * quantity - discount) AS totalAmount
      FROM invoices
      JOIN customers ON invoices.customerId = customers.id
      JOIN meals ON invoices.mealId = meals.id
      WHERE customers.date LIKE '$selectedDate%'
    ''');

    // Get the total number of meals for the selected date
    final totalMealsResult = await db.rawQuery('''
      SELECT SUM(quantity) AS totalMeals
      FROM invoices
      JOIN customers ON invoices.customerId = customers.id
      WHERE customers.date LIKE '$selectedDate%'
    ''');

    // Get detailed meal sales data for the selected date
    final detailedMealsResult = await db.rawQuery('''
      SELECT meals.name, SUM(invoices.quantity) AS quantitySold
      FROM invoices
      JOIN meals ON invoices.mealId = meals.id
      JOIN customers ON invoices.customerId = customers.id
      WHERE customers.date LIKE '$selectedDate%'
      GROUP BY meals.name
    ''');

    return {
      'customerCount': customersResult.first['customerCount'],
      'totalAmount': totalAmountResult.first['totalAmount'],
      'totalMeals': totalMealsResult.first['totalMeals'],
      'detailedMeals': detailedMealsResult,
    };
  }

  Future<List<Map<String, dynamic>>> getCustomersByDate(DateTime date) async {
    final db = await database;
    String selectedDate = date.toIso8601String().split('T').first;
    return await db.query(
      'customers',
      where: 'date LIKE ?',
      whereArgs: ['%$selectedDate%'],
      orderBy: 'day_id ASC',
    );
  }

  // Future<List<Map<String, dynamic>>> getCustomersByDate(DateTime date) async {
  //   final db = await database;
  //   String selectedDate = date.toIso8601String().split('T').first;
  //   return await db.query(
  //     'customers',
  //     where: 'date LIKE ?',
  //     whereArgs: ['%$selectedDate%'],
  //   );
  // }

  // Add this method to get the last update date
  Future<String?> getLastUpdateDate() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'customers',
      orderBy: 'date DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first['date'] as String?;
    } else {
      return null;
    }
  }
}
