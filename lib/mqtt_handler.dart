import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttHandler with ChangeNotifier {
  final ValueNotifier<String> data = ValueNotifier<String>("");
  late MqttServerClient client;
  // ---------------------- Required for connection to Mqtt
  final String subscribeTopic =
      "your_subscribe_topic"; // Replace with your MQTT topic for subscribing
  // for setting address of broker
  final String broker =
      "a3u11m5yzl0ti8-ats.iot.ap-south-1.amazonaws.com"; // Replace with your AWS IoT endpoint
  final int port = 8883; // AWS IoT MQTT port
  final String clientId = 'aws_flutter'; // Choose a unique client ID
  final String topic =
      'Test'; // Replace with the topic you want to publish to

  Future<bool> connect() async {
    client = MqttServerClient.withPort(broker, clientId, port);
    ByteData rootCA = await rootBundle.
    load('assets/certificates/AmazonRootCA1 (1).pem');
    ByteData deviceCert =
    await rootBundle.load('assets/certificates/9fa8169204f774d5b5dd9046cb2ff9a6762e261dd569f069177c5b136f16e9ea-certificate.pem.crt');
    ByteData privateKey = await rootBundle.
    load('assets/certificates/9fa8169204f774d5b5dd9046cb2ff9a6762e261dd569f069177c5b136f16e9ea-private.pem.key');

    SecurityContext context = SecurityContext.defaultContext;
    context.setClientAuthoritiesBytes(rootCA.buffer.asUint8List());
    context.useCertificateChainBytes(deviceCert.buffer.asUint8List());
    context.usePrivateKeyBytes(privateKey.buffer.asUint8List());
    client.securityContext = context;

    client.logging(on: true);
    client.keepAlivePeriod = 20;
    client.port = 8883;
    client.secure = true;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.pongCallback = pong;

    final MqttConnectMessage connMess =
    MqttConnectMessage().withClientIdentifier(clientId).startClean();
    client.connectionMessage = connMess;
    await client.connect();
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print("Connected to AWS Successfully!");
    } else {
      return false;
    }
    topic;
    client.subscribe(topic, MqttQos.atMostOnce);

    //-------------- code dor suscribing a topic ------------------------------//

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      data.value = pt;
      print(
          'MQTT_LOGS:: New data arrived: topic is <${c[0].topic}>, payload is $pt');
      print('');
    });
    return true;
  }

  // fpr check the connectivity

  bool isConnected() {
    return client.connectionStatus!.state == MqttConnectionState.connected;
  }
  void onConnected() {
    print('MQTT_LOGS:: Connected');
  }


  void onDisconnected() {
    print('MQTT_LOGS:: Disconnected');
  }

  void onSubscribed(String topic) {
    print('MQTT_LOGS:: Subscribed topic: $topic');
  }

  void onSubscribeFail(String topic) {
    print('MQTT_LOGS:: Failed to subscribe $topic');
  }

  void onUnsubscribed(String? topic) {
    print('MQTT_LOGS:: Unsubscribed topic: $topic');
  }

  void pong() {
    print('MQTT_LOGS:: Ping response client callback invoked');
  }

  // ----------------------------- Publishing a message ------------------------------------------------
  void publishMessage(TextEditingController txtController) {
    topic;
    final builder = MqttClientPayloadBuilder();
    String message = txtController.text;
    builder.addString(message);
    if ( client != null && client.connectionStatus?.state == MqttConnectionState.connected) {
      print('Published to topic: $topic, Message: $message');
      client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
    }
  }
}
