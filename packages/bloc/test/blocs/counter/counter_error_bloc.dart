import 'package:bloc/bloc.dart';

import '../counter/counter_bloc.dart';

class CounterErrorBloc extends Bloc<CounterEvent, int> {
  CounterErrorBloc() : super(0) {
    on<CounterEvent>(_onCounterEvent);
  }

  Stream<void> _onCounterEvent(CounterEvent event, Emit<int> emit) async* {
    switch (event) {
      case CounterEvent.decrement:
        emit(state - 1);
        break;
      case CounterEvent.increment:
        throw Error();
    }
  }
}
