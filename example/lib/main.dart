import 'package:flutter/material.dart';
import 'package:observable_pattern/observable_pattern.dart';

//Create a store with variables of type Observable
class MyStore {
  final email = ''.rx;
  final password = ''.rx;
  Observable<bool> _canSubmit;
  final loading = false.rx;
  final done = false.rx;

  MyStore() {
    email.transformer = (event) {
      if (event == null || event.isEmpty) {
        return 'Type your email';
      } else {
        return null;
      }
    };
    password.transformer = (event) {
      if (event == null || event.isEmpty) {
        return 'Type your password';
      } else {
        return null;
      }
    };
  }

  void signIn() async {
    if (loading.value) return;
    canSubmit.validate();
    if (!canSubmit.value) return;
    loading.add(true);
    await Future.delayed(const Duration(seconds: 3));
    loading.add(false);
    done.add(true);
  }

  Observable<bool> get canSubmit {
    if (_canSubmit == null) {
      _canSubmit = Observable.combine<String>([email, password]);
    }
    return _canSubmit;
  }
}

//Initialize your app
class MyApp extends StatelessWidget {
  final String title;

  const MyApp({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(title: title),
    );
  }
}

//Create your own stateful screen
class LoginScreen extends StatefulWidget {
  final String title;

  const LoginScreen({Key key, this.title}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

//Into your state class put your store and the magic will begin
class _LoginScreenState extends State<LoginScreen> {
  final store = MyStore();

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(callback);
  }

  void callback() {
    final focus = FocusScope.of(context);
    store.loading.listen((bool event) {
      if (event) {
        focus.unfocus();
        //do something...
      }
    });
    store.done.listen((bool event) {
      if (event) {
        //do something...
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(widget.title),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Observer<String>(
                  stream: store.email.stream,
                  builder: (BuildContext context, Reaction<String> snapshot) =>
                      TextField(
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      errorText: snapshot.error,
                    ),
                    onChanged: store.email.add,
                  ),
                ),
                Observer<String>(
                  stream: store.password.stream,
                  builder: (BuildContext context, Reaction<String> reaction) =>
                      TextField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: reaction.error,
                    ),
                    obscureText: true,
                    onChanged: store.password.add,
                  ),
                ),
                const SizedBox(height: 24.0),
                RaisedButton(
                  shape: StadiumBorder(),
                  color: Colors.blue,
                  onPressed: store.signIn,
                  child: Text(
                    'Sign in without reactive',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24.0),
                Observer<bool>(
                  stream: store.canSubmit.stream,
                  builder: (BuildContext context, Reaction<bool> reaction) =>
                      RaisedButton(
                    shape: StadiumBorder(),
                    color: Colors.blue,
                    onPressed: reaction.hasValue && reaction.value
                        ? store.signIn
                        : null,
                    child: Text(
                      'Sign in with reactive',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Observer<bool>(
          stream: store.loading.stream,
          builder: (BuildContext context, Reaction<bool> reaction) =>
              reaction.hasValue && reaction.value
                  ? Material(
                      color: Colors.black54,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ],
                      ),
                    )
                  : Container(),
        )
      ],
    );
  }
}

//Initialize your dart app
void main() => runApp(MyApp(title: 'Observable Pattern Example'));
