# Saha

Saha is a bilingual Flutter prototype for managing health records, daily reminders, and doctor visits.

## Run the demo

```sh
flutter pub get
flutter run
```

Choose **Explore the demo** to open a sample account with scheduled care tasks, a booked visit, and a conversation. Choose **Create account** to test registration with a blank care plan. Switch between English and Arabic from the sign-in screen or Profile.

- **My health** lets you add, edit, and delete conditions and medicines. Enter a time for a daily reminder and, for conditions, write the action you want to remember.
- **Home** shows the day’s care plan and the next appointment. The in-app banner appears when an incomplete reminder is due. Mark tasks complete to update your daily progress.
- **Doctors** lets you search fictional doctors, browse specialties, reserve a sample slot, and cancel upcoming appointments.
- **Messages** shows simulated conversations that return a canned reply.

Accounts and changes are stored in memory for the lifetime of the app process. Reminders use the device’s local time and appear in the app while it is open. This demo is designed for fictional health information.

## Project structure

```text
lib/
  core/
    localization/  English and Arabic strings
    network/       In-memory implementation of the feature data contracts
    theme/         Colors, typography, and component themes
    widgets/       Shared UI components
  feature/
    auth/
    chat/
    doctors/
    health/
    home/
    profile/
```

Each feature has a `model/`, `controller/`, and `view/` directory. GetX controllers own reactive feature state, and views call controller methods for user actions. The feature models define data contracts for accounts, health records, appointments, and chat. `lib/main.dart` wires those contracts to the demo gateway. Firebase integration will add asynchronous data implementations and replace the in-memory wiring.

Run `flutter analyze` and `flutter test` to verify the project.

## Illustration

The built-in image generator created `assets/images/care-heart.png` with the following prompt.

> Use case: illustration-story. Asset: transparent cutout for the right side of a premium bilingual health app card. Render a single cohesive small sculptural still life: an ivory heart with a small deep-green embossed ECG pulse, supported by a polished pale jade rounded plinth with one tiny pale chartreuse medical plus floating nearby. The objects feel like soft matte ceramic with subtle satin highlights, light from upper left. Three-quarter front view, clean modern healthcare product illustration, calm, simple, uncluttered. Center the whole cluster in a square canvas, large enough to read at 120 pixels, isolated on a truly transparent alpha background, very modest contact shadow. No people, letters, numbers, watermark, text, or opaque floor.
