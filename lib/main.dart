import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_state.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/todo_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = InjectionContainer();
  await container.init();
  runApp(MyApp(container: container));
}

class MyApp extends StatelessWidget {
  final InjectionContainer container;

  const MyApp({super.key, required this.container});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: container.getBlocProviders(),
      child: MaterialApp(
        title: 'Todo App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return const TodoListScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
