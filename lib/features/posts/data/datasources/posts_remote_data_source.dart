import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/utils/constants.dart';
import '../models/post_model.dart';

abstract class PostsRemoteDataSource {
  Future<List<PostModel>> getAllPosts();
  Future<PostModel> getPost(int id);
  Future<PostModel> createPost(PostModel post);
  Future<PostModel> updatePost(PostModel post);
  Future<PostModel> patchPost(int id, Map<String, dynamic> updates);
  Future<void> deletePost(int id);
}

class PostsRemoteDataSourceImpl implements PostsRemoteDataSource {
  final http.Client client;

  PostsRemoteDataSourceImpl({required this.client});

  @override
  Future<List<PostModel>> getAllPosts() async {
    final response = await client.get(
      Uri.parse('${ApiConstants.crudBaseUrl}${ApiConstants.postsEndpoint}'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => PostModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch posts');
    }
  }

  @override
  Future<PostModel> getPost(int id) async {
    final response = await client.get(
      Uri.parse('${ApiConstants.crudBaseUrl}${ApiConstants.postsEndpoint}/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return PostModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch post');
    }
  }

  @override
  Future<PostModel> createPost(PostModel post) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.crudBaseUrl}${ApiConstants.postsEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': post.userId,
        'title': post.title,
        'body': post.body,
      }),
    );

    if (response.statusCode == 201) {
      return PostModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create post');
    }
  }

  @override
  Future<PostModel> updatePost(PostModel post) async {
    final response = await client.put(
      Uri.parse('${ApiConstants.crudBaseUrl}${ApiConstants.postsEndpoint}/${post.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(post.toJson()),
    );

    if (response.statusCode == 200) {
      return PostModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update post');
    }
  }

  @override
  Future<PostModel> patchPost(int id, Map<String, dynamic> updates) async {
    final response = await client.patch(
      Uri.parse('${ApiConstants.crudBaseUrl}${ApiConstants.postsEndpoint}/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updates),
    );

    if (response.statusCode == 200) {
      return PostModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to patch post');
    }
  }

  @override
  Future<void> deletePost(int id) async {
    final response = await client.delete(
      Uri.parse('${ApiConstants.crudBaseUrl}${ApiConstants.postsEndpoint}/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete post');
    }
  }
}
