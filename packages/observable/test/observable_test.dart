import 'dart:async';

import 'package:observable/observable.dart';
import 'package:observable/src/exceptions/observable_exception.dart';
import 'package:test/test.dart';

void main() {
  group('OnData listener', () {
    Observable<List> observable;

    setUp(() {
      observable = [].obs;
      observable.listen((data) {
        final completer = data[0] as Completer;
        final value = data[1];
        completer.complete(value);
      });
    });

    tearDown(() {
      observable.close();
      observable = null;
    });

    test('Observable is a _Observable', () {
      expect(
        observable.runtimeType.toString(),
        '_Observable<List<dynamic>>',
      );
    });

    test('Trigger onData', () async {
      expect(observable.value, isA<List>());
      final completer = Completer();
      final data = 'Hello World';
      observable.add([completer, data]);
      final value = await completer.future;
      expect(value, data);
      expect(observable.value[1], data);
    });
  });

  group('OnError listener', () {
    Observable observable;
    Completer<StateError> error;

    setUp(() {
      observable = Observable();
      error = Completer();
      observable.listen(
        (_) => throw StateError('test'),
        onError: (err) => error.complete(err),
      );
    });

    tearDown(() {
      observable.close();
      observable = null;
      error = null;
    });

    test('Trigger onError', () async {
      final stateError = StateError('test');
      observable.addError(stateError);
      final err = await error.future;
      expect(err, stateError);
    });

    test('Trigger onData and call an onError', () async {
      observable.add(null);
      final err = await error.future;
      expect(err, isA<StateError>());
    });
  });

  group('OnDone listener', () {
    Observable observable;
    Completer<bool> done;
    Subscription subscription;

    setUp(() {
      observable = Observable();
      done = Completer();
      subscription = observable.listen(
        null,
        onDone: () => done?.complete(true),
      );
    });

    tearDown(() {
      if (!observable.isClosed) {
        observable.close();
      }
      observable = null;
      subscription = null;
      done = null;
    });

    test('Subscription is a _Subscription', () {
      expect(subscription.runtimeType.toString(), '_Subscription<dynamic>');
    });

    test('Subscription cancel', () async {
      expect(observable.length, 1);
      expect(observable.hasListeners, isTrue);
      expect(observable.isClosed, isFalse);
      subscription.cancel();
      final result = await done.future;
      expect(result, isTrue);
      expect(observable.length, 0);
      expect(observable.hasListeners, isFalse);
      expect(observable.isClosed, isFalse);
    });

    test('Observable close', () {
      expect(observable.length, 1);
      expect(observable.hasListeners, isTrue);
      expect(observable.isClosed, isFalse);
      observable.close().then((value) async {
        final result = await done.future;
        expect(result, isTrue);
        expect(observable.length, 0);
        expect(observable.hasListeners, isFalse);
        expect(observable.isClosed, isTrue);
        expect(() => observable.add(null), throwsA(isA<ObservableException>()));
        expect(
          () => observable.value = null,
          throwsA(isA<ObservableException>()),
        );
        expect(
          () => observable.addError(null),
          throwsA(isA<ObservableException>()),
        );
        expect(
          () => observable.listen(null),
          throwsA(isA<ObservableException>()),
        );
        expect(() => observable.close(), throwsA(isA<ObservableException>()));
      });
      expect(observable.length, 1);
      expect(observable.hasListeners, isTrue);
      expect(observable.isClosed, isFalse);
      expect(() => observable.add(null), throwsA(isA<ObservableException>()));
      expect(
        () => observable.value = null,
        throwsA(isA<ObservableException>()),
      );
      expect(
        () => observable.addError(null),
        throwsA(isA<ObservableException>()),
      );
      expect(
        () => observable.listen(null),
        throwsA(isA<ObservableException>()),
      );
      expect(() => observable.close(), throwsA(isA<ObservableException>()));
    });
  });

  group('Subscription handler', () {
    Observable<bool> observable;
    Completer<bool> dataHandler;
    Subscription<bool> subscription;

    setUp(() {
      observable = false.obs;
      dataHandler = Completer();
      subscription = observable.listen(null);
    });

    tearDown(() => observable.close());

    test('Change onData callback', () async {
      subscription.onData((data) => dataHandler.complete(data));
      final data = true;
      observable.value = data;
      final value = await dataHandler.future;
      expect(value, data);
      expect(observable.value, data);
    });

    test('Change onError callback', () async {
      subscription.onError((error) => dataHandler.complete(error));
      final data = true;
      observable.addError(data);
      final value = await dataHandler.future;
      expect(value, data);
      expect(observable.value, isFalse);
    });

    test('Change onDone callback', () async {
      subscription.onDone(() => dataHandler.complete(true));
      subscription.cancel();
      final value = await dataHandler.future;
      expect(value, isTrue);
      expect(observable.value, isFalse);
    });
  });
}
