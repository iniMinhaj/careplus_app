import 'package:equatable/equatable.dart';

sealed class SpecializationEvent extends Equatable {
  const SpecializationEvent();

  @override
  List<Object?> get props => [];
}

class SpecializationRequested extends SpecializationEvent {
  /// True for pull-to-refresh, which should drop any active category
  /// selection along with re-fetching.
  final bool resetSelection;

  const SpecializationRequested({this.resetSelection = false});

  @override
  List<Object?> get props => [resetSelection];
}

/// Toggle semantics: re-selecting the already-selected id clears it.
class SpecializationSelected extends SpecializationEvent {
  final String id;

  const SpecializationSelected(this.id);

  @override
  List<Object?> get props => [id];
}
