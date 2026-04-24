import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// مساعد قاعدة البيانات SQLite - نظام خبرتي الكامل
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'khibarti.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE roles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (role_id) REFERENCES roles(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE experts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        specialty TEXT NOT NULL,
        years_experience INTEGER DEFAULT 0,
        rating REAL DEFAULT 0,
        sessions_count INTEGER DEFAULT 0,
        bio TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL UNIQUE,
        university TEXT,
        major TEXT,
        graduation_year TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE companies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL UNIQUE,
        company_name TEXT NOT NULL,
        industry TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        expert_id INTEGER NOT NULL,
        student_id INTEGER NOT NULL,
        scheduled_date TEXT NOT NULL,
        scheduled_time TEXT NOT NULL,
        status TEXT DEFAULT 'upcoming',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (expert_id) REFERENCES experts(id),
        FOREIGN KEY (student_id) REFERENCES students(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE session_attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        joined_at TEXT DEFAULT CURRENT_TIMESTAMP,
        left_at TEXT,
        was_recorded INTEGER DEFAULT 0,
        FOREIGN KEY (session_id) REFERENCES sessions(id),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE ratings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        rater_id INTEGER NOT NULL,
        rated_id INTEGER NOT NULL,
        score INTEGER NOT NULL,
        comment TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (session_id) REFERENCES sessions(id),
        FOREIGN KEY (rater_id) REFERENCES users(id),
        FOREIGN KEY (rated_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE certificates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        expert_name TEXT NOT NULL,
        specialty TEXT NOT NULL,
        session_date TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        file_path TEXT,
        FOREIGN KEY (session_id) REFERENCES sessions(id),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        title TEXT NOT NULL,
        body TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        read INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    await db.insert('roles', {'name': 'student'});
    await db.insert('roles', {'name': 'expert'});
    await db.insert('roles', {'name': 'company'});

    final roleStudent = 1;
    final roleExpert = 2;
    final roleCompany = 3;

    await db.insert('users', {
      'email': 'student@khibarti.com',
      'password': '123456',
      'role_id': roleStudent,
      'name': 'طالب تجريبي',
    });
    await db.insert('users', {
      'email': 'expert@khibarti.com',
      'password': '123456',
      'role_id': roleExpert,
      'name': 'أحمد محمد',
    });
    await db.insert('users', {
      'email': 'company@khibarti.com',
      'password': '123456',
      'role_id': roleCompany,
      'name': 'شركة داعمة',
    });

    await db.insert('students', {
      'user_id': 1,
      'university': 'جامعة الملك سعود',
      'major': 'علوم الحاسب',
      'graduation_year': '2026',
    });
    await db.insert('experts', {
      'user_id': 2,
      'specialty': 'تطوير البرمجيات',
      'years_experience': 12,
      'rating': 4.8,
      'sessions_count': 42,
      'bio': 'خبير في تطوير التطبيقات والذكاء الاصطناعي',
    });
    await db.insert('companies', {
      'user_id': 3,
      'company_name': 'شركة التقنية',
      'industry': 'التقنية',
    });

    for (var i = 4; i <= 8; i++) {
      await db.insert('users', {
        'email': 'expert$i@khibarti.com',
        'password': '123456',
        'role_id': roleExpert,
        'name': _expertNames[i - 4],
      });
      await db.insert('experts', {
        'user_id': i,
        'specialty': _expertSpecialties[i - 4],
        'years_experience': _expertYears[i - 4],
        'rating': _expertRatings[i - 4],
        'sessions_count': _expertSessions[i - 4],
        'bio': 'خبير في مجال التخصص',
      });
    }

    await db.insert('sessions', {
      'expert_id': 1,
      'student_id': 1,
      'scheduled_date': '2026-02-28',
      'scheduled_time': '10:00',
      'status': 'upcoming',
    });
    await db.insert('sessions', {
      'expert_id': 2,
      'student_id': 1,
      'scheduled_date': '2026-03-01',
      'scheduled_time': '14:00',
      'status': 'upcoming',
    });
    await db.insert('sessions', {
      'expert_id': 1,
      'student_id': 1,
      'scheduled_date': '2026-02-20',
      'scheduled_time': '11:00',
      'status': 'completed',
    });

    await db.insert('notifications', {
      'user_id': 1,
      'title': 'جلسة قادمة',
      'body': 'لديك جلسة مع أحمد محمد غداً',
    });
    await db.insert('notifications', {
      'user_id': 1,
      'title': 'تذكير',
      'body': 'أكمل ملفك الشخصي',
    });
  }

  static const _expertNames = ['سارة علي', 'خالد حسن', 'فاطمة عمر', 'عمر يوسف', 'نورة أحمد'];
  static const _expertSpecialties = ['التسويق الرقمي', 'إدارة الأعمال', 'التصميم الجرافيكي', 'الذكاء الاصطناعي', 'المحاسبة'];
  static const _expertYears = [8, 15, 6, 10, 20];
  static const _expertRatings = [4.9, 4.6, 4.7, 4.9, 4.8];
  static const _expertSessions = [67, 28, 35, 55, 90];

  // ============ Users & Auth ============
  Future<Map<String, dynamic>?> authenticateUser(String email, String password) async {
    final db = await database;
    final users = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (users.isEmpty) return null;
    final user = users.first;
    final roles = await db.query('roles', where: 'id = ?', whereArgs: [user['role_id']]);
    user['role_name'] = roles.isNotEmpty ? roles.first['name'] : 'student';
    return user;
  }

  Future<int> registerUser({
    required String email,
    required String password,
    required int roleId,
    required String name,
  }) async {
    final db = await database;
    return await db.insert('users', {
      'email': email,
      'password': password,
      'role_id': roleId,
      'name': name,
    });
  }

  Future<void> createStudentProfile(int userId) async {
    final db = await database;
    await db.insert('students', {'user_id': userId});
  }

  Future<void> createExpertProfile(int userId, String specialty, {int years = 0, String? bio}) async {
    final db = await database;
    await db.insert('experts', {
      'user_id': userId,
      'specialty': specialty,
      'years_experience': years,
      'bio': bio ?? '',
    });
  }

  Future<void> createCompanyProfile(int userId, String companyName, {String? industry}) async {
    final db = await database;
    await db.insert('companies', {
      'user_id': userId,
      'company_name': companyName,
      'industry': industry ?? '',
    });
  }

  Future<bool> emailExists(String email) async {
    final db = await database;
    final r = await db.query('users', where: 'email = ?', whereArgs: [email]);
    return r.isNotEmpty;
  }

  // ============ Experts ============
  Future<List<Map<String, dynamic>>> getExperts({
    String? search,
    String? specialty,
    int? minYears,
    double? minRating,
  }) async {
    final db = await database;
    var query = '''
      SELECT e.*, u.name 
      FROM experts e 
      JOIN users u ON e.user_id = u.id
    ''';
    final args = <dynamic>[];
    final conditions = <String>[];

    if (search != null && search.isNotEmpty) {
      conditions.add('(u.name LIKE ? OR e.specialty LIKE ?)');
      args.addAll(['%$search%', '%$search%']);
    }
    if (specialty != null && specialty.isNotEmpty && specialty != 'الكل') {
      conditions.add('e.specialty = ?');
      args.add(specialty);
    }
    if (minYears != null && minYears > 0) {
      conditions.add('e.years_experience >= ?');
      args.add(minYears);
    }
    if (minRating != null && minRating > 0) {
      conditions.add('e.rating >= ?');
      args.add(minRating);
    }
    if (conditions.isNotEmpty) {
      query += ' WHERE ${conditions.join(' AND ')}';
    }
    query += ' ORDER BY e.rating DESC';

    return await db.rawQuery(query, args);
  }

  Future<Map<String, dynamic>?> getExpertById(int id) async {
    final db = await database;
    final experts = await db.rawQuery(
      'SELECT e.*, u.name FROM experts e JOIN users u ON e.user_id = u.id WHERE e.id = ?',
      [id],
    );
    return experts.isNotEmpty ? experts.first : null;
  }

  Future<List<String>> getSpecialties() async {
    final db = await database;
    final r = await db.rawQuery('SELECT DISTINCT specialty FROM experts');
    return r.map((e) => e['specialty'] as String).toList();
  }

  // ============ Sessions ============
  Future<int> bookSession(int expertId, int studentId, String date, String time) async {
    final db = await database;
    return await db.insert('sessions', {
      'expert_id': expertId,
      'student_id': studentId,
      'scheduled_date': date,
      'scheduled_time': time,
      'status': 'upcoming',
    });
  }

  Future<List<Map<String, dynamic>>> getSessionsByStudent(int studentId, {String? status}) async {
    final db = await database;
    var q = '''
      SELECT s.*, u.name as expert_name, e.specialty 
      FROM sessions s 
      JOIN experts e ON s.expert_id = e.id
      JOIN users u ON e.user_id = u.id
      WHERE s.student_id = ?
    ''';
    final args = <dynamic>[studentId];
    if (status != null && status.isNotEmpty) {
      q += ' AND s.status = ?';
      args.add(status);
    }
    q += ' ORDER BY s.scheduled_date DESC, s.scheduled_time DESC';
    return await db.rawQuery(q, args);
  }

  Future<List<Map<String, dynamic>>> getSessionsForUser(int userId, {String? status}) async {
    final db = await database;
    final studentRows = await db.query('students', where: 'user_id = ?', whereArgs: [userId]);
    final expertRows = await db.query('experts', where: 'user_id = ?', whereArgs: [userId]);
    final studentIds = studentRows.map((r) => r['id'] as int).toList();
    final expertIds = expertRows.map((r) => r['id'] as int).toList();
    if (studentIds.isEmpty && expertIds.isEmpty) return [];
    final sPlaceholders = studentIds.map((_) => '?').join(',');
    final ePlaceholders = expertIds.map((_) => '?').join(',');
    var q = '''
      SELECT s.*, u.name as expert_name, e.specialty 
      FROM sessions s 
      JOIN experts e ON s.expert_id = e.id
      JOIN users u ON e.user_id = u.id
      WHERE (s.student_id IN ($sPlaceholders)) OR (s.expert_id IN ($ePlaceholders))
    ''';
    final args = <dynamic>[...studentIds, ...expertIds];
    if (status != null && status.isNotEmpty) {
      q += ' AND s.status = ?';
      args.add(status);
    }
    q += ' ORDER BY s.scheduled_date DESC, s.scheduled_time DESC';
    return await db.rawQuery(q, args);
  }

  Future<List<Map<String, dynamic>>> getUpcomingSessionsForUser(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT s.*, u.name as expert_name, e.specialty 
      FROM sessions s 
      JOIN experts e ON s.expert_id = e.id
      JOIN users u ON e.user_id = u.id
      WHERE (s.student_id IN (SELECT id FROM students WHERE user_id = ?) 
             OR s.expert_id IN (SELECT id FROM experts WHERE user_id = ?))
      AND s.status = 'upcoming'
      ORDER BY s.scheduled_date ASC, s.scheduled_time ASC
    ''', [userId, userId]);
  }

  Future<void> updateSessionStatus(int sessionId, String status) async {
    final db = await database;
    await db.update('sessions', {'status': status}, where: 'id = ?', whereArgs: [sessionId]);
  }

  Future<void> cancelSession(int sessionId) async {
    await updateSessionStatus(sessionId, 'cancelled');
  }

  Future<void> completeSession(int sessionId) async {
    await updateSessionStatus(sessionId, 'completed');
  }

  Future<Map<String, dynamic>?> getSessionById(int id) async {
    final db = await database;
    final r = await db.rawQuery('''
      SELECT s.*, u.name as expert_name, e.specialty, e.id as expert_id
      FROM sessions s JOIN experts e ON s.expert_id = e.id
      JOIN users u ON e.user_id = u.id
      WHERE s.id = ?
    ''', [id]);
    return r.isNotEmpty ? r.first : null;
  }

  // ============ Session Attendance ============
  Future<int> recordAttendance(int sessionId, int userId, {bool wasRecorded = false}) async {
    final db = await database;
    return await db.insert('session_attendance', {
      'session_id': sessionId,
      'user_id': userId,
      'was_recorded': wasRecorded ? 1 : 0,
    });
  }

  Future<void> updateAttendanceLeave(int attendanceId) async {
    final db = await database;
    await db.update(
      'session_attendance',
      {'left_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [attendanceId],
    );
  }

  // ============ Ratings ============
  Future<int> addRating(int sessionId, int raterId, int ratedId, int score, {String? comment}) async {
    final db = await database;
    return await db.insert('ratings', {
      'session_id': sessionId,
      'rater_id': raterId,
      'rated_id': ratedId,
      'score': score,
      'comment': comment,
    });
  }

  Future<bool> hasRatedSession(int sessionId, int raterId) async {
    final db = await database;
    final r = await db.query('ratings', where: 'session_id = ? AND rater_id = ?', whereArgs: [sessionId, raterId]);
    return r.isNotEmpty;
  }

  // ============ Certificates ============
  Future<int> createCertificate({
    required int sessionId,
    required int userId,
    required String expertName,
    required String specialty,
    required String sessionDate,
    String? filePath,
  }) async {
    final db = await database;
    return await db.insert('certificates', {
      'session_id': sessionId,
      'user_id': userId,
      'expert_name': expertName,
      'specialty': specialty,
      'session_date': sessionDate,
      'file_path': filePath,
    });
  }

  Future<List<Map<String, dynamic>>> getCertificatesByUser(int userId) async {
    final db = await database;
    return await db.query('certificates', where: 'user_id = ?', whereArgs: [userId], orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> getCertificateBySession(int sessionId) async {
    final db = await database;
    final r = await db.query('certificates', where: 'session_id = ?', whereArgs: [sessionId]);
    return r.isNotEmpty ? r.first : null;
  }

  // ============ Notifications ============
  Future<List<Map<String, dynamic>>> getNotificationsForUser(int? userId) async {
    final db = await database;
    if (userId == null) return [];
    return await db.query(
      'notifications',
      where: 'user_id IS NULL OR user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  Future<void> addNotification(String title, {String? body, int? userId}) async {
    final db = await database;
    await db.insert('notifications', {'user_id': userId, 'title': title, 'body': body});
  }

  // ============ User Profile ============
  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    final r = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return r.isNotEmpty ? r.first : null;
  }

  Future<int?> getStudentIdByUserId(int userId) async {
    final db = await database;
    final r = await db.query('students', where: 'user_id = ?', whereArgs: [userId]);
    return r.isNotEmpty ? r.first['id'] as int? : null;
  }

  Future<int?> getExpertIdByUserId(int userId) async {
    final db = await database;
    final r = await db.query('experts', where: 'user_id = ?', whereArgs: [userId]);
    return r.isNotEmpty ? r.first['id'] as int? : null;
  }

  Future<void> updateUser(int id, {String? name, String? password}) async {
    final db = await database;
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (password != null && password.isNotEmpty) data['password'] = password;
    if (data.isNotEmpty) await db.update('users', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
