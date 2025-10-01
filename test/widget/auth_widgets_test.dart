import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Auth Widget Tests', () {
    testWidgets('Text field renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Button renders and can be tapped', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () => tapped = true,
              child: const Text('Login'),
            ),
          ),
        ),
      );

      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      expect(tapped, true);
    });

    testWidgets('Password field obscures text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, true);
    });

    testWidgets('Loading indicator shows correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Form validation shows error', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field is required';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Field is required'), findsOneWidget);
    });
  });
}
