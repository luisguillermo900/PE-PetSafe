import 'dart:convert';
import 'dart:io';

import 'package:lab04/services/aws_iot_core_config.dart';
import 'package:lab04/services/core/model/formatted_data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab04/viewmodels/dispositivos_notifier.dart';
import 'package:lab04/viewmodels/sensores_notifier.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

part 'aws_iot_event.dart';
part 'aws_iot_state.dart';

class AwsIotBloc extends Bloc<AwsIotEvent, AwsIotState> {
  final SensoresNotifier sensoresNotifier;
  final DispositivosNotifier dispositivosNotifier;
  final MqttServerClient _client =
      MqttServerClient(AwsIotCoreConfig.endpoint, "");

  static const int maxMessages = 10;
  final List<String> _messages = [];

  AwsIotBloc({required this.sensoresNotifier, required this.dispositivosNotifier}) : super(AwsIotInitial()) {
    on<AwsIotConnect>(_onConnect);
    on<AwsIotSendMessage>(_onSendMessage);
    on<AwsIotDataReceivedEvent>(
        (event, emit) => _onDataComming(event.payload, event.topic, emit));
    on<AwsIotSendFormattedMessage>(
        (event, emit) => _onSendFormattedMessage(event.formattedData, emit));
  }

  /// Connect to AWS IoT, all the configuration is in [AwsIotCoreConfig]
  /// But be careful, this just demo, in production, you should never hardcode
  /// the credentials in the code.
  Future<void> _onConnect(
      AwsIotConnect event, Emitter<AwsIotState> emit) async {
    try {
      debugPrint('Connecting to AWS IoT...');
      emit(AwsIotConnecting());
      ByteData rootCA = await rootBundle.load(AwsIotCoreConfig.caPath);
      ByteData deviceCerts = await rootBundle.load(AwsIotCoreConfig.certPath);
      ByteData privateKey = await rootBundle.load(AwsIotCoreConfig.keyPath);

      SecurityContext context = SecurityContext.defaultContext;
      context.setClientAuthoritiesBytes(rootCA.buffer.asUint8List());
      context.useCertificateChainBytes(deviceCerts.buffer.asUint8List());
      context.usePrivateKeyBytes(privateKey.buffer.asUint8List());

      _client.securityContext = context;
      _client.logging(on: true);
      _client.keepAlivePeriod = AwsIotCoreConfig.keepAlivePeriod;
      _client.port = AwsIotCoreConfig.port;
      _client.secure = true;

      _client.onConnected = () {
        _handleOnConnected(emit);
      };

      final MqttConnectMessage connMess = MqttConnectMessage()
          .withClientIdentifier(AwsIotCoreConfig.clientId)
          .startClean();
      _client.connectionMessage = connMess;

      await _client.connect();
    } catch (e) {
      debugPrint('Connect failed: $e');
      emit(AwsIotError('Connect failed: $e'));
      _client.disconnect();
    }
  }

  /// Handle on connected, after connected, we'll subscribe the
  /// channel [AwsIotCoreConfig.subTopic] and
  /// channel [AwsIotCoreConfig.estadoRelesTopic]
  void _handleOnConnected(Emitter<AwsIotState> emit) async {
    debugPrint('MQTT client is connected');

    _client.subscribe(AwsIotCoreConfig.subTopic, MqttQos.atMostOnce);
    _client.subscribe(AwsIotCoreConfig.estadoRelesTopic, MqttQos.atMostOnce);

    _client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final topic = c[0].topic;
      final recMess = c[0].payload as MqttPublishMessage;
      final message = String.fromCharCodes(recMess.payload.message);
      add(AwsIotDataReceivedEvent(message, topic));
    });

    emit(AwsIotConnected());
  }

  /// Send message to AWS IoT, if fail, emit [AwsIotError]
  Future<void> _onSendMessage(
      AwsIotSendMessage event, Emitter<AwsIotState> emit) async {
    debugPrint('Sending message: ${event.message}');
    try {
      _publishMessage(event.message);
    } catch (e) {
      debugPrint('Send message failed: $e');
      emit(AwsIotError('Send message failed: $e'));
    }
  }

  /// Handle data coming from AWS IoT
  Future<void> _onDataComming(String payload, String topic, Emitter<AwsIotState> emit) async {
    if(topic == AwsIotCoreConfig.subTopic){
      Future.microtask(() {
        sensoresNotifier.procesarPayload(payload);
      });
    } else if (topic == AwsIotCoreConfig.estadoRelesTopic){
      Future.microtask(() {
        debugPrint('Data coming from $topic');
        dispositivosNotifier.procesarPayload(payload);
      });
    }
    debugPrint('Data coming from $topic: $payload');
    _messages.insert(0, payload);
    if (_messages.length > maxMessages) {
      _messages.removeLast();
    }
    //emit(AwsIotDataReceived(List.from(_messages)));
  }

  Future<void> _onSendFormattedMessage(
      FormattedDataModel formattedData, Emitter<AwsIotState> emit) async {
    debugPrint('Sending formatted data: ${formattedData.toJson()}');
    try {
      final messageWithBody = {'body': formattedData.toJson()};
      final jsonString = jsonEncode(messageWithBody);
      debugPrint('Sending formatted data: $jsonString');
      _publishMessage(jsonString);
    } catch (e) {
      debugPrint('Send formatted message failed: $e');
      emit(AwsIotError('Send formatted message failed: $e'));
    }
  }

  /// The actual message sending function
  /// If the client is not connected, throw an exception
  void _publishMessage(String payload) {
    if (_client.connectionStatus?.state != MqttConnectionState.connected) {
      throw Exception('Mqtt client is not connected');
    }

    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);

    _client.publishMessage(
      AwsIotCoreConfig.pubTopic,
      MqttQos.atMostOnce,
      builder.payload!,
    );
  }
}