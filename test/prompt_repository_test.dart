import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weight_report_app/services/prompt_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loads the asset once and then uses the saved prompt', () async {
    final bundle = _FakeAssetBundle('default prompt');
    final repository = PromptRepository(assetBundle: bundle);

    expect(await repository.getAiCommentPrompt(), 'default prompt');
    expect(await repository.getAiCommentPrompt(), 'default prompt');
    expect(bundle.loadCount, 1);
  });

  test('saves and resets the AI comment prompt', () async {
    final repository = PromptRepository(
      assetBundle: _FakeAssetBundle('default prompt'),
    );
    await repository.saveAiCommentPrompt('custom prompt');
    expect(await repository.getAiCommentPrompt(), 'custom prompt');

    expect(await repository.resetAiCommentPrompt(), 'default prompt');
    expect(await repository.getAiCommentPrompt(), 'default prompt');
  });

  test('reports an asset loading failure', () async {
    final repository = PromptRepository(assetBundle: _FailingAssetBundle());

    expect(
      repository.getAiCommentPrompt(),
      throwsA(isA<PromptRepositoryException>()),
    );
  });
}

class _FakeAssetBundle extends CachingAssetBundle {
  _FakeAssetBundle(this.value);

  final String value;
  int loadCount = 0;

  @override
  Future<ByteData> load(String key) => throw UnimplementedError();

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    loadCount += 1;
    return value;
  }
}

class _FailingAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) => throw StateError('asset missing');

  @override
  Future<String> loadString(String key, {bool cache = true}) =>
      throw StateError('asset missing');
}
