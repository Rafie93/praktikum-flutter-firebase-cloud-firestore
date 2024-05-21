import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  // firebase initialization
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: '',
        authDomain: '',
        databaseURL: '',
        projectId: "",
        storageBucket: "",
        messagingSenderId: "",
        appId: "",
        measurementId: ""),
  );
  runApp(const MyApp());
}

final db = FirebaseFirestore.instance;
String? value;

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);
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
                db.collection('todos').add({'todo': value});
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
