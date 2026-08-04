import 'package:equatable/equatable.dart';

class EmergencyContact extends Equatable {
  final String name;
  final String relation;
  final String phone;

  const EmergencyContact({
    required this.name,
    required this.relation,
    required this.phone,
  });

  @override
  List<Object?> get props => [name, relation, phone];
}
