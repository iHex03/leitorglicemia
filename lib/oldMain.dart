import 'package:flutter/material.dart';

void main(List<String> args) {
  runApp(const MySettings());
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//           appBar: AppBar(
//             backgroundColor: Colors.cyan[900],
//             title: const Text("Tela Inicial"),
//           ),
//           body: Center(
//             child: Container(
//               child: const Text('Oi'),
//               margin: const EdgeInsets.all(100),
//               padding: const EdgeInsets.all(10),
//               color: Colors.amber[800],
//               height: 100,
//               width: 100,
//             ),
//           )),
//     );
//   }
// }
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         home: Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.cyan[900],
//         title: const Text("Tela Inicial"),
//       ),
//       body: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: const [
//           Icon(Icons.backpack),
//           Icon(Icons.leaderboard),
//           Icon(Icons.person),
//         ],
//       ),
//     ));
//   }
// }
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.cyan[900],
          title: const Text("Tela Inicial"),
        ),
        body: Stack(
          children: [
            Container(
              color: Colors.amber[800],
              height: 100,
              width: 100,
            ),
            const Align(
              child: Icon(Icons.verified),
              alignment: Alignment.topCenter,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green[800],
          child: const Icon(Icons.add),
          onPressed: () {
            print('printing pressed...');
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
        drawer: const Drawer(
          child: Text('Salve!'),
        ),
      ),
    );
  }
}

class MySettings extends StatelessWidget {
  const MySettings({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Text(
              "Configurações",
              style: TextStyle(
                color: Color.fromRGBO(236, 179, 101, 1),
                fontSize: 42,
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    Text(
                      "Níveis de Risco:",
                      style: TextStyle(
                        color: Color.fromRGBO(236, 179, 101, 1),
                        fontSize: 28,
                      ),
                    ),
                    Icon(Icons.info_outline),
                  ],
                ),
                Container(
                  height: 30,
                  width: 100,
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(217, 217, 217, 1),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                )
              ],
            ),
          ],
        ),
        backgroundColor: Color.fromRGBO(4, 28, 50, 1),
      ),
    );
  }
}
