import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/citizen_request.dart';

final citizenLanguageProvider = StateProvider<String>((ref) => 'hi');

final myRequestsProvider =
    StateNotifierProvider<MyRequestsNotifier, List<CitizenRequest>>(
  (ref) => MyRequestsNotifier(),
);

class MyRequestsNotifier extends StateNotifier<List<CitizenRequest>> {
  MyRequestsNotifier() : super([]);

  void add(CitizenRequest request) {
    state = [request, ...state];
  }
}
