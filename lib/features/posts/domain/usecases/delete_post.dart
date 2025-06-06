import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/posts_repository.dart';

class DeletePost implements UseCase<void, DeletePostParams> {
  final PostsRepository repository;

  DeletePost(this.repository);

  @override
  Future<Either<Failure, void>> call(DeletePostParams params) async {
    return await repository.deletePost(params.id);
  }
}

class DeletePostParams {
  final int id;

  DeletePostParams({required this.id});
}
