import 'dart:async';

///An interface that validate the value when it's changed and retain the error in an error object
typedef ObservableTransformer<V> = dynamic Function(V value);

///A class interface that hold values and sink data
mixin Reaction<V> {
  static Reaction get empty => const _EmptyReaction();

  V get value;

  dynamic get error;

  bool get hasValue => value != null;

  bool get hasError => error != null;

  void add(V value);

  set value(V value);
}

class _EmptyReaction<V> implements Reaction<V> {
  const _EmptyReaction();

  @override
  V get value => null;

  @override
  set value(V value) {}

  @override
  void add(V value) {}

  @override
  get error => null;

  @override
  bool get hasError => false;

  @override
  bool get hasValue => false;
}

///A class that manage a value and dispatch notifications when the value is change or validating;
class Observable<V> extends StreamView<V> with Reaction<V> {
  final StreamController<V> _controller;
  bool _dirty = false;
  V _value;
  dynamic _error;
  ObservableTransformer<V> transformer = (_) => null;

  Observable._(this._controller, this._value) : super(_controller.stream);

  factory Observable([V value]) =>
      Observable._(StreamController.broadcast(sync: true), value);

  static Observable<bool> combine<V>(List<Observable<V>> observables) {
    final observable = Observable<bool>(false);
    observable.listen((_) {
      var value = true;
      for (var data in observables) {
        if (data._hasError) {
          value = false;
          break;
        }
      }
      observable._value = value;
    });
    observable.transformer = (_) {
      for (var data in observables) {
        if (data._hasError) {
          data.validate();
        }
      }
      return null;
    };
    for (var data in observables) {
      data.listen((_) {
        if (!observable._dirty) {
          observable._controller.add(observable._value);
        }
      });
    }
    return observable;
  }

  Stream<V> get stream => this;

  Reaction<V> get reaction => this;

  Future close() => _controller.close().then((_) {
        _dirty = null;
        _value = null;
        _error = null;
        transformer = null;
      });

  @override
  V get value => _value;

  @override
  set value(V value) => add(value);

  @override
  void add(V value) {
    if (_value == value) {
      return;
    }
    _error = transformer(value);
    _value = value;
    _controller.add(value);
  }

  @override
  dynamic get error => _error;

  bool validate() {
    _dirty = true;
    _error = transformer(_value);
    _dirty = false;
    _controller.add(_value);
    return !hasError;
  }

  bool get _hasError => transformer(_value) != null;
}

extension StringX on String {
  Observable<String> get rx => Observable<String>(this);
}

extension IntX on int {
  Observable<int> get rx => Observable<int>(this);
}

extension DoubleX on double {
  Observable<double> get rx => Observable<double>(this);
}

extension NumX on num {
  Observable<num> get rx => Observable<num>(this);
}

extension ListX on List {
  Observable<List> get rx => Observable<List>(this);
}

extension MapX on Map {
  Observable<Map> get rx => Observable<Map>(this);
}

extension BoolX on bool {
  Observable<bool> get rx => Observable<bool>(this);
}

extension DynamicX on dynamic {
  Observable<dynamic> get rx => Observable<dynamic>(this);
}

extension ObjectX on Object {
  Observable<Object> get rx => Observable<Object>(this);
}
