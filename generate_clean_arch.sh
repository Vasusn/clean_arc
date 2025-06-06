#!/bin/bash


echo ""
echo ""



import 'package:equatable/equatable.dart';


  @override
}


}
EOF

import 'package:dartz/dartz.dart';



}
}
EOF




  @override
}
EOF

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

}
EOF

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';



  @override
  }
}


}
EOF



    required super.id,
  });

      id: json['id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
EOF

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/utils/constants.dart';

}

  final http.Client client;


  @override
    final response = await client.post(
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
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
    } else {
    }
  }
}
EOF

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';



  @override
    try {
    } catch (e) {
    }
  }

  @override
    try {
    } catch (e) {
    }
  }

  @override
  }
}
EOF


import 'package:equatable/equatable.dart';
import '../../domain/entities/post.dart';


  @override
  List<Object> get props => [];
}



  @override
}

class LogoutRequested extends AuthEvent {}
EOF

import 'package:equatable/equatable.dart';


  @override
  List<Object> get props => [];
}





  @override
}

  final String message;


  @override
  List<Object> get props => [message];
}

class PostOperationSuccess extends PostsState {
  final String message;
  final List<Post> posts;

  const PostOperationSuccess(this.message, this.posts);

  @override
  List<Object> get props => [message, posts];
}
EOF

import 'package:flutter_bloc/flutter_bloc.dart';


  }

  ) async {


    result.fold(
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {


}



            );
            );
          }



                    },
                                        );
                                  }
                      );
                    },
    );
  }
}
EOF


cat > lib/features/home/presentation/pages/home_page.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/pages/login_page.dart';
import '../../../posts/presentation/bloc/posts_bloc.dart';
import '../../../posts/presentation/bloc/posts_event.dart';
import '../../../posts/presentation/bloc/posts_state.dart';
import '../../../posts/domain/entities/post.dart';
import '../widgets/post_form_dialog.dart';
import '../widgets/post_card.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PostsBloc>().add(GetAllPostsEvent());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // CRUD Operations Header
            Container(
              decoration: BoxDecoration(
              ),
            ),
                child: Column(
                  children: [
                    const Icon(
                      color: Colors.blue,
                      size: 32,
                    ),
                    const Text(
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreatePostDialog(context);
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
EOF

                ),
              ),
            ),
          ),
        ),
      ],
        ),
      ),
    );
  }
}



