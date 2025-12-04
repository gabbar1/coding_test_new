import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/network_info.dart';
import '../../data/database/database_helper.dart';
import '../../data/datasources/local/todo_local_data_source.dart';
import '../../data/datasources/remote/todo_remote_data_source.dart';
import '../../data/repositories/todo_repository_impl.dart';
import '../../domain/repositories/todo_repository.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/todo/todo_bloc.dart';

class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();
  factory InjectionContainer() => _instance;
  InjectionContainer._internal();

  late final Dio _dio;
  late final SharedPreferences _prefs;
  late final INetworkInfo _networkInfo;
  late final ITodoRemoteDataSource _remoteDataSource;
  late final ITodoLocalDataSource _localDataSource;
  late final ITodoRepository _repository;

  Future<void> init() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
      ),
    );

    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );

    _prefs = await DatabaseHelper.instance.prefs;
    _networkInfo = NetworkInfo(Connectivity());
    _remoteDataSource = TodoRemoteDataSource(_dio);
    _localDataSource = TodoLocalDataSource(_prefs);
    _repository = TodoRepositoryImpl(
      _remoteDataSource,
      _localDataSource,
      _networkInfo,
      const Uuid(),
    );
  }

  List<BlocProvider> getBlocProviders() {
    return [
      BlocProvider<AuthBloc>(
        create: (_) => AuthBloc(),
      ),
      BlocProvider<TodoBloc>(
        create: (_) => TodoBloc(_repository),
      ),
    ];
  }
}

