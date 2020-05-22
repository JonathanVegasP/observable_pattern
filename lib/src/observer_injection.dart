import 'package:flutter/widgets.dart';

///An interface to create a data when building the widget tree
typedef _ObserverInjectionBuilder<T> = T Function(BuildContext context);

///An interface that is called when the ObserverInjection class is disposed from widget tree
typedef _Dispose<T> = void Function(BuildContext, T value);

///A class that hold an Object and change the widget three after this object changes
class ObserverInjection<T> extends StatefulWidget {
  final _ObserverInjectionBuilder<T> builder;
  final _Dispose<T> dispose;
  final Widget child;

  const ObserverInjection({
    Key key,
    @required this.builder,
    this.dispose,
    @required this.child,
  })  : assert(builder != null && child != null),
        super(key: key);

  static T of<T>(BuildContext context) {
    final element =
        context.dependOnInheritedWidgetOfExactType<_ObserverInjector<T>>();
    if (element == null || element.data == null) {
      throw _ObserverInjectionException(T, context.widget.runtimeType);
    }
    return element.data;
  }

  @override
  _ObserverInjectionState<T> createState() => _ObserverInjectionState<T>();
}

class _ObserverInjectionState<T> extends State<ObserverInjection<T>> {
  T data;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    data = widget.builder(context);
  }

  @override
  void dispose() {
    if (widget.dispose != null) {
      widget.dispose(context, data);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ObserverInjector<T>(
      child: widget.child,
      data: data,
    );
  }
}

///A class that inject a value received from ObserverInjection class into the whole tree
class _ObserverInjector<T> extends InheritedWidget {
  const _ObserverInjector({
    Key key,
    @required this.data,
    @required Widget child,
  })  : assert(child != null),
        super(key: key, child: child);

  final T data;

  @override
  bool updateShouldNotify(_ObserverInjector<T> old) => old.data != data;
}

///A class that is used when an exception was occurred
class _ObserverInjectionException implements Exception {
  final Type type;
  final Type widget;

  const _ObserverInjectionException(this.type, this.widget);

  @override
  String toString() {
    return 'ObserverInjectionException: Could not find the correct ObserverInjection<$type> above this $widget Widget';
  }
}
