import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

// import 'package:lab04/services/blocs/aws_iot_bloc.dart';
// import 'package:lab04/services/widgets/connect_button.dart';
// import 'package:lab04/services/widgets/message_display_board.dart';
// import 'package:lab04/services/widgets/message_input_bar.dart';
// import 'package:lab04/services/widgets/send_formatted_data_button.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter/material.dart';

void main() {
  runApp(const ProviderScope(child: App()));
}

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(create: (context) => AwsIotBloc()),
//       ],
//       child: MaterialApp(
//         title: 'AWS IoT Core Demo',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//           useMaterial3: true,
//         ),
//         home: const MyHomePage(),
//       ),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<AwsIotBloc, AwsIotState>(
//       builder: (context, state) {
//         return Scaffold(
//           appBar: AppBar(
//             backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//             title: const Text('AWS IoT Core Demo'),
//           ),
//           body: _buildBody(),
//         );
//       },
//     );
//   }

//   Widget _buildBody() {
//     return BlocConsumer<AwsIotBloc, AwsIotState>(
//       listener: (context, state) {
//         if (state is AwsIotError) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(state.message)),
//           );
//         }
//       },
//       builder: (context, state) {
//         if (state is AwsIotInitial ||
//             state is AwsIotDisconnected ||
//             state is AwsIotError) {
//           return const Center(
//             child: ConnectButton(),
//           );
//         }

//         if (state is AwsIotConnecting) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         }

//         return SingleChildScrollView(
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: MessageInputBar(
//                   onSend: (message) => context
//                       .read<AwsIotBloc>()
//                       .add(AwsIotSendMessage(message)),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: MessageDisplayBoard(
//                   messages: state is AwsIotDataReceived ? state.messages : [],
//                 ),
//               ),
//               const Center(child: SendFormattedDataButton()),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }