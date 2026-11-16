import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medicine_app/feature/check_in/view/trend_chart.dart';
import 'package:medicine_app/main.dart';
import 'package:medicine_app/feature/doctors/view/doctor_widgets.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

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

  Future<void> reveal(WidgetTester tester, Finder target) async {
    if (target.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        target,
        180,
        scrollable: find.byType(Scrollable).first,
      );
    }
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder target) async {
    await reveal(tester, target);
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
    await openApp(tester, now: () => DateTime(2026, 11, 14, 13));
    await tap(tester, find.text('العربية'));
    final demo = find.text('استكشف النسخة التجريبية');
    expect(Directionality.of(tester.element(demo)), TextDirection.rtl);
    await tap(tester, demo);
    await tester.enterText(field('قراءة السكر'), '١١٠');
    await tap(tester, find.text('احفظ وقارن'));
    expect(find.text('ضمن النطاق المرجعي العام'), findsOneWidget);
    expect(find.textContaining('القراءة التجريبية السابقة'), findsOneWidget);
    await tap(tester, find.text('تابع إلى التطبيق'));
    expect(find.text('مرحباً، نور'), findsOneWidget);
    expect(find.text('إضافة حالة'), findsNothing);
    expect(find.textContaining('سجّل أعراض الحساسية'), findsNothing);
    await tap(tester, find.byTooltip('التذكيرات'));
    expect(find.textContaining('سجّل أعراض الحساسية'), findsNothing);
    expect(find.text('دواء الصباح'), findsOneWidget);
    expect(find.text('دواء المساء'), findsOneWidget);
    await tap(tester, find.byTooltip('رجوع'));
    await tap(tester, tab('حسابي'));
    await tap(tester, find.text('English'));
    await tap(tester, tab('Home'));
    expect(find.text('Hello, Noor'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Saves tracked conditions and keeps manual medicine reminders', (
    tester,
  ) async {
    var now = DateTime(2026, 11, 14, 8, 59, 50);
    await openApp(tester, now: () => now);
    await tap(tester, find.text('Create account'));
    await tester.enterText(field('Full name'), 'Demo Tester');
    await tester.enterText(field('Email address'), 'tester@example.test');
    await tester.enterText(field('Password'), 'example1');
    await tap(tester, find.widgetWithText(FilledButton, 'Create account'));
    await tap(tester, find.text('Skip for now'));
    expect(find.text('Hello, Demo'), findsOneWidget);

    await tap(tester, tab('My health'));
    expect(find.text('Add condition'), findsNothing);
    await tap(tester, find.text('Health check-in'));
    expect(find.byType(FilterChip), findsNWidgets(2));
    await tap(tester, find.text('Diabetes'));
    await tap(tester, find.text('High blood pressure'));
    await tap(tester, find.text('Save condition selection'));
    expect(find.text('Diabetes · High blood pressure'), findsOneWidget);
    await tap(tester, tab('Home'));

    await tap(tester, find.text('Add medicine'));
    await tester.enterText(field('Medicine name'), 'Sample medicine');
    await tester.enterText(field('Dose or instructions'), 'As prescribed');
    await tap(tester, find.widgetWithText(FilledButton, 'Save'));
    expect(find.text('Sample medicine'), findsOneWidget);
    expect(find.text('Due'), findsNothing);
    now = DateTime(2026, 11, 14, 9);
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();
    expect(find.text('Care reminder · Sample medicine'), findsOneWidget);
    await tap(tester, find.byTooltip('Mark as done'));
    expect(find.text('1 of 1 tasks complete'), findsOneWidget);
    expect(find.text('Care reminder · Sample medicine'), findsNothing);

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
    await tap(tester, find.text('Skip for now'));
    expect(find.text('Hello, Demo'), findsOneWidget);
    await tap(tester, tab('My health'));
    expect(find.text('Diabetes · High blood pressure'), findsOneWidget);
    expect(find.text('Sample medicine'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Searches, books, chats, and cancels a demo appointment', (
    tester,
  ) async {
    await openApp(tester);
    await tap(tester, find.text('Explore the demo'));
    await tap(tester, find.text('Skip for now'));
    await tap(tester, tab('Doctors'));
    await tap(tester, find.widgetWithText(ChoiceChip, 'Physical therapy'));
    expect(find.text('Dr. Omar Khalil'), findsNothing);
    await tap(tester, find.text('Maya Awad, Physiotherapist'));
    await tap(tester, find.text('Book appointment'));
    await tap(tester, find.text('11:00 AM'));
    await tap(tester, find.text('Confirm appointment'));
    expect(find.text('Demo appointment booked'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tap(tester, find.text('All'));
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
  testWidgets(
    'Compares readings after restart and prompts again on foreground',
    (tester) async {
      await openApp(tester);
      await tap(tester, find.text('Create account'));
      await tester.enterText(field('Full name'), 'Check In');
      await tester.enterText(field('Email address'), 'checkin@example.test');
      await tester.enterText(field('Password'), 'test1234');
      await tap(tester, find.widgetWithText(FilledButton, 'Create account'));
      expect(find.text('Log your readings'), findsOneWidget);
      await tap(tester, find.text('Diabetes'));
      await tap(tester, find.text('High blood pressure'));
      await tester.enterText(field('Glucose reading'), '١٥٠');
      await tester.ensureVisible(field('Systolic (top number)'));
      await tester.enterText(field('Systolic (top number)'), '142');
      await tester.ensureVisible(field('Diastolic (bottom number)'));
      await tester.enterText(field('Diastolic (bottom number)'), '92');
      await tap(tester, find.text('Save and compare'));
      expect(
        find.text('This is your first reading of this kind.'),
        findsWidgets,
      );
      await tap(tester, find.text('Continue to the app'));

      await tester.pumpWidget(const SizedBox.shrink());
      await openApp(tester, now: () => DateTime(2026, 11, 15, 10));
      expect(find.text('Log your readings'), findsOneWidget);
      await tester.enterText(field('Glucose reading'), '115');
      await tester.ensureVisible(field('Systolic (top number)'));
      await tester.enterText(field('Systolic (top number)'), '121');
      await tester.ensureVisible(field('Diastolic (bottom number)'));
      await tester.enterText(field('Diastolic (bottom number)'), '80');
      await tap(tester, find.text('Save and compare'));
      expect(find.text('Systolic (top number): down 21 mmHg'), findsOneWidget);
      expect(
        find.text('Diastolic (bottom number): down 12 mmHg'),
        findsOneWidget,
      );
      expect(find.text('Large change from the previous entry'), findsOneWidget);
      await reveal(tester, find.text('Within general reference range'));
      expect(find.text('Blood sugar: down 35 mg/dL'), findsOneWidget);
      await tap(tester, find.text('Continue to the app'));
      await tap(tester, tab('My health'));
      await tap(tester, find.text('Condition trends'));
      final chart = find.byType(TrendChart);
      expect(
        tester
            .widget<TrendChart>(chart)
            .points
            .map((point) => point.values.single),
        [150, 115],
      );
      await tap(tester, find.text('Blood pressure'));
      expect(
        tester.widget<TrendChart>(chart).points.map((point) => point.values),
        [
          [142, 92],
          [121, 80],
        ],
      );
      await tester.pageBack();
      await tester.pumpAndSettle();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.text('Log your readings'), findsOneWidget);
      await tap(tester, find.text('2 hours after starting a meal'));
      await tester.enterText(field('Glucose reading'), '160');
      await tap(tester, find.text('Save and compare'));
      expect(
        find.text('This is your first reading of this kind.'),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('Shows different guidance for high and severely high readings', (
    tester,
  ) async {
    await openApp(tester);
    await tap(tester, find.text('Explore the demo'));

    Future<void> submit(String glucose, String upper, String lower) async {
      await tester.enterText(field('Glucose reading'), glucose);
      await tester.ensureVisible(field('Systolic (top number)'));
      await tester.enterText(field('Systolic (top number)'), upper);
      await tester.ensureVisible(field('Diastolic (bottom number)'));
      await tester.enterText(field('Diastolic (bottom number)'), lower);
      await tap(tester, find.text('Save and compare'));
    }

    await submit('195', '155', '95');
    expect(find.textContaining('Drink plain water'), findsOneWidget);
    await reveal(tester, find.textContaining('measure again'));
    expect(find.textContaining('measure again'), findsOneWidget);
    expect(find.textContaining('foods with less salt'), findsOneWidget);
    await tap(tester, find.text('Continue to the app'));
    await tap(tester, tab('My health'));
    await tap(tester, find.text('Health check-in'));
    await submit('325', '192', '124');
    expect(find.textContaining('Seek emergency care'), findsOneWidget);
    await reveal(tester, find.textContaining('call local emergency services'));
    expect(
      find.textContaining('call local emergency services'),
      findsOneWidget,
    );
    expect(find.textContaining('foods with less salt'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
