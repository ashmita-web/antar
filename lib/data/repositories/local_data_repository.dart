import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config.dart';
import '../../core/providers.dart';
import '../models/candidate_project.dart';
import '../models/citizen_request.dart';
import '../models/gap_entry.dart';
import '../models/village.dart';

final localDataRepositoryProvider = Provider<LocalDataRepository>((ref) {
  final region = ref.watch(appRegionProvider);
  return LocalDataRepository(region);
});

final villagesProvider = FutureProvider<List<Village>>((ref) {
  return ref.watch(localDataRepositoryProvider).loadVillages();
});

final gapMatrixProvider = FutureProvider<List<GapEntry>>((ref) {
  return ref.watch(localDataRepositoryProvider).loadGapMatrix();
});

final requestsProvider = FutureProvider<List<CitizenRequest>>((ref) {
  return ref.watch(localDataRepositoryProvider).loadRequests();
});

final candidatesProvider = FutureProvider<List<CandidateProject>>((ref) {
  return ref.watch(localDataRepositoryProvider).loadCandidates();
});

final aiCacheProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(localDataRepositoryProvider).loadAiCache();
});

class LocalDataRepository {
  LocalDataRepository(this._region);
  final AppRegion _region;

  String get _suffix => _region == AppRegion.brazil ? '_br' : '';

  Future<List<Village>> loadVillages() async {
    final data = await _loadAsset('villages$_suffix.json');
    return (data as List).map((e) => Village.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<GapEntry>> loadGapMatrix() async {
    final data = await _loadAsset('gap_matrix$_suffix.json');
    return (data as List).map((e) => GapEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<CitizenRequest>> loadRequests() async {
    final data = await _loadAsset('requests$_suffix.json');
    return (data as List).map((e) => CitizenRequest.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<CandidateProject>> loadCandidates() async {
    final data = await _loadAsset('candidates$_suffix.json');
    return (data as List).map((e) => CandidateProject.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> loadAiCache() async {
    final data = await _loadAsset('ai_cache$_suffix.json');
    return data as Map<String, dynamic>;
  }

  Future<dynamic> _loadAsset(String name) async {
    final jsonStr = await rootBundle.loadString('assets/data/$name');
    return json.decode(jsonStr);
  }
}
