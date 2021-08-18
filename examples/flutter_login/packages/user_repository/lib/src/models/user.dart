import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User(this.id, this.name);

  final String id;
  final String name;

  @override
  List<Object> get props => [id];

  static const empty = User('-', '');
}
