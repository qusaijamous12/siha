import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medicine_app/main.dart';
import 'package:medicine_app/feature/doctors/view/doctor_widgets.dart';

void main() {
  Future<void> openApp(WidgetTester tester, {DateTime Function()? now}) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      SahaApp(now: now ?? () => DateTime(2026, 11, 14, 10)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder target) async {
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Finder tab(String label) => find.widgetWithText(NavigationDestination, label);
  Finder field(String label) => find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.labelText == label,
  );

  testWidgets('Demo supports English and Arabic with RTL layout', (
    tester,
  ) async {
    await openApp(tester);
    await tap(tester, find.text('العربية'));
    final demo = find.text('استكشف النسخة التجريبية');
    expect(Directionality.of(tester.element(demo)), TextDirection.rtl);
    await tap(tester, demo);
    expect(find.text('مرحباً، نور'), findsOneWidget);
    await tap(tester, tab('حسابي'));
    await tap(tester, find.text('English'));
    await tap(tester, tab('Home'));
    expect(find.text('Hello, Noor'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Registers, adds a condition and medicine, and signs in again', (
    tester,
  ) async {
    var now = DateTime(2026, 11, 14, 8, 59, 50);
    await openApp(tester, now: () => now);
    await tap(tester, find.text('Create account'));
    await tester.enterText(field('Full name'), 'Demo Tester');
    await tester.enterText(field('Email address'), 'tester@example.test');
    await tester.enterText(field('Password'), 'example1');
    await tap(tester, find.widgetWithText(FilledButton, 'Create account'));
    expect(find.text('Hello, Demo'), findsOneWidget);

    await tap(tester, find.text('Add condition'));
    await tester.enterText(field('Condition name'), 'Seasonal symptoms');
    await tester.enterText(
      field('What should we remind you to do?'),
      'Log symptoms',
    );
    await tap(tester, find.widgetWithText(FilledButton, 'Save'));
    expect(find.text('Log symptoms'), findsOneWidget);
    expect(find.text('Due'), findsNothing);
    now = DateTime(2026, 11, 14, 9);
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();
    expect(find.text('Care reminder · Log symptoms'), findsOneWidget);
    await tap(tester, find.byTooltip('Mark as done'));
    expect(find.text('1 of 1 tasks complete'), findsOneWidget);
    expect(find.text('Care reminder · Log symptoms'), findsNothing);

    await tap(tester, find.text('Add medicine'));
    await tester.enterText(field('Medicine name'), 'Sample medicine');
    await tester.enterText(field('Dose or instructions'), 'As prescribed');
    await tap(tester, find.widgetWithText(FilledButton, 'Save'));
    expect(find.text('Care reminder · Sample medicine'), findsOneWidget);

    await tap(tester, tab('Profile'));
    await tap(tester, find.text('Sign out'));
    await tester.enterText(field('Email address'), 'tester@example.test');
    await tester.enterText(field('Password'), 'wrong1');
    await tap(tester, find.widgetWithText(FilledButton, 'Sign in'));
    expect(
      find.textContaining('Email or password is incorrect'),
      findsOneWidget,
    );
    await tester.enterText(field('Password'), 'example1');
    await tap(tester, find.widgetWithText(FilledButton, 'Sign in'));
    expect(find.text('Hello, Demo'), findsOneWidget);
    await tap(tester, tab('My health'));
    expect(find.text('Seasonal symptoms'), findsOneWidget);
    await tap(tester, find.text('Medicines'));
    expect(find.text('Sample medicine'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Searches, books, chats, and cancels a demo appointment', (
    tester,
  ) async {
    await openApp(tester);
    await tap(tester, find.text('Explore the demo'));
    await tap(tester, tab('Doctors'));
    await tester.enterText(find.byType(TextFormField), 'Omar');
    await tester.pumpAndSettle();
    expect(find.text('Dr. Lina Haddad'), findsNothing);
    await tap(tester, find.text('Dr. Omar Khalil'));
    await tap(tester, find.text('Book appointment'));
    await tap(tester, find.text('9:30 AM'));
    await tap(tester, find.text('Confirm appointment'));
    expect(find.text('Demo appointment booked'), findsOneWidget);
    await tap(tester, find.text('Message'));
    await tester.enterText(find.byType(TextField), 'Hello from the demo');
    await tester.pumpAndSettle();
    await tap(tester, find.byTooltip('Send message'));
    expect(find.text('Hello from the demo'), findsOneWidget);
    expect(find.textContaining('Thanks for trying the demo'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tap(tester, find.text('Appointments'));
    expect(find.text('Dr. Omar Khalil'), findsOneWidget);
    final visit = find
        .ancestor(
          of: find.text('Dr. Omar Khalil'),
          matching: find.byType(AppointmentTile),
        )
        .first;
    await tap(
      tester,
      find.descendant(
        of: visit,
        matching: find.byTooltip('Cancel appointment'),
      ),
    );
    await tap(tester, find.widgetWithText(FilledButton, 'Cancel appointment'));
    expect(find.text('Dr. Omar Khalil'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
