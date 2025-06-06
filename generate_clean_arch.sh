#!/bin/bash

# Flutter Login Feature Generator using Clean Architecture
# Uses DummyJSON API for authentication and JSONPlaceholder for CRUD operations
# Run this in your Flutter project root directory

echo "🚀 Generating Flutter Login Feature with Clean Architecture..."
echo ""
echo "📡 APIs Used:"
echo "  • Authentication: https://dummyjson.com/docs/auth"
echo "  • CRUD Operations: https://jsonplaceholder.typicode.com"
echo ""

# Create Feature Structure
echo "📁 Creating Authentication Feature Structure..."
mkdir -p lib/features/authentication/data/datasources
mkdir -p lib/features/authentication/data/models
mkdir -p lib/features/authentication/data/repositories
mkdir -p lib/features/authentication/domain/entities
mkdir -p lib/features/authentication/domain/repositories
mkdir -p lib/features/authentication/domain/usecases
mkdir -p lib/features/authentication/presentation/bloc
mkdir -p lib/features/authentication/presentation/pages
mkdir -p lib/features/authentication/presentation/widgets

# Create Home Feature Structure
mkdir -p lib/features/home/presentation/pages

# Create Core Structure if not exists
mkdir -p lib/core/error
mkdir -p lib/core/network
mkdir -p lib/core/usecases
mkdir -p lib/core/utils

# Generate Core Files
echo "📄 Creating Core Files..."

cat > lib/core/error/failures.dart << 'EOF'
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
EOF

cat > lib/core/usecases/usecase.dart << 'EOF'
import 'package:dartz/dartz.dart';
import '../error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
EOF

cat > lib/core/utils/constants.dart << 'EOF'
class ApiConstants {
  // DummyJSON API for Authentication
  static const String authBaseUrl = 'https://dummyjson.com';
  static const String loginEndpoint = '/auth/login';

  // JSONPlaceholder API for CRUD operations
  static const String crudBaseUrl = 'https://jsonplaceholder.typicode.com';
  static const String usersEndpoint = '/users';
  static const String postsEndpoint = '/posts';
}

class AppStrings {
  static const String appName = 'Clean Architecture Login';
  static const String login = 'Login';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String welcome = 'Welcome';
  static const String loginSuccess = 'Login Successful';
  static const String loginError = 'Login Failed';
}
EOF

# Generate Authentication Domain Layer
echo "📄 Creating Authentication Domain Layer..."

cat > lib/features/authentication/domain/entities/user.dart << 'EOF'
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String token;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.token,
  });

  @override
  List<Object?> get props => [id, username, email, firstName, lastName, token];
}
EOF

cat > lib/features/authentication/domain/repositories/auth_repository.dart << 'EOF'
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String username, String password);
  Future<Either<Failure, void>> logout();
  Future<bool> isLoggedIn();
}
EOF

cat > lib/features/authentication/domain/usecases/login_user.dart << 'EOF'
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUser implements UseCase<User, LoginParams> {
  final AuthRepository repository;

  LoginUser(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    return await repository.login(params.username, params.password);
  }
}

class LoginParams {
  final String username;
  final String password;

  LoginParams({required this.username, required this.password});
}
EOF

# Generate Authentication Data Layer
echo "📄 Creating Authentication Data Layer..."

cat > lib/features/authentication/data/models/user_model.dart << 'EOF'
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'token': token,
    };
  }
}
EOF

cat > lib/features/authentication/data/datasources/auth_remote_data_source.dart << 'EOF'
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/utils/constants.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String username, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> login(String username, String password) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.authBaseUrl}${ApiConstants.loginEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Login failed');
    }
  }
}
EOF

cat > lib/features/authentication/data/repositories/auth_repository_impl.dart << 'EOF'
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> login(String username, String password) async {
    try {
      final user = await remoteDataSource.login(username, password);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Implement logout logic here
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    // Implement check login status logic here
    return false;
  }
}
EOF

# Generate Authentication Presentation Layer
echo "📄 Creating Authentication Presentation Layer..."

cat > lib/features/authentication/presentation/bloc/auth_event.dart << 'EOF'
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;

  const LoginRequested({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];
}

class LogoutRequested extends AuthEvent {}
EOF

cat > lib/features/authentication/presentation/bloc/auth_state.dart << 'EOF'
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;

  const AuthSuccess(this.user);

  @override
  List<Object> get props => [user];
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object> get props => [message];
}
EOF

cat > lib/features/authentication/presentation/bloc/auth_bloc.dart << 'EOF'
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;

  AuthBloc({required this.loginUser}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await loginUser(
      LoginParams(username: event.username, password: event.password),
    );

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthInitial());
  }
}
EOF

cat > lib/features/authentication/presentation/pages/login_page.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/constants.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo/Title
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    AppStrings.appName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Username Field
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: AppStrings.password,
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Login Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(
                                          LoginRequested(
                                            username: _usernameController.text,
                                            password: _passwordController.text,
                                          ),
                                        );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: state is AuthLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  AppStrings.login,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Demo credentials info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      border: Border.all(color: Colors.amber),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Demo Credentials:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Username: kminchelle\nPassword: 0lelplR',
                          style: TextStyle(color: Colors.amber[800]),
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
    );
  }
}
EOF

# Generate Home Page
echo "📄 Creating Home Page..."

cat > lib/features/home/presentation/pages/home_page.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/pages/login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 60,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '🎉 Welcome to Home!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Login Successful!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 48),
            Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 32,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Clean Architecture Demo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This app demonstrates Clean Architecture with:\n'
                      '• Domain Layer (Business Logic)\n'
                      '• Data Layer (API Integration)\n'
                      '• Presentation Layer (UI & State)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
EOF

# Generate Main App File
echo "📄 Creating Main App File..."

cat > lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'features/authentication/data/datasources/auth_remote_data_source.dart';
import 'features/authentication/data/repositories/auth_repository_impl.dart';
import 'features/authentication/domain/usecases/login_user.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            loginUser: LoginUser(
              AuthRepositoryImpl(
                remoteDataSource: AuthRemoteDataSourceImpl(
                  client: http.Client(),
                ),
              ),
            ),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Clean Architecture Login',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const LoginPage(),
      ),
    );
  }
}
EOF

# Generate pubspec.yaml dependencies
echo "📄 Creating pubspec.yaml dependencies..."

cat > pubspec_dependencies.txt << 'EOF'
# Add these dependencies to your pubspec.yaml:

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  dartz: ^0.10.1
  http: ^1.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
EOF

echo "✅ Flutter Login Feature Generated Successfully!"
echo ""
echo "📚 API Information:"
echo "🔐 Authentication API: https://dummyjson.com/docs/auth"
echo "   • Login endpoint: POST /auth/login"
echo "   • Demo credentials: username: 'kminchelle', password: '0lelplR'"
echo ""
echo "🔧 CRUD Operations API: https://jsonplaceholder.typicode.com"
echo "   • Users: GET/POST/PUT/DELETE /users"
echo "   • Posts: GET/POST/PUT/DELETE /posts"
echo ""
echo "🚀 Next Steps:"
echo "1. Add the dependencies from pubspec_dependencies.txt to your pubspec.yaml"
echo "2. Run: flutter pub get"
echo "3. Run: flutter run"
echo ""
echo "🎯 Features:"
echo "• Clean Architecture structure"
echo "• BLoC state management"
echo "• Real API integration"
echo "• Simple login → home flow"
echo "• Error handling"
echo ""
echo "📱 Demo Credentials:"
echo "Username: kminchelle"
echo "Password: 0lelplR"
EOF

# Make script executable
chmod +x generate_login_feature.sh

echo ""
echo "💡 Usage:"
echo "1. Save this as 'generate_login_feature.sh'"
echo "2. Run: chmod +x generate_login_feature.sh"
echo "3. Run: ./generate_login_feature.sh"