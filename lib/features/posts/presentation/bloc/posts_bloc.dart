import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_all_posts.dart';
import '../../domain/usecases/create_post.dart';
import '../../domain/usecases/update_post.dart';
import '../../domain/usecases/patch_post.dart';
import '../../domain/usecases/delete_post.dart';
import 'posts_event.dart';
import 'posts_state.dart';

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  final GetAllPosts getAllPosts;
  final CreatePost createPost;
  final UpdatePost updatePost;
  final PatchPost patchPost;
  final DeletePost deletePost;

  PostsBloc({
    required this.getAllPosts,
    required this.createPost,
    required this.updatePost,
    required this.patchPost,
    required this.deletePost,
  }) : super(PostsInitial()) {
    on<GetAllPostsEvent>(_onGetAllPosts);
    on<CreatePostEvent>(_onCreatePost);
    on<UpdatePostEvent>(_onUpdatePost);
    on<PatchPostEvent>(_onPatchPost);
    on<DeletePostEvent>(_onDeletePost);
  }

  Future<void> _onGetAllPosts(
      GetAllPostsEvent event,
      Emitter<PostsState> emit,
      ) async {
    emit(PostsLoading());

    final result = await getAllPosts(NoParams());

    result.fold(
          (failure) => emit(PostsError(failure.message)),
          (posts) => emit(PostsLoaded(posts)),
    );
  }

  Future<void> _onCreatePost(
      CreatePostEvent event,
      Emitter<PostsState> emit,
      ) async {
    emit(PostsLoading());

    final result = await createPost(CreatePostParams(post: event.post));

    await result.fold(
          (failure) async => emit(PostsError(failure.message)),
          (post) async {
        // Refresh the list after creating
        final refreshResult = await getAllPosts(NoParams());
        refreshResult.fold(
              (failure) => emit(PostsError(failure.message)),
              (posts) => emit(PostOperationSuccess('Post created successfully!', posts)),
        );
      },
    );
  }

  Future<void> _onUpdatePost(
      UpdatePostEvent event,
      Emitter<PostsState> emit,
      ) async {
    emit(PostsLoading());

    final result = await updatePost(UpdatePostParams(post: event.post));

    await result.fold(
          (failure) async => emit(PostsError(failure.message)),
          (post) async {
        // Refresh the list after updating
        final refreshResult = await getAllPosts(NoParams());
        refreshResult.fold(
              (failure) => emit(PostsError(failure.message)),
              (posts) => emit(PostOperationSuccess('Post updated successfully!', posts)),
        );
      },
    );
  }

  Future<void> _onPatchPost(
      PatchPostEvent event,
      Emitter<PostsState> emit,
      ) async {
    emit(PostsLoading());

    final result = await patchPost(PatchPostParams(id: event.id, updates: event.updates));

    await result.fold(
          (failure) async => emit(PostsError(failure.message)),
          (post) async {
        // Refresh the list after patching
        final refreshResult = await getAllPosts(NoParams());
        refreshResult.fold(
              (failure) => emit(PostsError(failure.message)),
              (posts) => emit(PostOperationSuccess('Post patched successfully!', posts)),
        );
      },
    );
  }

  Future<void> _onDeletePost(
      DeletePostEvent event,
      Emitter<PostsState> emit,
      ) async {
    emit(PostsLoading());

    final result = await deletePost(DeletePostParams(id: event.id));

    await result.fold(
          (failure) async => emit(PostsError(failure.message)),
          (_) async {
        // Refresh the list after deleting
        final refreshResult = await getAllPosts(NoParams());
        refreshResult.fold(
              (failure) => emit(PostsError(failure.message)),
              (posts) => emit(PostOperationSuccess('Post deleted successfully!', posts)),
        );
      },
    );
  }
}