part of '../observable_impl.dart';

abstract class Observable<T> {
  const Observable._internal();

  factory Observable([T value]) = _Observable<T>;

  T get value;

  set value(T newValue);

  void add(T data);

  void addError(Object error);

  Subscription<T> listen(OnData<T> onData, {OnError onError, OnDone onDone});

  int get length;

  bool get hasListeners;

  bool get isClosed;

  Future<void> close();

  @override
  String toString() => '$value';
}
