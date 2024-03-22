import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

Future<void> main() async {

  enableFlutterDriverExtension(commands: [], finders: []);
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect(dartVmServiceUrl: 'http://127.0.0.1/');
    });

    tearDownAll(() async {
      // Close the connection to the driver after the tests have completed.
      driver.close();

    });

    test('Simulate Interaction 20 Times', () async {
      // Repeat the interaction 20 times
      final floatingActionButton = find.byTooltip('Open');

      // Find the TextFormField by its Key
      final textFormField = find.byValueKey('myTextFormField');

      // Tap on the floating action button
      await driver.tap(floatingActionButton);
      /*for (int i = 0; i < 20; i++) {
        // Simulate clicking on a button with a specific Semantics label
        await driver.tap(find.bySemanticsLabel('Button'));

        // Simulate typing in a text field with a specific Semantics label
        await driver.tap(find.bySemanticsLabel('TextFormField'));
        await driver.enterText('Hello');

        // Wait for a short duration to allow time for UI updates
        await Future.delayed(Duration(seconds: 1));
      }*/
    });

}