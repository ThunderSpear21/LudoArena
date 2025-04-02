import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ludo_app/bloc/host/host_bloc.dart';
import 'package:ludo_app/bloc/join/join_bloc.dart';
import 'package:ludo_app/bloc/socket_bloc.dart';
import 'package:ludo_app/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => JoinBloc()),
        BlocProvider(create: (context) => HostBloc()), 
        BlocProvider(
          create: (context) {
            final socketBloc = SocketBloc();
            socketBloc.add(ConnectToSocket());
            return socketBloc;
          },
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
  }
}
