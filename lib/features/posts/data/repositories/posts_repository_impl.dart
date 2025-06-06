import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/posts_repository.dart';
import '../datasources/posts_remote_data_source.dart';
import '../models/post_model.dart';

class PostsRepositoryImpl implements PostsRepository {
  final PostsRemoteDataSource remoteDataSource;

  PostsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Post>>> getAllPosts() async {
    try {
      final posts = await remoteDataSource.getAllPosts();
      return Right(posts);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Post>> getPost(int id) async {
    try {
      final post = await remoteDataSource.getPost(id);
      return Right(post);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Post>> createPost(Post post) async {
    try {
      final postModel = PostModel(
        id: post.id,
        userId: post.userId,
        title: post.title,
        body: post.body,
      );
      final createdPost = await remoteDataSource.createPost(postModel);
      return Right(createdPost);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Post>> updatePost(Post post) async {
    try {
      final postModel = PostModel(
        id: post.id,
        userId: post.userId,
        title: post.title,
        body: post.body,
      );
      final updatedPost = await remoteDataSource.updatePost(postModel);
      return Right(updatedPost);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Post>> patchPost(int id, Map<String, dynamic> updates) async {
    try {
      final patchedPost = await remoteDataSource.patchPost(id, updates);
      return Right(patchedPost);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(int id) async {
    try {
      await remoteDataSource.deletePost(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
