import 'package:clean_arch/features/home/presentation/widget/post_card.dart';
import 'package:clean_arch/features/home/presentation/widget/post_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/pages/login_page.dart';
import '../../../posts/presentation/bloc/posts_bloc.dart';
import '../../../posts/presentation/bloc/posts_event.dart';
import '../../../posts/presentation/bloc/posts_state.dart';
import '../../../posts/domain/entities/post.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load posts when home page opens
    context.read<PostsBloc>().add(GetAllPostsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: BlocListener<PostsBloc, PostsState>(
        listener: (context, state) {
          if (state is PostOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is PostsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: Column(
          children: [
            _buildCrudHeader(),
            Expanded(
              child: BlocBuilder<PostsBloc, PostsState>(
                builder: (context, state) {
                  if (state is PostsLoading) {
                    return _buildLoadingWidget();
                  } else if (state is PostsLoaded) {
                    return _buildPostsList(state.posts);
                  } else if (state is PostOperationSuccess) {
                    return _buildPostsList(state.posts);
                  } else if (state is PostsError) {
                    return _buildErrorWidget(state.message);
                  } else {
                    return _buildEmptyState();
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'CRUD Operations Demo',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 2,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh Posts',
          onPressed: () {
            context.read<PostsBloc>().add(GetAllPostsEvent());
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: () => _handleLogout(context),
        ),
      ],
    );
  }

  Widget _buildCrudHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.api,
            color: Colors.blue,
            size: 32,
          ),
          const SizedBox(height: 8),
          const Text(
            'REST API CRUD Operations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'JSONPlaceholder API Demo',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildOperationChip('GET', Colors.green, Icons.download),
              _buildOperationChip('POST', Colors.blue, Icons.add),
              _buildOperationChip('PUT', Colors.orange, Icons.edit),
              _buildOperationChip('PATCH', Colors.purple, Icons.update),
              _buildOperationChip('DELETE', Colors.red, Icons.delete),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOperationChip(String label, Color color, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      backgroundColor: color,
      elevation: 2,
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading posts...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList(List<Post> posts) {
    if (posts.isEmpty) {
      return _buildEmptyPostsList();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<PostsBloc>().add(GetAllPostsEvent());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostCard(
            post: post,
            onEdit: () => _showEditPostDialog(context, post),
            onPatch: () => _showPatchPostDialog(context, post),
            onDelete: () => _showDeleteConfirmation(context, post),
          );
        },
      ),
    );
  }

  Widget _buildEmptyPostsList() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No posts found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the + button to create your first post',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Error: $message',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<PostsBloc>().add(GetAllPostsEvent());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.refresh,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Press refresh to load posts',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _showCreatePostDialog(context),
      backgroundColor: Colors.blue,
      tooltip: 'Create New Post',
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _handleLogout(BuildContext context) {
    context.read<AuthBloc>().add(LogoutRequested());
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => PostFormDialog(
        title: 'Create New Post',
        buttonText: 'CREATE (POST)',
        onSubmit: (title, body) {
          final newPost = Post(
            id: 0, // Will be assigned by server
            userId: 1,
            title: title,
            body: body,
          );
          context.read<PostsBloc>().add(CreatePostEvent(newPost));
        },
      ),
    );
  }

  void _showEditPostDialog(BuildContext context, Post post) {
    showDialog(
      context: context,
      builder: (dialogContext) => PostFormDialog(
        title: 'Edit Post (PUT)',
        buttonText: 'UPDATE (PUT)',
        initialTitle: post.title,
        initialBody: post.body,
        onSubmit: (title, body) {
          final updatedPost = Post(
            id: post.id,
            userId: post.userId,
            title: title,
            body: body,
          );
          context.read<PostsBloc>().add(UpdatePostEvent(updatedPost));
        },
      ),
    );
  }

  void _showPatchPostDialog(BuildContext context, Post post) {
    showDialog(
      context: context,
      builder: (dialogContext) => PostFormDialog(
        title: 'Patch Post (PATCH)',
        buttonText: 'PATCH',
        initialTitle: post.title,
        initialBody: post.body,
        isPatch: true,
        onSubmit: (title, body) {
          final updates = <String, dynamic>{};
          if (title != post.title) updates['title'] = title;
          if (body != post.body) updates['body'] = body;

          if (updates.isNotEmpty) {
            context.read<PostsBloc>().add(PatchPostEvent(post.id, updates));
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Post post) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Post'),
          ],
        ),
        content: Text('Are you sure you want to delete "${post.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<PostsBloc>().add(DeletePostEvent(post.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}