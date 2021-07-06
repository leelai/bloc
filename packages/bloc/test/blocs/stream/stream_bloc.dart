import 'package:bloc/bloc.dart';

class StreamEvent {}

class StreamBloc extends Bloc<StreamEvent, int> {
  StreamBloc(Stream<int> stream) : super(0) {
    on<StreamEvent>((_, emit) async* {
      await for (final i in stream) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        emit(i);
      }
    }, restartable());
  }
}
