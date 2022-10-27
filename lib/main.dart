import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(fontFamily: 'Coolvetica'),
    home: GlicoReader(),
  ));
}

Future sendEmail(String emailEmergencia) async {
  final serviceId = 'service_vml9rlx';
  final templateId = 'template_yr2l02b';
  final userId = 'xd79Ru_YBA-fqlkxD';

  final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
  final response = await http.post(url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {
          'to_email': emailEmergencia,
          'user_name': 'GlicoReader',
          'user_email': 'dev.mmattos@gmail.com',
          'user_subject': 'Níveis Críticos de Glicose de Marcel',
          'user_message':
              'Marcel atingiu um valor crítico de glicose, entre em contato para checar sua saúde!',
        }
      }));

  print(response.body);
  print('Email enviado para $emailEmergencia');
}

class GlicoReader extends StatefulWidget {
  @override
  State<GlicoReader> createState() => _GlicoReaderState();
}

String _data = "0 0 0 0 0 0 0 0 0 0 0 0 0 0";
String filePath = 'assets/data1.txt';
double nivelRiscoMin = 59;
double nivelRiscoMax = 126;
String emailEmergencia = 'lecrammattos@live.com';
String nomeUsuario = 'Marcel';
var ultimaHora = '00:00';
var ultimaData = '1/1/99';
final _nivelRiscoMin = TextEditingController();
final _nivelRiscoMax = TextEditingController();
final _emailEmergencia = TextEditingController();
final _nomeUsuario = TextEditingController();

int counterGrafico = 0;
void desenhaGrafico() {
  if (counterGrafico >= 9) {
    counterGrafico = 0;
  } else {
    counterGrafico++;
  }
  ultimaHora = DateFormat('HH:mm:ss').format(DateTime.now()).toString();
  ultimaData = DateFormat('dd/MM/yy').format(DateTime.now()).toString();
  bluetooth();
}

void bluetooth() async{

try {
    BluetoothConnection connection = await BluetoothConnection.toAddress("98:DA:C0:00:2A:92");
    print('Connected to the device');

    connection.input?.listen((Uint8List data) {
        print('Data incoming: ${ascii.decode(data)}');
        connection.output.add(data); // Sending data

        if (ascii.decode(data).contains('!')) {
            connection.finish(); // Closing connection
            print('Disconnecting by local host');
        }
    }).onDone(() {
        print('Disconnected by remote request');
    });


}
catch (exception) {
    print('Cannot connect, exception occured');
}

}

class _GlicoReaderState extends State<GlicoReader> {
  fetchFileData() async {
    String responseText;
    responseText = await rootBundle.loadString(filePath);
    setState(() {
      _data = responseText;
    });
  }

  @override
  void initState() {
    fetchFileData();
    super.initState();
    const time = Duration(seconds: 10);
    Timer.periodic(
        time,
        (Timer t) => setState(() {
              desenhaGrafico();
            }));
  }

  @override
  Widget build(BuildContext context) {
    // void serialReader() async
    // {
    // var status = await Permission.storage.status;
    //               if (!status.isGranted) {
    //                 await Permission.storage.request();
    //               }
    // List<String> availablePort = SerialPort.availablePorts;
    // print('Available Ports: $availablePort');

    // SerialPort port1 = SerialPort('COM4');
    // port1.openReadWrite();

    // try {
    //   print(port1.write(_stringToUint8List('hello')));
    // } on SerialPortError catch (err, _) {
    //   print(SerialPort.lastError);
    // }
    // }
    // serialReader();
Timer.periodic(
        Duration(seconds: 5),
        (Timer t) => setState(() {
              bluetooth();
            }));
        fetchFileData();

    List<String>? lstring = _data.split(" ");
    List<double> ldouble = lstring.map(double.parse).toList();

    List<double> novoGrafico =
        ldouble.sublist(counterGrafico, counterGrafico + 5);
    novoGrafico.removeAt(0);
    novoGrafico.add(novoGrafico.last);

    double lastGlicemia = novoGrafico.last;
    String avisoGlicemia = 'Seus valores estão normais.';
    String warningColor = "linear-gradient(to right, #00ff80, #00ff80)";
    int warningColorHex = 0xFF00FF80;

    if (lastGlicemia <= nivelRiscoMin || lastGlicemia >= nivelRiscoMax) {
      avisoGlicemia = 'Seus valores estão críticos, notificação enviada.';
      warningColor = "linear-gradient(to right, #cd5c5c, #cd5c5c)";
      warningColorHex = 0xFFCD5C5C;
    }
    void showToast() {
      Fluttertoast.showToast(
        msg: avisoGlicemia,
        fontSize: 16,
        backgroundColor: Color(warningColorHex),
        textColor: Colors.black,
        webPosition: "center",
        webBgColor: warningColor,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
      );
      if (lastGlicemia <= nivelRiscoMin || lastGlicemia >= nivelRiscoMax) {
        // sendEmail(emailEmergencia);
      }
    }

    return Scaffold(
      backgroundColor: Color(0xFF041C32),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional(-0.75, 0),
                child: Text(
                  'Olá $nomeUsuario, sua glicemia atual é:',
                  style: TextStyle(
                    color: Color.fromRGBO(236, 179, 101, 1),
                    fontSize: 24,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    lastGlicemia.toInt().toString(),
                    style: TextStyle(
                      color: Color.fromRGBO(236, 179, 101, 1),
                      fontSize: 72,
                    ),
                  ),
                  Text(
                    'mg/dL',
                    style: TextStyle(
                      color: Color.fromRGBO(236, 179, 101, 1),
                      fontSize: 16,
                      height: 5,
                    ),
                  ),
                ],
              ),
              Container(
                child: Text(
                  'Última leitura realizada em $ultimaData às $ultimaHora',
                  style: TextStyle(
                    color: Color.fromRGBO(236, 179, 101, 1),
                    fontSize: 18,
                  ),
                ),
              ),
              GraphBuilder(novoGrafico: novoGrafico),
              Container(
                child: Align(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // desenhaGrafico();
                        showToast();
                      });
                    },
                    child: const Text(
                      'Leitura Rápida',
                      style: TextStyle(
                        color: Color.fromRGBO(236, 179, 101, 1),
                        fontSize: 32,
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Color.fromRGBO(4, 41, 58, 0)),
                      overlayColor: MaterialStateProperty.all(
                          Color.fromRGBO(4, 41, 58, 1)),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                child: Align(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    width: 400,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 255, 255, 0),
                      shape: BoxShape.rectangle,
                    ),
                    child: Align(
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: ElevatedButton(
                                child: const Text(
                                  'Configurações',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 20,
                                  ),
                                ),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Color.fromRGBO(236, 179, 101, 1)),
                                  overlayColor: MaterialStateProperty.all(
                                      Color.fromRGBO(4, 41, 58, 1)),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (settingContext) =>
                                            const _Settings()),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Uint8List _stringToUint8List(String data) {
//   List<int> codeUnits = data.codeUnits;
//   Uint8List uint8list = Uint8List.fromList(codeUnits);
//   return uint8list;
// }

class _Settings extends StatelessWidget {
  const _Settings({super.key});

  @override
  Widget build(BuildContext settingContext) {
    return Scaffold(
      backgroundColor: Color(0xFF041C32),
      body: Align(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(5, 20, 5, 20),
                  child: Align(
                    alignment: AlignmentDirectional(0, 0),
                    child: ElevatedButton(
                      onPressed: () {
                        filePath = 'assets/data1.txt';
                        print(filePath);
                      },
                      child: const Text(
                        'Caso 1',
                        style: TextStyle(
                          color: Color.fromRGBO(236, 179, 101, 1),
                          fontSize: 20,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromRGBO(4, 41, 58, 0)),
                        overlayColor: MaterialStateProperty.all(
                            Color.fromRGBO(4, 41, 58, 1)),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(5, 20, 5, 20),
                  child: Align(
                    alignment: AlignmentDirectional(0, 0),
                    child: ElevatedButton(
                      onPressed: () {
                        filePath = 'assets/data2.txt';
                        print(filePath);
                      },
                      child: const Text(
                        'Caso 2',
                        style: TextStyle(
                          color: Color.fromRGBO(236, 179, 101, 1),
                          fontSize: 20,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromRGBO(4, 41, 58, 0)),
                        overlayColor: MaterialStateProperty.all(
                            Color.fromRGBO(4, 41, 58, 1)),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(5, 20, 5, 20),
                  child: Align(
                    alignment: AlignmentDirectional(0, 0),
                    child: ElevatedButton(
                      onPressed: () {
                        filePath = 'assets/data3.txt';
                        print(filePath);
                      },
                      child: const Text(
                        'Caso 3',
                        style: TextStyle(
                          color: Color.fromRGBO(236, 179, 101, 1),
                          fontSize: 20,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromRGBO(4, 41, 58, 0)),
                        overlayColor: MaterialStateProperty.all(
                            Color.fromRGBO(4, 41, 58, 1)),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              child: Text(
                'Níveis de Risco',
                style: TextStyle(
                  color: Color.fromRGBO(236, 179, 101, 1),
                  fontSize: 24,
                ),
              ),
            ),
            Container(
              child: Align(
                child: Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  width: 400,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0),
                    shape: BoxShape.rectangle,
                  ),
                  child: Align(
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Align(
                                  child: Text(
                                    'Mínimo',
                                    style: TextStyle(
                                      color: Color.fromRGBO(236, 179, 101, 1),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Align(
                                  child: Text(
                                    'Máximo',
                                    style: TextStyle(
                                      color: Color.fromRGBO(236, 179, 101, 1),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Align(
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Align(
                                    child: Container(
                                      width: 100,
                                      child: TextFormField(
                                        controller: _nivelRiscoMin,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          hintText: '60',
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color.fromRGBO(0, 0, 0, 0),
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color.fromRGBO(0, 0, 0, 0),
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          errorBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  Color.fromRGBO(255, 0, 0, 1),
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          focusedErrorBorder:
                                              UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  Color.fromRGBO(255, 0, 0, 1),
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          filled: true,
                                          fillColor: Color(0xFFD9D9D9),
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    child: Container(
                                      width: 100,
                                      child: TextFormField(
                                        controller: _nivelRiscoMax,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          hintText: '126',
                                          // hintStyle:,
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0x00000000),
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0x00000000),
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          errorBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  Color.fromRGBO(255, 0, 0, 1),
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          focusedErrorBorder:
                                              UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  Color.fromRGBO(255, 0, 0, 1),
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          filled: true,
                                          fillColor:
                                              Color.fromRGBO(217, 217, 217, 1),
                                        ),
                                        // style: ,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              child: Text(
                'Contato de Emergência',
                style: TextStyle(
                  color: Color.fromRGBO(236, 179, 101, 1),
                  fontSize: 24,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
              child: Container(
                width: 300,
                child: TextFormField(
                  controller: _emailEmergencia,
                  obscureText: false,
                  decoration: InputDecoration(
                    hintText: 'contato@email.com',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0x00000000),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0x00000000),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    errorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromRGBO(255, 0, 0, 1),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    focusedErrorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromRGBO(255, 0, 0, 1),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    filled: true,
                    fillColor: Color.fromRGBO(217, 217, 217, 1),
                  ),
                  // style: ,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            ),
            Container(
              child: Text(
                'Nome do Usuário',
                style: TextStyle(
                  color: Color.fromRGBO(236, 179, 101, 1),
                  fontSize: 24,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
              child: Container(
                width: 300,
                child: TextFormField(
                  controller: _nomeUsuario,
                  obscureText: false,
                  decoration: InputDecoration(
                    hintText: 'Insira seu nome aqui',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0x00000000),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0x00000000),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    errorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromRGBO(255, 0, 0, 1),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    focusedErrorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromRGBO(255, 0, 0, 1),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    filled: true,
                    fillColor: Color.fromRGBO(217, 217, 217, 1),
                  ),
                  // style: ,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        nivelRiscoMin = double.parse(_nivelRiscoMin.text);
                        nivelRiscoMax = double.parse(_nivelRiscoMax.text);
                        emailEmergencia = _emailEmergencia.text;
                        nomeUsuario = _nomeUsuario.text;
                        print(nivelRiscoMin);
                        print(nivelRiscoMax);
                        print(emailEmergencia);
                        print(nomeUsuario);
                        Fluttertoast.showToast(
                          msg: 'Suas configurações foram salvas.',
                          fontSize: 16,
                          backgroundColor: Color(0xFF00FF80),
                          textColor: Colors.black,
                          webPosition: "center",
                          webBgColor:
                              "linear-gradient(to right, #00ff80, #00ff80)",
                          gravity: ToastGravity.TOP,
                          timeInSecForIosWeb: 2,
                        );
                      },
                      child: const Text(
                        'Salvar Configurações',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 24,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromRGBO(236, 179, 101, 1)),
                        overlayColor: MaterialStateProperty.all(
                            Color.fromRGBO(4, 41, 58, 1)),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        print(filePath);

                        Navigator.pop(settingContext);
                        print(filePath);
                        print(emailEmergencia);
                      },
                      child: const Text(
                        '< Início',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 36,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromRGBO(236, 179, 101, 1)),
                        overlayColor: MaterialStateProperty.all(
                            Color.fromRGBO(4, 41, 58, 1)),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GraphBuilder extends StatelessWidget {
  const GraphBuilder({
    Key? key,
    required this.novoGrafico,
  }) : super(key: key);

  final List<double> novoGrafico;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 300,
      decoration: BoxDecoration(
          border: Border.all(color: Color.fromRGBO(236, 179, 101, 1))),
      child: new Sparkline(
        data: novoGrafico,
        lineColor: Color.fromRGBO(236, 179, 101, 1),
        lineWidth: 4,
        // pointsMode: PointsMode.all,
        // pointSize: 8.0,
        // fillMode: FillMode.below,
        // fillColor: Color.fromRGBO(4, 41, 58, 1),
        enableGridLines: true,
      ),
    );
  }
}
