import 'package:equatable/equatable.dart';

/// Base type for domain entities.
///
/// Every entity carries a stable [id] and uses value equality (via
/// [Equatable]) so entities compare by data, not identity — which keeps
/// Riverpod / widget rebuilds correct and predictable.
abstract class Entity extends Equatable {
  const Entity({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];

  @override
  bool get stringify => true;
}

/// Contract for mapping a model to/from a serializable map (e.g. Firestore).
///
/// Data-layer models implement [toMap]; a matching `fromMap` factory is
/// provided per model. Kept separate from [Entity] so pure domain entities
/// need not know about serialization.
abstract interface class Serializable {
  Map<String, dynamic> toMap();
}
