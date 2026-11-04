import 'package:flutter_test/flutter_test.dart';
import 'package:yamintto/app/configuration/app_configuration.dart';

void main() {
  group('AppConfiguration', () {
    test('exposes the approved application identity', () {
      expect(AppConfiguration.applicationName, 'Yamintto');
      expect(AppConfiguration.projectName, 'yamintto');
      expect(AppConfiguration.androidApplicationId, 'com.merrmist.yamintto');
      expect(AppConfiguration.iosBundleIdentifier, 'com.merrmist.yamintto');
    });

    test('starts with a beta version', () {
      expect(AppConfiguration.initialVersion, startsWith('0.1.0-beta.'));
    });
  });
}
