import 'package:flutter/material.dart';
import '../../providers/providers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab04/services/blocs/aws_iot_bloc.dart';
import 'package:lab04/services/widgets/connect_button.dart';
import 'package:lab04/services/widgets/message_input_bar.dart';
import 'package:lab04/services/widgets/message_temperature.dart';
import 'package:lab04/services/widgets/send_formatted_data_button.dart';

/*class TemperatureView extends StatelessWidget {
  const TemperatureView({super.key});

  @override
  Widget build(BuildContext context) {
    final sensoresNotifier = ref.read(sensoresProvider.notifier);
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => AwsIotBloc(sensoresNotifier: sensoresNotifier))],
      child: const TemperaturePage(),
    );
  }
}

class TemperaturePage extends StatefulWidget {
  const TemperaturePage({super.key});

  @override
  State<TemperaturePage> createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
  
  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    return BlocConsumer<AwsIotBloc, AwsIotState>(
      listener: (context, state) {
        if (state is AwsIotError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },

      builder: (context, state) {
        if (state is AwsIotInitial ||
            state is AwsIotDisconnected ||
            state is AwsIotError) {
          //return Center(child: ConnectButton());
          context.read<AwsIotBloc>().add(AwsIotConnect());
        }

        if (state is AwsIotConnecting) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Padding(
              //   padding: const EdgeInsets.all(10.0),
              //   child: MessageInputBar(
              //     onSend:
              //         (message) => context.read<AwsIotBloc>().add(
              //           AwsIotSendMessage(message),
              //         ),
              //   ),
              // ),

              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: MessageTemperature(
                  messages: state is AwsIotDataReceived ? state.messages : [],
                ),
              ),

              //const SizedBox(height: 16),SS

              //const Center(child: SendFormattedDataButton()),

            ],
          ),
        );
      },
    );
  }
}
*/