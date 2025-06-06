import 'package:equatable/equatable.dart';
import '../../domain/entities/post.dart';

abstract class PostsEvent extends Equatable {
  const PostsEvent();

  @override
  List<Object> get props => [];
}

class GetAllPostsEvent extends PostsEvent {}

class CreatePostEvent extends PostsEvent {
  final Post post;

  const CreatePostEvent(this.post);

  @override
  List<Object> get props => [post];
}

class UpdatePostEvent extends PostsEvent {
  final Post post;

  const UpdatePostEvent(this.post);

  @override
  List<Object> get props => [post];
}

class PatchPostEvent extends PostsEvent {
  final int id;
  final Map<String, dynamic> updates;

  const PatchPostEvent(this.id, this.updates);

  @override
  List<Object> get props => [id, updates];
}

class DeletePostEvent extends PostsEvent {
  final int id;

  const DeletePostEvent(this.id);

  @override
  List<Object> get props => [id];
}
