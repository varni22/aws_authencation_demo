import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'mqtt_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:  false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  MqttHandler mqttHandler = MqttHandler();
  final textEditController = TextEditingController();
 String _errorText = "";
  // String pubTopic = 'Morning Message ';
  //
  // late MqttServerClient client;
  // final String broker = 'mqtt.eclipse.org'; // Replace with your MQTT broker address
  // final int port = 1883; // Replace with your MQTT broker port
  // final String topic = 'mqtt_flutter_topic'; // Replace with your desired topic
  void _validateTextField() {
    setState(() {
      if (textEditController.text.isEmpty) {
        _errorText = "Field cannot be empty";
      } else {
        _errorText = "";
        // Perform action or send a message here
        print("Message sent: ${textEditController.text}");
      }
    });
  }

  // void _publishMessage() {
  //   if (client != null && client.connectionStatus?.state == MqttConnectionState.connected) {
  //     String message = textEditController.text;
  //     final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
  //     builder.addString(message);
  //     client.publishMessage(pubTopic, MqttQos.atMostOnce, builder.payload!);
  //     print('Published to topic: $topic, Message: $message');
  //   } else {
  //     print('Not connected to broker');
  //   }
  // }
  @override
  void initState() {
    super.initState();
    mqttHandler.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Varni Digital'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Data received:',
                style: TextStyle(color: Colors.black, fontSize: 25)),
            ValueListenableBuilder<String>(
                valueListenable: mqttHandler.data,
              builder: (BuildContext context, String value, Widget? child) {
                return Column(
                  children: <Widget>[
                    Text('$value',
                        style: TextStyle(
                            color: Colors.deepPurpleAccent, fontSize: 25.0)),
                  SizedBox(height: 10.0,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: TextField(
                        controller: textEditController,
                        decoration: InputDecoration(
                          labelText: 'Send a Message',
                          labelStyle: TextStyle(color: Colors.grey),
                          errorText: _errorText,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                      //  field validation
                        _validateTextField;
                        // for publishing data to server
                        mqttHandler.publishMessage(textEditController);
                      // for clear data
                        textEditController.clear();
                      },
                      child: Text("Send",
                style: TextStyle(
                color: Colors.white, fontSize: 16.0)),
                 style: ElevatedButton.styleFrom(
                primary: Colors.black, // Change this color to your desired color
                    ),
                    )
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }

    @override
    void dispose() {
     mqttHandler. client.disconnect();
      super.dispose();
    }
}

