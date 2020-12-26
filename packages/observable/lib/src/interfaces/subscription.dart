import '../types/functions.dart';

mixin Subscription<T> {
  void onData(OnData<T> handle);

  void onError(OnError handle);

  void onDone(OnDone handle);

  void cancel();
}
