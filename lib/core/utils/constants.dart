class ApiConstants {
  // DummyJSON API for Authentication
  static const String authBaseUrl = 'https://dummyjson.com';
  static const String loginEndpoint = '/auth/login';

  // JSONPlaceholder API for CRUD operations
  static const String crudBaseUrl = 'https://jsonplaceholder.typicode.com';
  static const String usersEndpoint = '/users';
  static const String postsEndpoint = '/posts';
}

class AppStrings {
  static const String appName = 'Clean Architecture Login';
  static const String login = 'Login';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String welcome = 'Welcome';
  static const String loginSuccess = 'Login Successful';
  static const String loginError = 'Login Failed';
}
