import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

class UserViewModel extends StateNotifier<UserModel> {
  UserViewModel()
      : super(UserModel(
          id: '1',
          username: 'Admin',
          email: 'admin@example.com',
        ));

  void updateUser(UserModel user) {
    state = user;
  }
}
