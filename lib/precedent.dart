import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mrz_scanner/flutter_mrz_scanner.dart';
import 'package:mrz_parser/src/mrz_result.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scanner App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QRScanPage(),
    );
  }
}

class QRScanPage extends StatefulWidget {
  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'READID',
              style: TextStyle(
                color: Colors.purple,
              ),
            ),
            Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'NFC Passport Reader',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StepCircle(
                  isActive: true, // État de l'étape "Scan"
                  label: 'ScanQr',
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 500), // Durée de l'animation
                  width: 60,
                  height: 2,
                  color: Colors.grey, // Couleur de la ligne
                ),
                StepCircle(
                  isActive: false, // État de l'étape "Info"
                  label: 'ScanMr',
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 500), // Durée de l'animation
                  width: 60,
                  height: 2,
                  color: Colors.grey, // Couleur de la ligne
                ),
                StepCircle(
                  isActive: false, // État de l'étape "Scan"
                  label: 'ReadNfc',
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 500), // Durée de l'animation
                  width: 60,
                  height: 2,
                  color: Colors.grey, // Couleur de la ligne
                ),
                StepCircle(
                  isActive: false, // État de l'étape "Scan"
                  label: 'Result',
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Text(
                  "A scanner is a versatile tool that digitally captures information from various sources such as documents, images, and barcodes. It plays a crucial role in converting physical data into digital formats, facilitating efficient storage, processing, and retrieval of information. Whether it's scanning documents for archiving, capturing images for analysis, or reading barcodes for inventory management, scanners enhance productivity and streamline workflows across diverse industries.",
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QRScanCamera()),
                    );
                  },
                  child: Text('Scanner Qr code '),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QRScanCamera extends StatefulWidget {
  @override
  _QRScanCameraState createState() => _QRScanCameraState();
}

class _QRScanCameraState extends State<QRScanCamera> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;
  String qrText = '';
  bool isFlashOn = false; // Ajoutez une variable pour suivre l'état du flash

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed:
                        _toggleFlash, // Ajoutez un bouton pour activer/désactiver le flash
                    child: Text(
                        isFlashOn ? 'Éteindre le flash' : 'Allumer le flash'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData.code ?? "rien ";
        _showQRData(context, qrText);
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    setState(() {
      isFlashOn = !isFlashOn; // Inversez l'état du flash
    });
    controller
        .toggleFlash(); // Utilisez la méthode de contrôle intégrée du flash
  }

  void _showQRData(BuildContext context, String data) {
    // Interpréter les données JSON
    try {
      Map<String, dynamic> userData = jsonDecode(data);
      String nameQr = userData['name'];
      String lastNameQr = userData['lastName'];
      String idQr = userData['cin'];

      // Afficher les détails de l'utilisateur dans une boîte de dialogue
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Détails de l\'utilisateur'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('name: $nameQr'),
                Text('lastname: $lastNameQr'),
                Text('Id: $idQr'),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DescriptionScreen(
                              nameQr: nameQr,
                              lastNameQr: lastNameQr,
                              idQr: idQr,
                              
                            )),
                  );
                },
                child: Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Annuler'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Erreur lors de l\'interprétation des données JSON: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur lors de l\'interprétation des données JSON.'),
      ));
    }
  }
}

class StepCircle extends StatelessWidget {
  final bool isActive;
  final String label;

  StepCircle({required this.isActive, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? Colors.purple
            : Colors.grey, // Couleur violette si l'étape est active
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 4),
        ),
      ),
    );
  }
}

class DescriptionScreen extends StatefulWidget {
  final String nameQr;
  final String lastNameQr;
  final String idQr;

  DescriptionScreen({
    required this.nameQr,
    required this.lastNameQr,
    required this.idQr,
  });

  @override
  _DescriptionScreenState createState() => _DescriptionScreenState();
}

class _DescriptionScreenState extends State<DescriptionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner App'),
      ),
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(vertical: 20),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              StepCircle(
                isActive: true, // État de l'étape "Scan"
                label: 'ScanQr',
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 500), // Durée de l'animation
                width: 60,
                height: 2,
                color: Colors.purple, // Couleur de la ligne
              ),
              StepCircle(
                isActive: true, // État de l'étape "Info"
                label: 'ScanMr',
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 500), // Durée de l'animation
                width: 60,
                height: 2,
                color: Colors.grey, // Couleur de la ligne
              ),
              StepCircle(
                isActive: false, // État de l'étape "Scan"
                label: 'ReadNfc',
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 500), // Durée de l'animation
                width: 60,
                height: 2,
                color: Colors.grey, // Couleur de la ligne
              ),
              StepCircle(
                isActive: false, // État de l'étape "Scan"
                label: 'Result',
              ),
            ]),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Text(
                  "A scanner is a versatile tool that digitally captures information from various sources such as documents, images, and barcodes. It plays a crucial role in converting physical data into digital formats, facilitating efficient storage, processing, and retrieval of information. Whether it's scanning documents for archiving, capturing images for analysis, or reading barcodes for inventory management, scanners enhance productivity and streamline workflows across diverse industries.",
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    requestCameraPermission(
                        context); // Ouvrir la caméra lorsque le bouton "Scanner Cart ID" est pressé
                  },
                  child: Text('Scanner Cart ID'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    requestCameraPermission(context);
                  },
                  child: Text('Scanner Passport'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void requestCameraPermission(BuildContext context) async {
    var status = await Permission.camera.status;
    if (status.isGranted) {
      // L'autorisation est déjà accordée
      openMRZScanner(context);
    } else {
      if (status.isDenied || status.isPermanentlyDenied) {
        // L'utilisateur a refusé l'autorisation précédemment, vous pouvez lui montrer un message expliquant pourquoi l'autorisation est nécessaire
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Camera permission is required to use the MRZ scanner.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () {
              openAppSettings();
            },
          ),
        ));
      }
      // Demandez à l'utilisateur d'accorder l'autorisation
      status = await Permission.camera.request();
      if (status.isGranted) {
        // L'autorisation a été accordée
        openMRZScanner(context);
      }
    }
  }

  void openMRZScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MRZScannerScreen(
                nameQr: widget.nameQr,
                lastNameQr: widget.lastNameQr,
                idQr: widget.idQr,
              )),
    );
  }
}

class MRZScannerScreen extends StatefulWidget {
  final String nameQr;
  final String lastNameQr;
  final String idQr;

  MRZScannerScreen({
    required this.nameQr,
    required this.lastNameQr,
    required this.idQr,
  });

  @override
  _MRZScannerScreenState createState() => _MRZScannerScreenState();
}

class _MRZScannerScreenState extends State<MRZScannerScreen> {
  late MRZController controller;
  bool isFlashOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MRZ Scanner'),
      ),
      body: Stack(
        children: [
          Center(
            child: Stack(
              children: [
                MRZScanner(
                  withOverlay: true,
                  onControllerCreated: (ctrl) {
                    onControllerCreated(ctrl, context);
                  },
                ),
                Positioned(
                  bottom: 290,
                  left: 50,
                  right: 50,
                  child: Row(
                    children: List.generate(
                      30,
                      (index) => Expanded(
                        child: Text(
                          '<',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 270,
                  left: 50,
                  right: 50,
                  child: Row(
                    children: List.generate(
                      30,
                      (index) => Expanded(
                        child: Text(
                          '<',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 250,
                  left: 50,
                  right: 50,
                  child: Row(
                    children: List.generate(
                      30,
                      (index) => Expanded(
                        child: Text(
                          '<',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50, left: 10, right: 10),
              child: Text(
                'Placez votre carte d\'identité de manière à ce que le MRZ soit visible à l\'écran',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: _toggleFlash,
              child: Text(isFlashOn ? 'Éteindre le flash' : 'Allumer le flash'),
            ),
          ),
        ],
      ),
    );
  }

  void onControllerCreated(MRZController controller, BuildContext context) {
    controller.onParsed = (mrzResult) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MRZResultPage(
            mrzResult: mrzResult,
            nameQr: widget.nameQr,
            lastNameQr: widget.lastNameQr,
            idQr: widget.idQr,
          ),
        ),
      );
    };

    controller.onError = (error) {
      print('MRZ Scanner Error: $error');
    };
  }

void _toggleFlash() {
  setState(() {
    isFlashOn = !isFlashOn;
  });
  
  if (isFlashOn) {
    controller.flashlightOn();
  } else {
    controller.flashlightOff();
  }
}
}


class MRZResultPage extends StatelessWidget {
  final MRZResult mrzResult;
  final String nameQr;
  final String lastNameQr;
  final String idQr;

  MRZResultPage({
    required this.mrzResult,
    required this.nameQr,
    required this.lastNameQr,
    required this.idQr,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MRZ Result'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('First Name: ${mrzResult.givenNames}'),
            Text('Last Name: ${mrzResult.surnames}'),
            Text('Id: ${mrzResult.personalNumber}'),
            Text('documentNumber: ${mrzResult.documentNumber}'),
            Text('First Name qr: ${nameQr}'),
            Text('Last Name qr: ${lastNameQr}'),
            Text('Id qr: ${idQr}'),
            SizedBox(height: 20), // Espacement entre le texte et le bouton
            ElevatedButton(
              onPressed: () {
                validatedatat(context);
              },
              child: Text('Valider les donnes'),
            ),
          ],
        ),
      ),
    );
  }

  void validatedatat(BuildContext context) {
    if (mrzResult.givenNames.toLowerCase() == nameQr.toLowerCase() &&
        mrzResult.surnames.toLowerCase() == lastNameQr.toLowerCase() &&
        mrzResult.personalNumber.toLowerCase() == idQr.toLowerCase()) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("valide"),
            content: Text("les donnes est valide a mrz valider le NFC"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NfcScannerPage(
                              mrzResult: mrzResult,
                              nameQr: nameQr,
                              lastNameQr: lastNameQr,
                              idQr: idQr,
                              
                            )),
                  ); // Ferme la boîte de dialogue
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("pas valider"),
            content: Text("les donnes pas valider tester a nouvaus"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MRZScannerScreen(
                              nameQr: nameQr,
                              lastNameQr: lastNameQr,
                              idQr: idQr,
                              
                            )),
                  );
                },
                child: Text("Retour"),
              ),
            ],
          );
        },
      );
    }
  }
}

class NfcScannerPage extends StatefulWidget {
  final MRZResult mrzResult;
  final String nameQr;
  final String lastNameQr;
  final String idQr;

  NfcScannerPage({
    required this.mrzResult,
    required this.nameQr,
    required this.lastNameQr,
    required this.idQr,
  });
  @override
  _NfcScannerPageState createState() => _NfcScannerPageState();
}

class _NfcScannerPageState extends State<NfcScannerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner App'),
      ),
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(vertical: 20),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              StepCircle(
                isActive: true, // État de l'étape "Scan"
                label: 'ScanQr',
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 500), // Durée de l'animation
                width: 60,
                height: 2,
                color: Colors.purple, // Couleur de la ligne
              ),
              StepCircle(
                isActive: true, // État de l'étape "Info"
                label: 'ScanMr',
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 500), // Durée de l'animation
                width: 60,
                height: 2,
                color: Colors.purple, // Couleur de la ligne
              ),
              StepCircle(
                isActive: true, // État de l'étape "Scan"
                label: 'ReadNfc',
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 500), // Durée de l'animation
                width: 60,
                height: 2,
                color: Colors.grey, // Couleur de la ligne
              ),
              StepCircle(
                isActive: false, // État de l'étape "Scan"
                label: 'Result',
              ),
            ]),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Text(
                  "Hello mr ${widget.nameQr} ${widget.lastNameQr} please get your cart id in back of your phone for detecte you NFC information",
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Scanner NFC'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
