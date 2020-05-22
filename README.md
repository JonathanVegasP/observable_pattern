# Observable Pattern

## Observable class

```dart
//This is how initialize the observable class that holds a value and listen to changes and automatically close it's stream inside Observer Widget.
//you don't need to pass an initial value, but you can set an initial value
Observable<String>('Initial Value'); // you can type like T is the type of the value and E is the type of the error. Or
final variable = ''.rx; //You can declare your observable using extension methods like this. It's like Observable<String> 

//you can pass a function to validate the value and reproduce an error object.
 Observable.transformer = (event) {
      if (event == null || event.isEmpty) {
        // return the type of the error if something is wrong
        return 'Type your email';
      } else {
        //return null if everything is ok
        return null;
      }
    };

//You can listen to changes when the value change with addListener.
Observable.listen((event) {
// do something...
});

//you can change the value with two ways
Observable<String>.value  = 'New Value';
//or
Observable<String>.add('New Value');
//after this the object will listen to the new value and validate automatically

//you can validate manually by yourself using
Observable.validate();

//you can validate and listen to all objects into one using a static function from the object
final Observable<bool> canSubmit = Observable.combine<String>(<Observable<String>>[object1, object2]);
//validate all objects put in param;
canSubmit.validate();
if(canSubmit.value) {
// do something...
}

/*
this static function will return an Observable<bool,void> that listen for every elements inside and validate then using
Observable.validate(); and hold a bool value that indicate if every object inside is validated without error if false
it'll indicate that an object has an error.
*/ 
```

## Observer Widget

Observer Widget is a widget that listen changes when a value inside Observable class and change
rebuild only where it's localized

in this example only the text widget will be rebuild.

```dart
   Observer<String>(
          stream: Observable.stream,
          builder: (BuildContext context, Reaction<String> snapshot) {
            return Text('${snapshot.hasData ? snapshot.data : ''}'); 
          },
```

## ObserverInjection

It is a simple way to inject dependencies using Inherited Widget and listen if the object
injected change and rebuild everything that is inside it

```dart
//Inject
ObserverInjection<UserData>(
builder: (context) => UserData(),
child: Container(),
//If necessary you can dispose
dispose: (context, UserData user) => user.dispose(),
);

//Read
final UserData user = ObserverInjection.of<UserData>(context);
```
