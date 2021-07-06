import 'package:bloc/bloc.dart';

import '../counter/counter_bloc.dart';

class OnTransitionErrorBloc extends Bloc<CounterEvent, int> {
  OnTransitionErrorBloc({
    required this.error,
    required this.onErrorCallback,
  }) : super(0) {
    on<CounterEvent>(_onCounterEvent);
  }

  final Function onErrorCallback;
  final Error error;

  @override
  void onError(Object error, StackTrace stackTrace) {
    onErrorCallback(error, stackTrace);
    super.onError(error, stackTrace);
  }

  @override
  void onTransition(Transition<CounterEvent, int> transition) {
    super.onTransition(transition);
    throw error;
  }

  Stream<void> _onCounterEvent(CounterEvent event, Emit<int> emit) async* {
    switch (event) {
      case CounterEvent.increment:
        emit(state + 1);
        break;
      case CounterEvent.decrement:
        emit(state - 1);
        break;
    }
  }
}
