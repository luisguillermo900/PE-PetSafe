import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeViewModel extends StateNotifier<int> {
  HomeViewModel() : super(0); // Tab inicial

  void changeTab(int index) {
    state = index;
  }
}
