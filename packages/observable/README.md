# Observable

A library for reactive programming with Dart

## Usage

A simple usage example:

```dart
import 'package:observable/observable.dart';

void main() {
  /// Initialize the observable
  final observable = Observable<int>();

  /// Or final observable = 0.obs.
  /// Can be any type you want not only int or double types

  /// Create an subscription and handle the callbacks or maybe change
  /// someone and cancel when needed
  final subscription = observable.listen(
    (data) {
      //Do something
    },
    onError: (error) {
      //Handle Error
    },
    onDone: () {
      //Handle after closed
    },
  );

  /// Add an event to observable. If it trigger an exception the
  /// onError listener will be called than onData listener
  observable.add(1);

  /// Or observable.value = 1. As it does the same thing the add method

  /// Add an event error to observable. It can be anything
  observable.addError(Exception());

  /// Get the current data that was added to observable
  observable.value;

  /// Check if the observable has a listener
  observable.hasListeners;

  /// Check how many listeners the observable has
  observable.length;

  /// Check if the observable is closed
  observable.isClosed;

  /// Change onData callback
  subscription.onData((data) {
    //Do something
  });

  /// Change onError callback
  subscription.onError((error) {
    //Do something
  });

  /// Change onDone callback
  subscription.onDone(() {
    //Do something
  });

  /// Cancel subscription and trigger onDone callback
  subscription.cancel();

  /// Close all subscriptions and trigger onDone callback on every subscription
  observable.close();
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/jonathanvegasp/observable_pattern/issues
