import 'package:bloc/bloc.dart';

typedef OnEventCallback = Function(CounterEvent);
typedef OnTransitionCallback = Function(Transition<CounterEvent, int>);
typedef OnErrorCallback = Function(Object error, StackTrace? stackTrace);

enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc({
    this.onEventCallback,
    this.onTransitionCallback,
    this.onErrorCallback,
  }) : super(0) {
    on<CounterEvent>(_onCounterEvent);
  }

  final OnEventCallback? onEventCallback;
  final OnTransitionCallback? onTransitionCallback;
  final OnErrorCallback? onErrorCallback;

  @override
  void onEvent(CounterEvent event) {
    super.onEvent(event);
    onEventCallback?.call(event);
  }

  @override
  void onTransition(Transition<CounterEvent, int> transition) {
    super.onTransition(transition);
    onTransitionCallback?.call(transition);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    onErrorCallback?.call(error, stackTrace);
    super.onError(error, stackTrace);
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
