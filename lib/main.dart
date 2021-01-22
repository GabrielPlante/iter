import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Requires that a Firestore emulator is running locally.
/// See https://firebase.flutter.dev/docs/firestore/usage#emulator-usage
bool USE_FIRESTORE_EMULATOR = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  /* if (USE_FIRESTORE_EMULATOR) {
    FirebaseFirestore.instance.settings = Settings(
        host: 'localhost:8080', sslEnabled: false, persistenceEnabled: false);
  } */
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  MaterialApp withMaterialApp(Widget body) {
    return MaterialApp(
      title: 'Test BDD',
      theme: ThemeData.dark(),
      home: Scaffold(
        body: body,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return withMaterialApp(Center(child: MainView()));
  }
}

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance.collection('Data');

    return Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Menu Principal'),
              StreamBuilder(
                stream: FirebaseFirestore.instance.snapshotsInSync(),
                builder: (context, _) {
                  return Text(
                    'Dernière mise à jour: ${DateTime.now()}',
                    style: Theme.of(context).textTheme.caption,
                  );
                },
              )
            ],
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: query.snapshots(),
          builder: (context, stream) {
            if (stream.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (stream.hasError) {
              return Center(child: Text(stream.error.toString()));
            }

            QuerySnapshot querySnapshot = stream.data;

            if(querySnapshot == null || querySnapshot.size == 0) {
              return Center(child: Text("Pas de donnée à afficher"));
            }

            return ListView.builder(
              itemCount: querySnapshot.size,
              itemBuilder: (context, index) => DataCard(querySnapshot.docs[index]),
            );
          },
        ));
  }
}


class DataCard extends StatelessWidget {

  final DocumentSnapshot snapshot;

  /// Initialize a [Move] instance with a given [DocumentSnapshot].
  DataCard(this.snapshot);

  /// Returns the [DocumentSnapshot] data as a a [Map].
  Map<String, dynamic> get data {
    return snapshot.data();
  }


  Widget get dataName {
    return Container(
      width: 100,
      child: Center(child: Text(data['name'])),
    );
  }




  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: 4, top: 4),
        child: Card(
          child: dataName,
        ));
  }
}