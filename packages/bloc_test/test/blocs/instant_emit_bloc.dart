import 'package:bloc/bloc.dart';

import 'blocs.dart';

class InstantEmitBloc extends Bloc<CounterEvent, int> {
  InstantEmitBloc() : super(0) {
    on<CounterEvent>(_onEvent);
    add(CounterEvent.increment);
  }

  void _onEvent(CounterEvent event, Emitter<int> emit) async {
    switch (event) {
      case CounterEvent.increment:
        return emit(state + 1);
    }
  }
}
