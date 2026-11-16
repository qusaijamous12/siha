# Saha

Saha is a bilingual Flutter prototype for managing health records, daily reminders, and doctor visits.

## Run the demo

```sh
flutter pub get
flutter run
```

Choose **Explore the demo** to open a sample account with scheduled care tasks, a booked visit, and a conversation. Choose **Create account** to test registration with a blank care plan. Switch between English and Arabic from the sign-in screen or Profile.

- **My health** lets you track diabetes and high blood pressure and add, edit, and delete medicines. Enter a time for a daily medicine reminder.
- **Home** shows the day’s care plan and the next appointment. The in-app banner appears when an incomplete reminder is due. Mark tasks complete to update your daily progress.
- **Doctors** lets you search fictional doctors, browse specialties, reserve a sample slot, and cancel upcoming appointments.
- **Messages** shows simulated conversations that return a canned reply.

**Health check-in** opens after sign-in and when the app returns from the background. Select diabetes, high blood pressure, or both. The app compares each measurement with the last reading of its kind. Blood sugar comparisons use the same meal timing. The demo account starts with labeled sample readings. You can skip the screen or reopen it from **My health**.

The prototype saves demo accounts, the sign-in session, tracked conditions, and their check-in histories in secure storage on the device. Other changes last for the lifetime of the app process. Reminders use the device’s local time and appear in the app while it is open. This demo is designed for fictional health information.

**Condition trends** (under **My health**) charts the most recent 30 entries per series. Blood sugar has separate before- and after-meal series, and blood pressure shows systolic and diastolic values. The demo flags changes of at least 30 mg/dL for glucose, 20 mmHg systolic or 10 mmHg diastolic for pressure. These are demo thresholds for highlighting changes to review. The check-in shows general reference ranges and different guidance for high and severely high readings. For non-urgent high readings, it includes hydration guidance for blood sugar and remeasurement and low-salt food guidance for blood pressure. See [CDC blood sugar guidance](https://www.cdc.gov/diabetes/treatment/index.html), [AHA home pressure monitoring](https://www.heart.org/en/health-topics/high-blood-pressure/understanding-blood-pressure-readings/monitoring-your-blood-pressure-at-home), and [AHA guidance on salt](https://www.heart.org/en/health-topics/high-blood-pressure/changes-you-can-make-to-manage-high-blood-pressure/shaking-the-salt-habit-to-lower-high-blood-pressure).

The doctor directory includes a fictional physical therapist with bookable demo appointments.

## Project structure

```text
lib/
  core/
    localization/  English and Arabic strings
    network/       In-memory data for care plans, appointments, and messages
    storage/       On-device demo accounts and check-in readings
    theme/         Colors, typography, and component themes
    widgets/       Shared UI components
  feature/
    auth/
    chat/
    check_in/
    doctors/
    health/
    home/
    profile/
```

Each feature has a `model/`, `controller/`, and `view/` directory. GetX controllers own reactive feature state, and views call controller methods for user actions. The feature models define data contracts for accounts, check-in readings, health records, appointments, and chat. `lib/main.dart` wires those contracts to the demo data and secure local storage. Firebase integration can replace those implementations.

Run `flutter analyze` and `flutter test` to verify the project.

The check-in labels use general adult references and are for a demo with fictional readings. See [CDC blood sugar targets](https://www.cdc.gov/diabetes/treatment/index.html), [CDC guidance on low blood sugar](https://www.cdc.gov/diabetes/treatment/treatment-low-blood-sugar-hypoglycemia.html), [CDC guidance on diabetic ketoacidosis](https://www.cdc.gov/diabetes/about/diabetic-ketoacidosis.html), [AHA blood pressure categories](https://www.heart.org/en/health-topics/high-blood-pressure/understanding-blood-pressure-readings), and [AHA guidance on low blood pressure](https://www.heart.org/en/health-topics/high-blood-pressure/the-facts-about-high-blood-pressure/low-blood-pressure-when-blood-pressure-is-too-low).

## Illustration

The built-in image generator created `assets/images/care-heart.png` with the following prompt.

> Use case: illustration-story. Asset: transparent cutout for the right side of a premium bilingual health app card. Render a single cohesive small sculptural still life: an ivory heart with a small deep-green embossed ECG pulse, supported by a polished pale jade rounded plinth with one tiny pale chartreuse medical plus floating nearby. The objects feel like soft matte ceramic with subtle satin highlights, light from upper left. Three-quarter front view, clean modern healthcare product illustration, calm, simple, uncluttered. Center the whole cluster in a square canvas, large enough to read at 120 pixels, isolated on a truly transparent alpha background, very modest contact shadow. No people, letters, numbers, watermark, text, or opaque floor.
