import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:command_it/command_it.dart';
import 'package:just_audio_platform_interface/just_audio_platform_interface.dart';

import 'package:mvp_app_protegge_e_trasforma/utils/locator.dart';
import 'package:mvp_app_protegge_e_trasforma/utils/cache_manager.dart';
import 'package:mvp_app_protegge_e_trasforma/data/network/api_client.dart';

// ViewModels
import 'package:mvp_app_protegge_e_trasforma/ui/safeplace/view_model/safe_place_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/auth/view_model/auth_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/view_model/trusted_contact_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/chat/view_model/chatbot_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/material/view_model/material_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/settings/view_model/dead_man_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/sos/view_model/sos_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/home/view_model/home_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_access_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_view_model.dart';

class MockJustAudioPlatform extends JustAudioPlatform {
  @override
  Future<AudioPlayerPlatform> init(InitRequest request) async {
    return MockAudioPlayerPlatform(request.id);
  }
  @override
  Future<DisposePlayerResponse> disposePlayer(DisposePlayerRequest request) async {
    return DisposePlayerResponse();
  }
  @override
  Future<DisposeAllPlayersResponse> disposeAllPlayers(DisposeAllPlayersRequest request) async {
    return DisposeAllPlayersResponse();
  }
}

class MockAudioPlayerPlatform extends AudioPlayerPlatform {
  MockAudioPlayerPlatform(super.id);
  @override
  Stream<PlaybackEventMessage> get playbackEventMessageStream => const Stream.empty();
  @override
  Future<LoadResponse> load(LoadRequest request) async => LoadResponse(duration: const Duration(seconds: 1));
  @override
  Future<PlayResponse> play(PlayRequest request) async => PlayResponse();
  @override
  Future<PauseResponse> pause(PauseRequest request) async => PauseResponse();
  @override
  Future<SeekResponse> seek(SeekRequest request) async => SeekResponse();
  @override
  Future<SetVolumeResponse> setVolume(SetVolumeRequest request) async => SetVolumeResponse();
  @override
  Future<SetSpeedResponse> setSpeed(SetSpeedRequest request) async => SetSpeedResponse();
  @override
  Future<SetLoopModeResponse> setLoopMode(SetLoopModeRequest request) async => SetLoopModeResponse();
  @override
  Future<SetShuffleModeResponse> setShuffleMode(SetShuffleModeRequest request) async => SetShuffleModeResponse();
  @override
  Future<SetAndroidAudioAttributesResponse> setAndroidAudioAttributes(SetAndroidAudioAttributesRequest request) async => SetAndroidAudioAttributesResponse();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    JustAudioPlatform.instance = MockJustAudioPlatform();

    const channelPathProvider = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channelPathProvider, (MethodCall methodCall) async {
      return '.';
    });

    // 1. Inizializza le variabili d'ambiente fittizie
    dotenv.loadFromString(envString: '''
      API_BASE_URL=http://test.com
      COGNITO_DOMAIN=test_domain
      COGNITO_CLIENT_ID=test_id
      COGNITO_CLIENT_SECRET=test_secret
    ''');

    // 2. Intercetta le chiamate di Geolocator per SafePlaceViewModel
    const channel = MethodChannel('flutter.baseflow.com/geolocator');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'isLocationServiceEnabled') {
        return true;
      }
      return null;
    });

    // 3. Mock del Secure Storage per DiaryAccessViewModel
    FlutterSecureStorage.setMockInitialValues({});

    // 4. Previene il crash di command_it per comandi lanciati nei costruttori dei ViewModel
    Command.globalExceptionHandler = (error, stackTrace) {
      // Ignoriamo silenziosamente gli errori asincroni dei Command durante il test del locator
    };
  });

  setUp(() {
    GetIt.instance.reset();
    setupLocator();
  });

  tearDownAll(() {
    const channel = MethodChannel('flutter.baseflow.com/geolocator');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('setupLocator', () {
    test('dovrebbe registrare correttamente le istanze base', () {
      expect(GetIt.instance.isRegistered<ApiClient>(), isTrue);
      expect(GetIt.instance.isRegistered<CacheManager>(), isTrue);
    });

    test('dovrebbe essere in grado di risolvere l\'intero albero delle dipendenze per tutti i ViewModels', () {
      expect(() => GetIt.instance<AuthViewModel>(), returnsNormally);
      expect(() => GetIt.instance<HomeViewModel>(), returnsNormally);
      expect(() => GetIt.instance<SafePlaceViewModel>(), returnsNormally);
      expect(() => GetIt.instance<TrustedContactViewModel>(), returnsNormally);
      expect(() => GetIt.instance<SosViewModel>(), returnsNormally);
      expect(() => GetIt.instance<ChatbotViewModel>(), returnsNormally);
      expect(() => GetIt.instance<MaterialViewModel>(), returnsNormally);
      expect(() => GetIt.instance<DeadManViewModel>(), returnsNormally);
      expect(() => GetIt.instance<DiaryAccessViewModel>(), returnsNormally);
      expect(() => GetIt.instance<DiaryViewModel>(), returnsNormally);
    });
  });
}
