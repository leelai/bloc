import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'complex_event.dart';
part 'complex_state.dart';

const _delay = Duration(milliseconds: 100);

class ComplexBloc extends Bloc<ComplexEvent, ComplexState> {
  ComplexBloc() : super(ComplexStateA()) {
    on<ComplexEventA>((_, emit) async* {
      emit(ComplexStateA());
    });
    on<ComplexEventB>((_, emit) async* {
      emit(ComplexStateB());
    });
    on<ComplexEventC>(
      (_, emit) async* {
        await Future<void>.delayed(_delay, () => emit(ComplexStateC()));
      },
    );
    on<ComplexEventD>(
      (_, emit) async* {
        await Future<void>.delayed(_delay, () => emit(ComplexStateD()));
      },
    );
  }

  @override
  Stream<ComplexState> transformStates(Stream<ComplexState> states) {
    return states.debounceTime(const Duration(milliseconds: 50));
  }
}
