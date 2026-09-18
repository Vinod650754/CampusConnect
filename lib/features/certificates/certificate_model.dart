import 'package:equatable/equatable.dart';

enum CertificateStatus { issued, revoked, pending }

class CertificateModel extends Equatable {
  final String id;
  final String title;
  final String? certificateHash;
  final String? certificateUrl;
  final String userId;
  final String userName;
  final String? eventId;
  final String? eventTitle;
  final CertificateStatus status;
  final DateTime issuedAt;
  final DateTime? revokedAt;

  const CertificateModel({required this.id, required this.title, this.certificateHash, this.certificateUrl, required this.userId, required this.userName, this.eventId, this.eventTitle, required this.status, required this.issuedAt, this.revokedAt});

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map ? Map<String, dynamic>.from(json['user'] as Map) : const <String, dynamic>{};
    final event = json['event'] is Map ? Map<String, dynamic>.from(json['event'] as Map) : const <String, dynamic>{};
    final raw = (json['status'] ?? 'ISSUED').toString().toUpperCase();
    return CertificateModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      certificateHash: json['certificateHash'] as String?,
      certificateUrl: json['certificateUrl'] as String?,
      userId: json['userId'] as String? ?? user['id'] as String? ?? '',
      userName: user['fullName'] as String? ?? '',
      eventId: json['eventId'] as String? ?? event['id'] as String?,
      eventTitle: event['title'] as String?,
      status: switch (raw) { 'REVOKED' => CertificateStatus.revoked, 'PENDING' => CertificateStatus.pending, _ => CertificateStatus.issued },
      issuedAt: DateTime.tryParse(json['issuedAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      revokedAt: DateTime.tryParse(json['revokedAt']?.toString() ?? ''),
    );
  }
  CertificateModel copyWith({CertificateStatus? status, DateTime? revokedAt}) => CertificateModel(id: id, title: title, certificateHash: certificateHash, certificateUrl: certificateUrl, userId: userId, userName: userName, eventId: eventId, eventTitle: eventTitle, status: status ?? this.status, issuedAt: issuedAt, revokedAt: revokedAt ?? this.revokedAt);
  bool get isValid => status == CertificateStatus.issued;
  @override List<Object?> get props => [id, title, certificateHash, certificateUrl, userId, userName, eventId, eventTitle, status, issuedAt, revokedAt];
}
