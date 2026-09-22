// Smoke test for the demo's SDK-independent UI helper.
//
// The ad screens themselves require the native `mc_sdk` method channel, which
// is only available on a device or emulator, so they are exercised manually.

import 'package:flutter_test/flutter_test.dart';

import 'package:hyperbid_flutter_demo/widgets/event_console.dart';

void main() {
  test('EventConsoleController appends and clears log lines', () {
    final controller = EventConsoleController();

    expect(controller.lines, isEmpty);

    controller.log('first');
    controller.log('second');
    expect(controller.lines, ['first', 'second']);

    controller.clear();
    expect(controller.lines, isEmpty);
  });

  test('EventConsoleController ignores log/clear after dispose', () {
    final controller = EventConsoleController();
    controller.dispose();

    // Late global SDK callbacks must not throw notifyListeners-after-dispose.
    controller.log('late event');
    controller.clear();
    expect(controller.lines, isEmpty);
  });
}
