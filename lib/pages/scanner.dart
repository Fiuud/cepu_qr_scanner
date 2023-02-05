import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScannerPage extends StatefulWidget {
  const ScannerPage({Key? key, required this.login, required this.password})
      : super(key: key);

  final String login;
  final String password;

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  MobileScannerController cameraController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mobile Scanner"),
        actions: [
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state as TorchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state as CameraFacing) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
        allowDuplicates: false,
        controller: cameraController,
        onDetect: _foundBarcode,
      ),
    );
  }

  void _foundBarcode(Barcode barcode, MobileScannerArguments? args) {
    /// get scan data
    final String code = barcode.rawValue ?? "---";
    debugPrint('Barcode found! $code');
    qrData(code, widget.login, widget.password);
  }

  qrData(String code, String login, String password) async {
    String basicAuth = 'Basic ${base64.encode(utf8.encode('$login:$password'))}';
    final uri = Uri.https('rabotyagi1.pythonanywhere.com', '/check/qr');
    final msg = jsonEncode(<String, dynamic>{
      'qr_data': code,
      'lecture_room': login
    });
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'authorization': basicAuth,
    };

    http.Response response = await http.post(
      uri,
      headers: headers,
      body: msg,
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(jsonResponse['status'])));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Непредвиденная ошибка, попробуйте ещё раз.')));
    }
  }
}
