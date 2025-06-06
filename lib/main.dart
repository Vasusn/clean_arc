import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'features/authentication/data/datasources/auth_remote_data_source.dart';
import 'features/authentication/data/repositories/auth_repository_impl.dart';
import 'features/authentication/domain/usecases/login_user.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/pages/login_page.dart';
import 'features/posts/data/datasources/posts_remote_data_source.dart';
import 'features/posts/data/repositories/posts_repository_impl.dart';
import 'features/posts/domain/usecases/get_all_posts.dart';
import 'features/posts/domain/usecases/create_post.dart';
import 'features/posts/domain/usecases/update_post.dart';
import 'features/posts/domain/usecases/patch_post.dart';
import 'features/posts/domain/usecases/delete_post.dart';
import 'features/posts/presentation/bloc/posts_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create shared HTTP client
    final httpClient = http.Client();

    // Create shared data sources
    final authRemoteDataSource = AuthRemoteDataSourceImpl(client: httpClient);
    final postsRemoteDataSource = PostsRemoteDataSourceImpl(client: httpClient);

    // Create repositories
    final authRepository = AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);
    final postsRepository = PostsRepositoryImpl(remoteDataSource: postsRemoteDataSource);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            loginUser: LoginUser(authRepository),
          ),
        ),
        BlocProvider(
          create: (context) => PostsBloc(
            getAllPosts: GetAllPosts(postsRepository),
            createPost: CreatePost(postsRepository),
            updatePost: UpdatePost(postsRepository),
            patchPost: PatchPost(postsRepository),
            deletePost: DeletePost(postsRepository),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Clean Architecture Login',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 2,
          ),
          cardTheme: CardTheme(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        home: const LoginPage(),
      ),
    );
  }
}
