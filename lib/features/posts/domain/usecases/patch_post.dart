import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post.dart';
import '../repositories/posts_repository.dart';

class PatchPost implements UseCase<Post, PatchPostParams> {
  final PostsRepository repository;

  PatchPost(this.repository);

  @override
  Future<Either<Failure, Post>> call(PatchPostParams params) async {
    return await repository.patchPost(params.id, params.updates);
  }
}

class PatchPostParams {
  final int id;
  final Map<String, dynamic> updates;

  PatchPostParams({required this.id, required this.updates});
}
