import 'dart:async';

enum AppEvent { tasksChanged }
//zarządza zdarzeniami aplikacji, które mogą być emitowane i subskrybowane
class AppEvents {
  AppEvents._();
  static final AppEvents I = AppEvents._();

  final StreamController<AppEvent> _controller = StreamController<AppEvent>.broadcast();
  Stream<AppEvent> get stream => _controller.stream;

  void emit(AppEvent e) => _controller.add(e);
}
