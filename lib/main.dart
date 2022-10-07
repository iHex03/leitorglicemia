import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main(List<String> args) {
  runApp(GlicoReader());
}

class GlicoReader extends StatefulWidget {
  @override
  State<GlicoReader> createState() => _GlicoReaderState();
}

class _GlicoReaderState extends State<GlicoReader> {
  String _data = "";
  String filePath = 'assets/data0.txt';
  List<double> hardData = [5, 6, 8, 11, 8, 13, 7, 9, 10];
  double nivelRiscoMin = 59;
  double nivelRiscoMax = 126;

  fetchFileData() async {
    String responseText;
    responseText = await rootBundle.loadString(filePath);
    setState(() {
      _data = responseText;
    });
  }

  Future<void> send() async {
    final Email email = Email(
      body: 'Email body',
      subject: 'Email subject',
      recipients: ['lecrammattos@live.com'],
    );
    String platformResponse;

    try {
      await FlutterEmailSender.send(email);
      platformResponse = 'success';
    } catch (error) {
      print(error);
      platformResponse = error.toString();
      print(platformResponse);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    fetchFileData();
    super.initState();
  }

  final _nivelRiscoMin = TextEditingController();
  final _nivelRiscoMax = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<String>? lstring = _data.split(" ");
    List<double> ldouble = lstring.map(double.parse).toList();

    double lastGlicemia = ldouble.last;
    String avisoGlicemia = 'Seus valores estão normais.';
    String warningColor = "linear-gradient(to right, #00ff80, #00ff80)";

    if (lastGlicemia <= nivelRiscoMin || lastGlicemia >= nivelRiscoMax) {
      avisoGlicemia = 'Seus valores estão críticos, notificação enviada.';
      warningColor = "linear-gradient(to right, #cd5c5c, #cd5c5c)";
      send();
    }
    void showToast() => Fluttertoast.showToast(
          msg: avisoGlicemia,
          fontSize: 36,
          backgroundColor: Colors.black,
          textColor: Colors.black,
          webPosition: "center",
          webBgColor: warningColor,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
        );

    final horarioAtual = DateTime.now();

    return MaterialApp(
      theme: ThemeData(fontFamily: 'Coolvetica'),
      home: Scaffold(
        backgroundColor: Color(0xFF041C32),
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Align(
                  alignment: AlignmentDirectional(-0.75, 0),
                  child: Text(
                    'Olá Marcel',
                    style: TextStyle(
                      color: Color.fromRGBO(236, 179, 101, 1),
                      fontSize: 32,
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(-0.75, 0),
                  child: Text(
                    'Sua glicemia está em:',
                    style: TextStyle(
                      color: Color.fromRGBO(236, 179, 101, 1),
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  lastGlicemia.toString(),
                  style: TextStyle(
                    color: Color.fromRGBO(236, 179, 101, 1),
                    fontSize: 110,
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional(0, -1),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Última leitura realizada em ',
                          style: TextStyle(
                            color: Color.fromRGBO(236, 179, 101, 1),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          horarioAtual.toString(),
                          style: TextStyle(
                            color: Color.fromRGBO(236, 179, 101, 1),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 350,
                  height: 300,
                  decoration: BoxDecoration(
                      border:
                          Border.all(color: Color.fromRGBO(236, 179, 101, 1))),
                  child: new Sparkline(
                    data: ldouble,
                    lineColor: Color.fromRGBO(236, 179, 101, 1),
                    lineWidth: 4,
                    pointsMode: PointsMode.all,
                    // pointColor: Colors.black,
                    pointSize: 8.0,
                    fillMode: FillMode.below,
                    fillColor: Color.fromRGBO(4, 41, 58, 1),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  child: Align(
                    alignment: AlignmentDirectional(0, 0),
                    // child: Container(
                    //   decoration: BoxDecoration(
                    //     border: Border.all(
                    //       color: Color.fromRGBO(236, 179, 101, 1),
                    //     ),
                    //     borderRadius: BorderRadius.all(
                    //       Radius.circular(10),
                    //     ),
                    //   ),
                    //   child: Text(
                    //     _data,
                    //     style: TextStyle(
                    //       color: Color.fromRGBO(236, 179, 101, 1),
                    //       fontSize: 32,
                    //     ),
                    //   ),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      child: Align(
                        alignment: AlignmentDirectional(-0.75, 0),
                        child: Text(
                          'Níveis de Risco',
                          style: TextStyle(
                            color: Color.fromRGBO(236, 179, 101, 1),
                            fontSize: 32,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(
                            () {
                              nivelRiscoMin = double.parse(_nivelRiscoMin.text);
                              nivelRiscoMax = double.parse(_nivelRiscoMax.text);
                              print(nivelRiscoMin);
                              print(nivelRiscoMax);
                            },
                          );
                          Fluttertoast.showToast(
                            msg: 'Níveis de Risco salvos.',
                            fontSize: 36,
                            backgroundColor: Colors.black,
                            textColor: Colors.black,
                            webPosition: "center",
                            webBgColor:
                                "linear-gradient(to right, #00ff80, #00ff80)",
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 2,
                          );
                        },
                        child: const Text(
                          'Salvar',
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 32,
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
                    )
                  ],
                ),
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional(0, 0),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      width: 400,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(255, 255, 255, 0),
                        shape: BoxShape.rectangle,
                      ),
                      alignment: AlignmentDirectional(0, 0),
                      child: Align(
                        alignment: AlignmentDirectional(0, 0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: AlignmentDirectional(0, 0),
                                      child: Text(
                                        'Mínimo',
                                        style: TextStyle(
                                          color:
                                              Color.fromRGBO(236, 179, 101, 1),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: AlignmentDirectional(0, 0),
                                      child: Text(
                                        'Máximo',
                                        style: TextStyle(
                                          color:
                                              Color.fromRGBO(236, 179, 101, 1),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Align(
                                alignment: AlignmentDirectional(0, 0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Align(
                                        alignment: AlignmentDirectional(0, 0),
                                        child: Container(
                                          width: 120,
                                          child: TextFormField(
                                            controller: _nivelRiscoMin,
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              hintText: '60',
                                              // hintStyle:,
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 0),
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 0),
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              errorBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color.fromRGBO(
                                                      255, 0, 0, 1),
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              focusedErrorBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color.fromRGBO(
                                                      255, 0, 0, 1),
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              filled: true,
                                              fillColor: Color(0xFFD9D9D9),
                                            ),
                                            // style: ,
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: AlignmentDirectional(0, 0),
                                        child: Container(
                                          width: 120,
                                          child: TextFormField(
                                            controller: _nivelRiscoMax,
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              hintText: '126',
                                              // hintStyle:,
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              errorBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color.fromRGBO(
                                                      255, 0, 0, 1),
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              focusedErrorBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color.fromRGBO(
                                                      255, 0, 0, 1),
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              filled: true,
                                              fillColor: Color.fromRGBO(
                                                  217, 217, 217, 1),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(5, 20, 5, 20),
                      child: Align(
                        alignment: AlignmentDirectional(0, 0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(
                              () {
                                filePath = 'assets/data1.txt';
                                fetchFileData();
                              },
                            );
                          },
                          child: const Text(
                            'Caso 1',
                            style: TextStyle(
                              color: Color.fromRGBO(236, 179, 101, 1),
                              fontSize: 28,
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
                            setState(
                              () {
                                filePath = 'assets/data2.txt';
                                fetchFileData();
                              },
                            );
                          },
                          child: const Text(
                            'Caso 2',
                            style: TextStyle(
                              color: Color.fromRGBO(236, 179, 101, 1),
                              fontSize: 28,
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
                            setState(
                              () {
                                filePath = 'assets/data3.txt';
                                fetchFileData();
                              },
                            );
                          },
                          child: const Text(
                            'Caso 3',
                            style: TextStyle(
                              color: Color.fromRGBO(236, 179, 101, 1),
                              fontSize: 28,
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}