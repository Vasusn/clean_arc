import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post.dart';
import '../repositories/posts_repository.dart';

class CreatePost implements UseCase<Post, CreatePostParams> {
  final PostsRepository repository;

  CreatePost(this.repository);

  @override
  Future<Either<Failure, Post>> call(CreatePostParams params) async {
    return await repository.createPost(params.post);
  }
}

class CreatePostParams {
  final Post post;

  CreatePostParams({required this.post});
}
