import 'package:equatable/equatable.dart';

enum AnnouncementTargetRole { coreTeam, member, student }

class AnnouncementModel extends Equatable {
  final String id;
  final String title;
  final String content;
  final List<AnnouncementTargetRole> targetRoles;
  final bool isPinned;
  final bool isPublished;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final String authorName;

  const AnnouncementModel({required this.id, required this.title, required this.content, required this.targetRoles, required this.isPinned, required this.isPublished, required this.publishedAt, required this.createdAt, required this.authorName});

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] is Map ? Map<String, dynamic>.from(json['author'] as Map) : const <String, dynamic>{};
    final roles = (json['targetRoles'] as List? ?? const []).map((e) => e.toString().toUpperCase()).map((e) {
      switch (e) {
        case 'CORE_TEAM': return AnnouncementTargetRole.coreTeam;
        case 'MEMBER': return AnnouncementTargetRole.member;
        default: return AnnouncementTargetRole.student;
      }
    }).toList();
    return AnnouncementModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      targetRoles: roles,
      isPinned: json['isPinned'] as bool? ?? false,
      isPublished: json['isPublished'] as bool? ?? false,
      publishedAt: DateTime.tryParse(json['publishedAt']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      authorName: author['fullName'] as String? ?? 'CampusConnect',
    );
  }

  AnnouncementModel copyWith({String? title, String? content, List<AnnouncementTargetRole>? targetRoles, bool? isPinned, bool? isPublished, DateTime? publishedAt}) => AnnouncementModel(id: id, title: title ?? this.title, content: content ?? this.content, targetRoles: targetRoles ?? this.targetRoles, isPinned: isPinned ?? this.isPinned, isPublished: isPublished ?? this.isPublished, publishedAt: publishedAt ?? this.publishedAt, createdAt: createdAt, authorName: authorName);

  String get audienceLabel => targetRoles.map((role) => switch (role) { AnnouncementTargetRole.coreTeam => 'Core Team', AnnouncementTargetRole.member => 'Members', AnnouncementTargetRole.student => 'Students' }).join(' • ');
  List<String> get backendTargetRoles => targetRoles.map((role) => switch (role) { AnnouncementTargetRole.coreTeam => 'CORE_TEAM', AnnouncementTargetRole.member => 'MEMBER', AnnouncementTargetRole.student => 'STUDENT' }).toList();

  @override List<Object?> get props => [id, title, content, targetRoles, isPinned, isPublished, publishedAt, createdAt, authorName];
}
