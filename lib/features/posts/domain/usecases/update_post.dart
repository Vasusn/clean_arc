import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post.dart';
import '../repositories/posts_repository.dart';

class UpdatePost implements UseCase<Post, UpdatePostParams> {
  final PostsRepository repository;

  UpdatePost(this.repository);

  @override
  Future<Either<Failure, Post>> call(UpdatePostParams params) async {
    return await repository.updatePost(params.post);
  }
}

class UpdatePostParams {
  final Post post;

  UpdatePostParams({required this.post});
}
