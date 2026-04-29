import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:khibarti/config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._();
  static ApiService get instance => _instance;
  final String _base = ApiConfig.baseUrl;

  ApiService._();

  /// فحص اتصال التطبيق بالسيرفر
  Future<bool> checkConnection() async {
    try {
      final r = await http
          .get(Uri.parse('$_base/api/health'))
          .timeout(const Duration(seconds: 3));
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final r = await http
          .post(
            Uri.parse('$_base/api/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 5));
      if (r.statusCode == 200)
        return jsonDecode(r.body) as Map<String, dynamic>;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> register({
    required String email,
    required String password,
    required int roleId,
    required String name,
  }) async {
    try {
      final r = await http
          .post(
            Uri.parse('$_base/api/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
              'roleId': roleId,
              'name': name,
            }),
          )
          .timeout(const Duration(seconds: 5));
      if (r.statusCode == 200)
        return jsonDecode(r.body) as Map<String, dynamic>;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> emailExists(String email) async {
    try {
      final r = await http
          .get(
            Uri.parse(
              '$_base/api/auth/check-email?email=${Uri.encodeComponent(email)}',
            ),
          )
          .timeout(const Duration(seconds: 5));
      if (r.statusCode == 200)
        return (jsonDecode(r.body) as Map)['exists'] == true;
      return false;
    } catch (_) {
      return false;
    }
  }

  /// [audience] `student` (افتراضي) للطلاب، `company` لقائمة شركاء الشركة فقط
  Future<List<Map<String, dynamic>>> getExperts({
    String? search,
    String? specialty,
    int? minYears,
    double? minRating,
    String? audience,
  }) async {
    try {
      final q = <String>[];
      if (audience != null && audience.isNotEmpty) q.add('audience=$audience');
      if (search != null && search.isNotEmpty) q.add('search=$search');
      if (specialty != null && specialty != 'الكل')
        q.add('specialty=$specialty');
      if (minYears != null && minYears > 0) q.add('minYears=$minYears');
      if (minRating != null && minRating > 0) q.add('minRating=$minRating');
      final query = q.isEmpty ? '' : '?${q.join('&')}';
      final url = Uri.parse('$_base/api/experts$query');
      final r = await http.get(url).timeout(const Duration(seconds: 5));
      if (r.statusCode == 200)
        return List<Map<String, dynamic>>.from(jsonDecode(r.body));
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<List<String>> getSpecialties({String? audience}) async {
    try {
      final q = audience != null && audience.isNotEmpty ? '?audience=$audience' : '';
      final r = await http
          .get(Uri.parse('$_base/api/experts/specialties$q'))
          .timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) return List<String>.from(jsonDecode(r.body));
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getExpertByUserId(int userId) async {
    try {
      final r = await http
          .get(Uri.parse('$_base/api/experts/by-user/$userId'))
          .timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        if (data == null) return null;
        return Map<String, dynamic>.from(data as Map);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getExpertById(int id) async {
    try {
      final r = await http
          .get(Uri.parse('$_base/api/experts/$id'))
          .timeout(const Duration(seconds: 5));
      if (r.statusCode == 200)
        return jsonDecode(r.body) as Map<String, dynamic>;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<int?> bookSession(
    int expertId,
    int studentId,
    String date,
    String time,
  ) async {
    try {
      final resp = await http
          .post(
            Uri.parse('$_base/api/sessions/book'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'expertId': expertId,
              'studentId': studentId,
              'date': date,
              'time': time,
            }),
          )
          .timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200)
        return (jsonDecode(resp.body) as Map)['id'] as int?;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getCompanyDelegates(int ownerUserId) async {
    try {
      final r = await http
          .get(
            Uri.parse('$_base/api/company/delegates?ownerUserId=$ownerUserId'),
          )
          .timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(r.body));
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> createCompanyDelegate({
    required int ownerUserId,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final r = await http
          .post(
            Uri.parse('$_base/api/company/delegates'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'ownerUserId': ownerUserId,
              'email': email,
              'password': password,
              'name': name,
            }),
          )
          .timeout(const Duration(seconds: 8));
      if (r.statusCode == 200) {
        return jsonDecode(r.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> deleteCompanyDelegate({
    required int ownerUserId,
    required int delegateId,
  }) async {
    try {
      final r = await http
          .delete(
            Uri.parse(
              '$_base/api/company/delegates/$delegateId?ownerUserId=$ownerUserId',
            ),
          )
          .timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) return null;
      if (r.statusCode == 404) return 'not_found';
      try {
        final m = jsonDecode(r.body);
        if (m is Map && m['error'] != null) return m['error'].toString();
      } catch (_) {}
      return 'error';
    } catch (_) {
      return 'error';
    }
  }

  Future<Map<String, dynamic>?> getExpertPartnerDirectoryStatus(int expertUserId) async {
    try {
      final r = await http
          .get(
            Uri.parse(
              '$_base/api/experts/partner-directory-request/me?expertUserId=$expertUserId',
            ),
          )
          .timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(r.body) as Map);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> submitExpertPartnerDirectoryRequest(int expertUserId) async {
    try {
      final r = await http
          .post(
            Uri.parse('$_base/api/experts/partner-directory-request'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'expertUserId': expertUserId}),
          )
          .timeout(const Duration(seconds: 6));
      if (r.statusCode == 200) {
        return null;
      }
      try {
        final m = jsonDecode(r.body);
        if (m is Map && m['error'] != null) {
          return m['error'].toString();
        }
      } catch (_) {}
      return 'error';
    } catch (_) {
      return 'error';
    }
  }

  Future<List<Map<String, dynamic>>> getCompanyPartnerRequests(
    int officerUserId, {
    String status = 'pending',
  }) async {
    try {
      final r = await http
          .get(
            Uri.parse(
              '$_base/api/company/partner-requests?officerUserId=$officerUserId&status=$status',
            ),
          )
          .timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(r.body));
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<String?> decideCompanyPartnerRequest({
    required int officerUserId,
    required int requestId,
    required bool approve,
  }) async {
    try {
      final r = await http
          .patch(
            Uri.parse('$_base/api/company/partner-requests/$requestId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'officerUserId': officerUserId,
              'decision': approve ? 'approve' : 'reject',
            }),
          )
          .timeout(const Duration(seconds: 6));
      if (r.statusCode == 200) {
        return null;
      }
      try {
        final m = jsonDecode(r.body);
        if (m is Map && m['error'] != null) {
          return m['error'].toString();
        }
      } catch (_) {}
      return 'error';
    } catch (_) {
      return 'error';
    }
  }

  Future<List<Map<String, dynamic>>> getSessionsForUser(
    int userId, {
    String? status,
  }) async {
    try {
      final url = status != null && status.isNotEmpty
          ? '$_base/api/sessions/user/$userId?status=$status'
          : '$_base/api/sessions/user/$userId';
      final r = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));
      if (r.statusCode == 200)
        return List<Map<String, dynamic>>.from(jsonDecode(r.body));
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> updateSessionStatus(int sessionId, String status) async {
    try {
      await http
          .patch(
            Uri.parse('$_base/api/sessions/$sessionId/status'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'status': status}),
          )
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  Future<void> cancelSession(int sessionId) async =>
      updateSessionStatus(sessionId, 'cancelled');
  Future<void> completeSession(int sessionId) async =>
      updateSessionStatus(sessionId, 'completed');

  Future<void> addRating(
    int sessionId,
    int raterId,
    int ratedId,
    int score,
  ) async {
    try {
      await http
          .post(
            Uri.parse('$_base/api/sessions/$sessionId/rate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'raterId': raterId,
              'ratedId': ratedId,
              'score': score,
            }),
          )
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  Future<void> recordAttendance(int sessionId, int userId) async {
    try {
      await http
          .post(
            Uri.parse('$_base/api/sessions/$sessionId/attendance'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'userId': userId}),
          )
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  Future<void> createCertificate({
    required int sessionId,
    required int userId,
    required String expertName,
    required String specialty,
    required String sessionDate,
  }) async {
    try {
      await http
          .post(
            Uri.parse('$_base/api/certificates'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'sessionId': sessionId,
              'userId': userId,
              'expertName': expertName,
              'specialty': specialty,
              'sessionDate': sessionDate,
            }),
          )
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> getNotificationsForUser(int userId) async {
    try {
      final r = await http
          .get(Uri.parse('$_base/api/notifications/$userId'))
          .timeout(const Duration(seconds: 5));
      if (r.statusCode == 200)
        return List<Map<String, dynamic>>.from(jsonDecode(r.body));
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    try {
      final r = await http
          .get(Uri.parse('$_base/api/users/$id'))
          .timeout(const Duration(seconds: 5));
      if (r.statusCode == 200)
        return jsonDecode(r.body) as Map<String, dynamic>;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<int?> getStudentIdByUserId(int userId) async {
    try {
      final r = await http
          .get(Uri.parse('$_base/api/students/by-user/$userId'))
          .timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        return data != null ? (data as Map)['id'] as int? : null;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<int?> getExpertUserIdByExpertId(int expertId) async {
    try {
      final r = await http
          .get(Uri.parse('$_base/api/experts/$expertId/user'))
          .timeout(const Duration(seconds: 5));
      if (r.statusCode == 200)
        return (jsonDecode(r.body) as Map)['userId'] as int?;
      return null;
    } catch (_) {
      return null;
    }
  }

  /// تحديث المستخدم — يعيد البيانات المحدّثة من السيرفر أو يرمي ApiException
  Future<Map<String, dynamic>?> updateUser(
    int id, {
    String? name,
    String? password,
    String? phone,
    String? country,
    String? avatar,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (password != null && password.isNotEmpty) body['password'] = password;
      if (phone != null) body['phone'] = phone;
      if (country != null) body['country'] = country;
      if (avatar != null) body['avatar'] = avatar;
      if (body.isEmpty) return null;
      final r = await http
          .patch(
            Uri.parse('$_base/api/users/$id'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        return data is Map ? Map<String, dynamic>.from(data) : null;
      }
      String err = 'فشل تحديث البيانات';
      try {
        final m = jsonDecode(r.body) as Map?;
        if (m?['error'] != null) err = m!['error'] as String;
      } catch (_) {}
      throw ApiException(err);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('تأكد من تشغيل السيرفر والاتصال بالشبكة');
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await http
          .delete(Uri.parse('$_base/api/users/$id'))
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> getConversations(int userId) async {
    try {
      final r = await http
          .get(Uri.parse('$_base/api/messages/conversations/$userId'))
          .timeout(const Duration(seconds: 5));
      if (r.statusCode == 200)
        return List<Map<String, dynamic>>.from(jsonDecode(r.body));
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getMessages(
    int userId,
    int otherUserId,
  ) async {
    try {
      final r = await http
          .get(Uri.parse('$_base/api/messages/$userId/$otherUserId'))
          .timeout(const Duration(seconds: 5));
      if (r.statusCode == 200)
        return List<Map<String, dynamic>>.from(jsonDecode(r.body));
      return [];
    } catch (_) {
      return [];
    }
  }

  /// إرسال رسالة — يعيد الرسالة عند النجاح أو null عند الفشل
  // ============ Admin ============
  Future<Map<String, dynamic>?> getAdminStats(int adminUserId) async {
    try {
      final r = await http
          .get(Uri.parse('$_base/api/admin/stats?adminUserId=$adminUserId'))
          .timeout(const Duration(seconds: 8));
      if (r.statusCode == 200)
        return jsonDecode(r.body) as Map<String, dynamic>;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAdminUsers(int adminUserId) async {
    try {
      final r = await http
          .get(Uri.parse('$_base/api/admin/users?adminUserId=$adminUserId'))
          .timeout(const Duration(seconds: 8));
      if (r.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(r.body));
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// تفاصيل مستخدم للمدير (بدون كلمة مرور)
  Future<Map<String, dynamic>?> getAdminUserDetail(
    int adminUserId,
    int userId,
  ) async {
    try {
      final r = await http
          .get(
            Uri.parse(
              '$_base/api/admin/user/$userId?adminUserId=$adminUserId',
            ),
          )
          .timeout(const Duration(seconds: 8));
      if (r.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(r.body) as Map);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// تحديث مستخدم من لوحة الإدارة
  Future<Map<String, dynamic>?> adminUpdateUser(
    int adminUserId,
    int userId, {
    String? name,
    String? email,
    int? roleId,
    String? password,
    String? phone,
    String? country,
    bool? isBlocked,
    bool? expertVerified,
  }) async {
    try {
      final body = <String, dynamic>{'adminUserId': adminUserId};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (roleId != null) body['roleId'] = roleId;
      if (password != null && password.isNotEmpty) body['password'] = password;
      if (phone != null) body['phone'] = phone.isEmpty ? null : phone;
      if (country != null) body['country'] = country.isEmpty ? null : country;
      if (isBlocked != null) body['isBlocked'] = isBlocked;
      if (expertVerified != null) body['expertVerified'] = expertVerified;
      if (body.length <= 1) return null;
      final r = await http
          .patch(
            Uri.parse('$_base/api/admin/user/$userId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 12));
      if (r.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(r.body) as Map);
      }
      String err = 'فشل التحديث';
      try {
        final m = jsonDecode(r.body) as Map?;
        if (m?['error'] != null) err = m!['error'] as String;
      } catch (_) {}
      throw ApiException(err);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('تأكد من تشغيل السيرفر والاتصال بالشبكة');
    }
  }

  /// إنشاء مستخدم جديد من الإدارة — الحقل «بريد» يقبل أي نص
  Future<Map<String, dynamic>?> adminCreateUser(
    int adminUserId, {
    required String email,
    required String password,
    required String name,
    required int roleId,
  }) async {
    try {
      final r = await http
          .post(
            Uri.parse('$_base/api/admin/users'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'adminUserId': adminUserId,
              'email': email,
              'password': password,
              'name': name,
              'roleId': roleId,
            }),
          )
          .timeout(const Duration(seconds: 12));
      if (r.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(r.body) as Map);
      }
      String err = 'فشل الإنشاء';
      try {
        final m = jsonDecode(r.body) as Map?;
        if (m?['error'] != null) err = m!['error'] as String;
      } catch (_) {}
      throw ApiException(err);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('تأكد من تشغيل السيرفر والاتصال بالشبكة');
    }
  }

  Future<bool> adminDeleteUser(int adminUserId, int userId) async {
    try {
      final r = await http
          .delete(
            Uri.parse(
              '$_base/api/admin/user/$userId?adminUserId=$adminUserId',
            ),
          )
          .timeout(const Duration(seconds: 10));
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAdminSessions(int adminUserId) async {
    try {
      final r = await http
          .get(Uri.parse('$_base/api/admin/sessions?adminUserId=$adminUserId'))
          .timeout(const Duration(seconds: 8));
      if (r.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(r.body));
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<bool> sendAdminNotification({
    required int adminUserId,
    required String title,
    String? body,
    int? userId,
  }) async {
    try {
      final r = await http
          .post(
            Uri.parse('$_base/api/admin/notifications'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'adminUserId': adminUserId,
              'title': title,
              if (body != null) 'body': body,
              if (userId != null) 'userId': userId,
            }),
          )
          .timeout(const Duration(seconds: 8));
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> sendMessage(
    int senderId,
    int receiverId,
    String body,
  ) async {
    final sid = senderId;
    final rid = receiverId;
    final msgBody = body.trim();
    if (msgBody.isEmpty) return null;

    try {
      final r = await http
          .post(
            Uri.parse('$_base/api/messages'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'senderId': sid,
              'receiverId': rid,
              'body': msgBody,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        return data is Map ? Map<String, dynamic>.from(data) : null;
      }
      String errMsg = 'فشل إرسال الرسالة';
      try {
        final err = jsonDecode(r.body) as Map?;
        if (err != null && err['error'] != null)
          errMsg = err['error'] as String;
      } catch (_) {}
      throw ApiException(errMsg);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('تأكد من تشغيل السيرفر والاتصال بالشبكة');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}
