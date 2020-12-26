import 'dart:async';

import 'exceptions/observable_exception.dart';
import 'interfaces/subscription.dart';
import 'types/functions.dart';

part 'base/observable.dart';

class _Subscription<T> implements Subscription<T> {
  final _Listener<T> _listener;
  OnData<T> _data;
  OnError _error;
  OnDone _done;

  _Subscription(this._listener, this._data, this._error, this._done);

  void triggerData(T data) => _data?.call(data);

  void triggerError(Object error) => _error?.call(error);

  void triggerDone() {
    _done?.call();
    _data = null;
    _error = null;
    _done = null;
  }

  @override
  void cancel() {
    _listener.unListen(this);
    triggerDone();
  }

  @override
  void onData(handle) => _data = handle;

  @override
  void onDone(handle) => _done = handle;

  @override
  void onError(handle) => _error = handle;
}

class _Listener<T> {
  List<_Subscription<T>> _subscriptions = [];
  bool closing = false;

  void _isClosing([bool close = false]) {
    if (closing) {
      throw ObservableException(close);
    }
  }

  void listen(Subscription<T> subscription) {
    _isClosing();
    _subscriptions.add(subscription);
  }

  void unListen(Subscription<T> subscription) =>
      _subscriptions.remove(subscription);

  int get length => _subscriptions.length;

  void notifyData(T data) {
    _isClosing();
    scheduleMicrotask(() {
      for (var subscription in _subscriptions) {
        try {
          subscription.triggerData(data);
        } catch (e) {
          subscription.triggerError(e);
        }
      }
    });
  }

  void notifyError(Object error) {
    _isClosing();
    scheduleMicrotask(() {
      for (var subscription in _subscriptions) {
        subscription.triggerError(error);
      }
    });
  }

  Future<void> notifyDone() => Future.microtask(_onNotifyDone);

  void _onNotifyDone() {
    for (var subscription in _subscriptions) {
      subscription.triggerDone();
    }
    _subscriptions = null;
  }

  Future<void> close() {
    _isClosing(true);
    closing = true;
    return notifyDone();
  }
}

class _Observable<T> extends Observable<T> {
  _Listener<T> _listener = _Listener();
  T _value;

  _Observable([this._value]) : super._internal();

  @override
  T get value => _value;

  @override
  set value(T newValue) => add(newValue);

  void _isClosed([bool close = false]) {
    if (isClosed) {
      throw ObservableException(close);
    }
  }

  @override
  void add(T data) {
    _isClosed();
    _value = data;
    _listener.notifyData(data);
  }

  @override
  void addError(Object error) {
    _isClosed();
    _listener.notifyError(error);
  }

  @override
  Subscription<T> listen(onData, {onError, onDone}) {
    _isClosed();
    final Subscription<T> subscription = _Subscription(
      _listener,
      onData,
      onError,
      onDone,
    );
    _listener.listen(subscription);
    return subscription;
  }

  @override
  Future<void> close() async {
    _isClosed(true);
    await _listener.close();
    _listener = null;
    _value = null;
  }

  @override
  bool get hasListeners => length > 0;

  @override
  bool get isClosed => _listener == null;

  @override
  int get length => _listener?.length ?? 0;
}

extension ObservableX<T> on T {
  Observable<T> get obs => _Observable(this);
}
