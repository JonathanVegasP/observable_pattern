import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:observable_pattern/src/observable.dart';

///An interface that build and rebuild after a value change with a value holder
typedef ObservableBuilder<V> = Widget Function(
    BuildContext context, Reaction<V> reaction);

///a class that receive a stream that extends observable and a builder to rebuild when a value change from Observable object
class Observer<V> extends StatefulWidget {
  final Observable<V> _observable;
  final ObservableBuilder<V> builder;

  const Observer({
    Key key,
    Stream<V> stream,
    @required this.builder,
  })  : assert(stream is Observable, 'This stream must be part of Observable'),
        assert(builder != null),
        _observable = stream as Observable,
        super(key: key);

  @override
  _ObserverState<V> createState() => _ObserverState<V>();
}

class _ObserverState<V> extends State<Observer<V>> {
  StreamSubscription<V> _subscription;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_subscribe);
  }

  void _subscribe() {
    _subscription = widget._observable?.listen(_callback);
  }

  void _callback(V value) {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    widget._observable?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child =
        widget.builder(context, widget._observable?.reaction ?? Reaction.empty);
    assert(child != null);
    return child;
  }
}
