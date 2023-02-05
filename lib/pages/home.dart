import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scanner2/pages/scanner.dart';
import 'dart:convert';

class MyHome extends StatefulWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: <Widget>[
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'CepuScanner',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        fontSize: 30),
                  )),
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'Авторизация',
                    style: TextStyle(fontSize: 20),
                  )),
              Container(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Кабинет',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: TextField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Пароль',
                  ),
                ),
              ),
              ElevatedButton(
                child: const Text('Войти'),
                onPressed: () {
                  checkAccount(nameController.text, passwordController.text);
                },
              ),
            ],
          )),
    );
  }

  checkAccount(String login, String password) async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: Colors.black,
                )),
          );
        });
    final uri = Uri.https('rabotyagi1.pythonanywhere.com', '/log');
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'authorization': 'Basic ${base64Encode(utf8.encode('$login:$password'))}',
    };

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    // print(jsonDecode(response.body));
    debugPrint(response.body.toString());

    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ScannerPage(login: login, password: password)));
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Кабинет или пароль неверный.')));
    }
  }
}