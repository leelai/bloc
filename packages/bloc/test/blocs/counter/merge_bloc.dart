import 'package:bloc/bloc.dart';

import '../blocs.dart';

EventModifier<CounterEvent> custom() {
  return (event, events, next) async {
    if (event == CounterEvent.decrement) return next();
    if (events().isEmpty) return next();
    await Future<void>.delayed(const Duration(milliseconds: 100), next);
  };
}

class MergeBloc extends Bloc<CounterEvent, int> {
  MergeBloc({this.onTransitionCallback}) : super(0) {
    on<CounterEvent>(_onCounterEvent, custom());
  }

  final void Function(Transition<CounterEvent, int>)? onTransitionCallback;

  @override
  void onTransition(Transition<CounterEvent, int> transition) {
    super.onTransition(transition);
    onTransitionCallback?.call(transition);
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
