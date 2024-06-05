import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/common/toastr.dart';
import 'package:flutter_application_1/config/firebase_notification.dart';
import 'package:flutter_application_1/config/firebase_option.dart';
import 'package:flutter_application_1/login.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:permission_handler/permission_handler.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification!.body}');
}

void main() async {
  // firebase initialization
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (await Permission.notification.request().isGranted) {
    await NotificationService().initNotifications();
    await NotificationService().getToken();
  }
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(const MyApp());
}

final db = FirebaseFirestore.instance;

DatabaseReference ref =
    FirebaseDatabase.instance.ref('todos'); //firebase realtime database

String? value;

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktik Firebase Cloud Firestore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String userId = "";
  String email = "";
  bool isLogin = false;
  @override
  void initState() {
    super.initState();
    //check user login
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
        setState(() {
          userId = '';
          email = '';
          isLogin = false;
        });
      } else {
        setState(() {
          userId = user.uid;
          email = user.email!;
          isLogin = true;
        });
        print('User is signed in! oke ' + email);
      }
    });

    //fcm notification
    // get token firebase

    FirebaseMessaging.instance.getToken().then((String? token) {
      print('FIREBASE: $token');
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message recieved");
      print(event.notification!.body);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(event.notification!.title!),
              content: Text(event.notification!.body!),
              actions: [
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return showBottomSheet(context, false, null);
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Todo App'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              getDataRealTime();
            },
          ),
          // icon login
          isLogin
              ? IconButton(
                  icon: const Icon(Icons.account_circle_outlined),
                  onPressed: () {
                    // _prefs.then((SharedPreferences prefs) {
                    //   prefs.remove('userId');
                    // });
                    showToast(message: email);
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.login_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Login(),
                      ),
                    );
                  },
                ),

          isLogin
              ? IconButton(
                  icon: const Icon(Icons.logout_sharp),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                )
              : const SizedBox(),
        ],
      ),
      body: StreamBuilder(
        stream: db.collection('todos').snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, int index) {
              DocumentSnapshot documentSnapshot = snapshot.data.docs[index];
              return ListTile(
                title: Text(documentSnapshot['todo']),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return showBottomSheet(context, true, documentSnapshot);
                    },
                  );
                },
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                  onPressed: () {
                    // Here We Will Add The Delete Feature
                    db.collection('todos').doc(documentSnapshot.id).delete();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

showBottomSheet(
    BuildContext context, bool isUpdate, DocumentSnapshot? documentSnapshot) {
  // Added the isUpdate argument to check if our item has been updated
  return Padding(
    padding: const EdgeInsets.only(top: 20),
    child: Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: TextField(
            controller: isUpdate
                ? TextEditingController(text: documentSnapshot?['todo'])
                : TextEditingController(),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: isUpdate ? 'Update Todo' : 'Add Todo',
              hintText: 'Enter An Item',
            ),
            onChanged: (String _val) {
              // Storing the value of the text entered in the variable value.
              value = _val;
            },
          ),
        ),
        TextButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(Colors.lightBlueAccent),
            ),
            onPressed: () {
              // Check to see if isUpdate is true then update the value else add the value
              if (isUpdate) {
                db.collection('todos').doc(documentSnapshot?.id).update({
                  'todo': value,
                });
              } else {
                db
                    .collection('todos')
                    .add({'todo': value, 'tanggal': DateTime.now()});
                addDataRealTime(value!);
              }
              Navigator.pop(context);
            },
            child: isUpdate
                ? const Text(
                    'UPDATE',
                    style: TextStyle(color: Colors.white),
                  )
                : const Text('ADD', style: TextStyle(color: Colors.white))),
      ],
    ),
  );
}

//INI CONTOH JIKA FIREBASE REALTIME DATABASE
void addDataRealTime(String todo) {
  ref.push().set({
    'name': todo,
  });
}

void updateDataRealTime(String key, String todo) {
  ref.child(key).update({
    'name': todo,
  });
}

void deleteDataRealTime(String key) {
  ref.child(key).remove();
}

void getDataRealTime() {
  ref.onValue.listen((event) {
    DataSnapshot dataSnapshot = event.snapshot;
    Map<dynamic, dynamic>? values = dataSnapshot.value as Map?;
    values!.forEach((key, value) {
      print(value['name']);
    });
  });
}
