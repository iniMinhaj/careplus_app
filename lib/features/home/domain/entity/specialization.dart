import 'package:equatable/equatable.dart';

class Specialization extends Equatable {
  final String id;
  final String name;
  final String icon;
  final int doctorCount;

  const Specialization({
    required this.id,
    required this.name,
    required this.icon,
    required this.doctorCount,
  });

  @override
  List<Object?> get props => [id, name, icon, doctorCount];
}
