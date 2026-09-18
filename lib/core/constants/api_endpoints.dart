class ApiEndpoints {
  ApiEndpoints._();

  static const register = '/auth/register';
  static const login = '/auth/login';
  static const refreshToken = '/auth/refresh';
  static const logout = '/auth/logout';
  static const profile = '/auth/me';
  static const health = '/health';

  static const users = '/users';
  static const userOverview = '/users/overview';

  static const events = '/events';
  static String eventById(String id) => '/events/$id';
  static String eventAttendanceQr(String id) => '/events/$id/attendance-qr';
  static String publishEvent(String id) => '/events/$id/publish';

  static const registrationsMy = '/registrations/my';
  static String registerForEvent(String eventId) => '/registrations/events/$eventId';
  static String eventRegistrations(String eventId) => '/registrations/events/$eventId';
  static String cancelRegistration(String registrationId) => '/registrations/$registrationId/cancel';
  static String updateRegistrationStatus(String registrationId) => '/registrations/$registrationId/status';

  static const attendanceScan = '/attendance/scan';
  static String eventAttendance(String eventId) => '/attendance/events/$eventId';
  static String ownAttendance(String eventId) => '/attendance/events/$eventId/me';
  static String updateAttendance(String attendanceId) => '/attendance/$attendanceId';

  static const announcements = '/announcements';
  static const adminAnnouncements = '/announcements/manage';
  static String announcementById(String id) => '/announcements/$id';

  static const notifications = '/notifications';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const notificationsReadAll = '/notifications/read-all';

  static const gallery = '/gallery';
  static String galleryById(String id) => '/gallery/$id';

  static const certificatesMy = '/certificates/my';
  static const certificates = '/certificates';
  static String certificateRevoke(String id) => '/certificates/$id/revoke';
  static String certificateVerify(String hash) => '/certificates/verify/$hash';

  static const profileMe = '/profile';
  static const profilePassword = '/profile/password';
}
