import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firstapp/main.dart';

/// Finds the checkbox circle for a task by its title text.
/// It locates the ListTile containing the text, then taps its leading GestureDetector.
Finder findCheckbox(String taskTitle) {
  return find.descendant(
    of: find.ancestor(
      of: find.text(taskTitle),
      matching: find.byType(ListTile),
    ),
    matching: find.byType(GestureDetector),
  );
}

void main() {
  testWidgets('App loads with default tasks', (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());

    expect(find.text('Buy groceries'), findsOneWidget);
    expect(find.text('Read a book'), findsOneWidget);
    expect(find.text('Go for a walk'), findsOneWidget);
  });

  testWidgets('Can add a new task', (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());

    await tester.enterText(find.byType(TextField), 'New test task');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.text('New test task'), findsOneWidget);
  });

  testWidgets('Can mark a task as completed', (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());

    await tester.tap(findCheckbox('Buy groceries').first);
    await tester.pump();

    // Task still visible but now completed (strikethrough)
    expect(find.text('Buy groceries'), findsOneWidget);
  });

  testWidgets('Filter tabs are visible', (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());

    expect(find.text('All'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
  });

  testWidgets('Completed filter shows only completed tasks',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());

    // Mark 'Buy groceries' as complete
    await tester.tap(findCheckbox('Buy groceries').first);
    await tester.pump();

    // Switch to Completed filter
    await tester.tap(find.text('Completed'));
    await tester.pump();

    expect(find.text('Buy groceries'), findsOneWidget);
    expect(find.text('Read a book'), findsNothing);
  });

  testWidgets('Active filter hides completed tasks',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());

    // Mark 'Buy groceries' as complete
    await tester.tap(findCheckbox('Buy groceries').first);
    await tester.pump();

    // Switch to Active filter
    await tester.tap(find.text('Active'));
    await tester.pump();

    expect(find.text('Buy groceries'), findsNothing);
    expect(find.text('Read a book'), findsOneWidget);
  });
}