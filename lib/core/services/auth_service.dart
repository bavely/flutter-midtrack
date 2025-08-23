import 'package:graphql_flutter/graphql_flutter.dart';

import '../models/user.dart';

/// GraphQL operations for authentication.
const String _loginUserMutation = r'''
mutation LoginUser($email: String!, $password: String!) {
  loginUser(email: $email, password: $password) {
    token
    user {
      id
      email
      name
      profileImageUrl
      createdAt
    }
  }
}
''';

const String _registerUserMutation = r'''
mutation RegisterUser($email: String!, $password: String!, $name: String!) {
  registerUser(email: $email, password: $password, name: $name) {
    token
    user {
      id
      email
      name
      profileImageUrl
      createdAt
    }
  }
}
''';

const String _refreshTokenMutation = r'''
mutation RefreshToken($refreshToken: String!) {
  refreshToken(refreshToken: $refreshToken) {
    token
  }
}
''';

const String _resetPasswordMutation = r'''
mutation ForgotPassword($email: String!) {
  forgotPassword(email: $email) {
    success
  }
}
''';

const String _getViewerQuery = r'''
query GetUser {
  getUser {
    id
    email
    name
    profileImageUrl
    createdAt
  }
}
''';

class AuthService {
  AuthService({required GraphQLClient client}) : _client = client;

  final GraphQLClient _client;

  Future<AuthResult> login(String email, String password) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_loginUserMutation),
        variables: {
          'email': email,
          'password': password,
        },
      ),
    );
    return _parseAuthResult(result, 'loginUser');
  }

  Future<AuthResult> signup(String email, String password, String name) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_registerUserMutation),
        variables: {
          'email': email,
          'password': password,
          'name': name,
        },
      ),
    );
    return _parseAuthResult(result, 'registerUser');
  }

  Future<void> forgotPassword(String email) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_resetPasswordMutation),
        variables: {'email': email},
      ),
    );
    if (result.hasException) {
      throw result.exception!;
    }
  }

  Future<User> getCurrentUser() async {
    final result = await _client.query(
      QueryOptions(document: gql(_getViewerQuery)),
    );
    if (result.hasException) {
      throw result.exception!;
    }
    final data = result.data?['getUser'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('User data not found');
    }
    return User.fromJson(data);
  }

  Future<String> refreshToken(String refreshToken) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_refreshTokenMutation),
        variables: {'refreshToken': refreshToken},
      ),
    );
    if (result.hasException) {
      throw result.exception!;
    }
    final data = result.data?['refreshToken'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Token refresh failed');
    }
    return data['token'] as String;
  }

  AuthResult _parseAuthResult(QueryResult result, String field) {
    if (result.hasException) {
      throw result.exception!;
    }
    final data = result.data?[field] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Invalid response');
    }
    return AuthResult.fromJson({
      'token': data['token'],
      'user': data['user'],
    });
  }
}

