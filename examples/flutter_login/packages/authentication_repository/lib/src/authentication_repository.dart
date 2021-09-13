import 'dart:async';

import 'package:equatable/equatable.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

abstract class AuthenticationStatusEx extends Equatable {
  const AuthenticationStatusEx(this.status);

  final AuthenticationStatus status;

  @override
  List<Object> get props => [];
}

class AuthenticationStatusUnknown extends AuthenticationStatusEx {
  const AuthenticationStatusUnknown() : super(AuthenticationStatus.unknown);

  @override
  List<Object> get props => [];
}

class AuthenticationStatusAuthenticated extends AuthenticationStatusEx {
  const AuthenticationStatusAuthenticated(this.name, this.password)
      : super(AuthenticationStatus.authenticated);

  final String name;
  final String password;

  @override
  List<Object> get props => [name, password];
}

class AuthenticationStatusuUnauthenticated extends AuthenticationStatusEx {
  const AuthenticationStatusuUnauthenticated()
      : super(AuthenticationStatus.unauthenticated);

  @override
  List<Object> get props => [];
}

// enum AuthenticationStatus { unknown, authenticated, unauthenticated }

//todo AuthenticationStatus.authenticated with user profile
class AuthenticationRepository {
  final _controller = StreamController<AuthenticationStatusEx>();

  Stream<AuthenticationStatusEx> get status async* {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield const AuthenticationStatusuUnauthenticated();
    yield* _controller.stream;
  }

  Future<void> logIn({
    required String username,
    required String password,
  }) async {
    print('logIn $username $password');
    await Future.delayed(
      const Duration(milliseconds: 300),
      () => _controller
          .add(AuthenticationStatusAuthenticated(username, password)),
    );
  }

  void logOut() {
    _controller.add(const AuthenticationStatusuUnauthenticated());
  }

  void dispose() => _controller.close();
}
