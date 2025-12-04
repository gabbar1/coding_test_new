import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthUnauthenticated()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (event.username == 'admin' && event.password == 'password') {
      emit(AuthAuthenticated(event.username));
    } else {
      emit(const AuthError('Invalid credentials. Use admin/password'));
    }
  }

  void _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthUnauthenticated());
  }
}

