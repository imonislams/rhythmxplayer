import 'deezer_api.dart';
import '../local/local_store.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final httpClientProvider = Provider((ref) => http.Client());
final deezerApiProvider = Provider(
  (ref) => DeezerApi(ref.read(httpClientProvider)),
);
final localStoreProvider = Provider((ref) => LocalStore());

final lowDataModeProvider = StateNotifierProvider<LowDataModeNotifier, bool>((
  ref,
) {
  return LowDataModeNotifier(ref.read(localStoreProvider));
});

class LowDataModeNotifier extends StateNotifier<bool> {
  final LocalStore _store;
  LowDataModeNotifier(this._store) : super(false) {
    _load();
  }
  Future<void> _load() async => state = await _store.getLowDataMode();
  Future<void> set(bool v) async {
    state = v;
    await _store.setLowDataMode(v);
  }
}
