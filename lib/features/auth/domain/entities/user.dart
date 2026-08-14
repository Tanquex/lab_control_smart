class User {
  final String id;
  final String name;
  final String email;
  final String studentId;
  final String career;
  final String role; // 'student', 'teacher', 'admin'

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.studentId,
    required this.career,
    required this.role,
  });
}
