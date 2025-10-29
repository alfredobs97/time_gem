# Implementation Plan: time_gem Onboarding

This document outlines the phased implementation plan for the `time_gem` application, focusing initially on the onboarding flow with BLoC state management and calendar integration options.

## Phases

### Phase 1: Project Setup and Initial Commit

- [x] Create a new empty Flutter project named `time_gem` in the `/Users/alfredo/Documents/time_gem` directory.
- [x] Remove any boilerplate code or files that will be replaced by the onboarding implementation, including the `test` directory.
- [x] Update the `pubspec.yaml` file:
    - Set the `description` to "A time management app with AI-powered task scheduling and calendar integration."
    - Set the `version` to `0.1.0`.
    - Add `flutter_bloc`, `bloc`, `google_sign_in`, `googleapis`, `sqflite` as dependencies.
- [x] Update the `README.md` file with a short placeholder description: "time_gem: Your intelligent time management companion."
- [x] Create a `CHANGELOG.md` file with the initial version `0.1.0` and a brief entry.
- [x] Commit this initial, empty version of the package to the `main` branch with a suitable commit message.
- [x] After committing, start the app using the `launch_app` tool on the user's preferred device.

### Phase 2: Implement Onboarding UI

- [x] Create the `WelcomeScreen` widget.
- [x] Create the `AppGoalScreen` widget to explain the app's purpose.
- [x] Design the UI for the onboarding screens.
- [x] Add navigation between `WelcomeScreen`, `AppGoalScreen`, and `CalendarIntegrationScreen`.
- [x] Create unit tests for the onboarding screens (if applicable).

### Phase 3: Implement Onboarding UI (Calendar Integration Screen)

- [x] Create the `CalendarIntegrationScreen` widget.
- [x] Design the UI for the `CalendarIntegrationScreen` with options to "Connect Google Calendar" and "Continue without connecting".
- [x] Implement the warning message/dialog for users who choose to "Continue without connecting".
- [x] Add navigation logic based on user choice.
- [x] Changed the warning dialog to a modal bottom sheet.
- [x] Create unit tests for the `CalendarIntegrationScreen`.

### Phase 4: Implement Google Calendar Integration Logic

- [x] Create a `CalendarBloc` to manage the state of calendar integration.
- [x] Implement the Google Sign-In logic within the `CalendarBloc`.
- [x] Handle requesting calendar permissions.
- [x] Implement the logic to fetch Google Calendar events using `googleapis`.
- [x] Create unit tests for the `CalendarBloc` and calendar integration services. (Skipped as per user instruction)

### Phase 5: Implement Local Calendar Logic

- [x] Create a local calendar service using `sqflite` for storing and retrieving events.
- [x] Integrate the local calendar service with the `CalendarBloc` for users who opt out of Google Calendar.
- [x] Create unit tests for the local calendar service.

### Phase 6: Integrate BLoC with UI

- [x] Connect the `CalendarBloc` to the onboarding screens using `BlocProvider` and `BlocBuilder`.
- [x] Update the UI to react to states emitted by the `CalendarBloc` (e.g., loading, authenticated, error).
- [x] Ensure proper navigation based on the calendar integration status.
- [ ] Create widget tests for the integrated onboarding flow.

### Phase 7: Finalization and Documentation

- [ ] Create a comprehensive `README.md` file for the package.
- [ ] Create a `GEMINI.md` file in the project directory.
- [ ] Ask the user for final review.

## Post-Phase Checklist

After completing each phase:

- [ ] Create/modify unit tests for testing the code added or modified in this phase, if relevant.
- [ ] Run the `dart_fix` tool to clean up the code.
- [ ] Run the `analyze_files` tool one more time and fix any issues.
- [ ] Run any tests to make sure they all pass.
- [ ] Run `dart_format` to make sure that the formatting is correct.
- [ ] Re-read the `IMPLEMENTATION.md` file to see what, if anything, has changed in the implementation plan, and if it has changed, take care of anything the changes imply.
- [ ] Update the `IMPLEMENTATION.md` file with the current state, including any learnings, surprises, or deviations in the Journal section. Check off any checkboxes of items that have been completed.
- [ ] Use `git diff` to verify the changes that have been made, and create a suitable commit message for any changes, following any guidelines you have about commit messages. Be sure to properly escape dollar signs and backticks, and present the change message to the user for approval.
- [ ] Wait for approval. Don't commit the changes or move on to the next phase of implementation until the user approves the commit.
- [ ] After committing the change, if the app is running, use the `hot_reload` tool to reload it.

## Journal

### Phase 1: Project Setup and Initial Commit

**Actions Taken:**
- Created an empty Flutter project using `fvm exec flutter create --empty .`.
- Removed the `test` directory.
- Updated `pubspec.yaml` with description, version, and dependencies.
- Updated `README.md` and created `CHANGELOG.md`.
- Initialized Git repository and committed changes.
- User confirmed the app is running.

**Learnings:**
- Resolved a Dart SDK version mismatch using FVM.

**Surprises:**
- The project was not a Git repository initially.

**Deviations from Plan:**
- None.

### Phase 2: Implement Onboarding UI

**Actions Taken:**
- Created `lib/welcome_screen.dart`.
- Created `lib/app_goal_screen.dart` to explain the app's purpose, as requested by the user.
- Created `lib/calendar_integration_screen.dart`.
- Implemented the UI for the onboarding screens.
- Updated navigation flow: `WelcomeScreen` -> `AppGoalScreen` -> `CalendarIntegrationScreen`.

**Learnings:**
- Adapting the plan to include an extra screen is straightforward.

**Surprises:**
- None.

**Deviations from Plan:**
- Added an `AppGoalScreen` to the onboarding flow based on user feedback.
- Skipped `fvm exec flutter analyze` as requested by the user.

### Phase 3: Implement Onboarding UI (Calendar Integration Screen)

**Actions Taken:**
- Created `lib/main_app_screen.dart` as a placeholder for the main application screen.
- Updated `lib/calendar_integration_screen.dart` to include a warning dialog for local calendar usage and navigation to `MainAppScreen`.
- Changed the warning dialog to a modal bottom sheet for a better user experience.

**Learnings:**
- Implementing a dialog for user choice provides a clear user experience for calendar integration.
- Modal bottom sheets offer a more modern and less intrusive way to present contextual information and choices to the user compared to traditional dialogs.

**Surprises:**
- None.

**Deviations from Plan:**
- Skipped unit tests for `CalendarIntegrationScreen` for now, as per the user's instruction to focus on implementation.
- Replaced `AlertDialog` with `showModalBottomSheet` for the warning message, as requested by the user.

### Phase 4: Implement Google Calendar Integration Logic

**Actions Taken:**
- Created `lib/calendar_bloc` directory.
- Created `lib/calendar_bloc/calendar_event.dart` with `sealed class`.
- Created `lib/calendar_bloc/calendar_state.dart` with `sealed class`.
- Created `lib/calendar_bloc/calendar_bloc.dart` with basic `CalendarBloc` implementation for Google Sign-In/Sign-Out.
- Updated `CalendarBloc` to request calendar permissions.
- Added `FetchCalendarEvents` event and `CalendarEventsLoaded` state.
- Implemented logic to fetch calendar events from the Google Calendar API.
- Updated `MainAppScreen` to display fetched events and trigger fetching.
- Updated `CalendarIntegrationScreen` to handle sign-out navigation.

**Learnings:**
- The `sealed class` keyword in Dart 3.0 provides excellent type safety and exhaustiveness checking for BLoC events and states.
- Using an extension on `GoogleSignIn` can simplify the process of getting an authenticated client for `googleapis`.

**Surprises:**
- None.

**Deviations from Plan:**
- None.

### Phase 5: Implement Local Calendar Logic

**Actions Taken:**
- Created `lib/local_calendar` directory and `lib/local_calendar/local_calendar_service.dart`.
- Created `lib/models/calendar_event.dart` for a unified event model.
- Refactored `LocalCalendarService` to use `CalendarEvent` and decoupled the entity from the service.
- Integrated `LocalCalendarService` with `CalendarBloc`.
- Updated `main.dart` to provide `LocalCalendarService` to `CalendarBloc`.
- Created `test/local_calendar` directory and `test/local_calendar/local_calendar_service_test.dart`.
- Added `sqflite_common_ffi` as a dev dependency.
- Modified `DatabaseHelper` to allow injecting a database for testing.
- Successfully ran unit tests for `LocalCalendarService`.

**Learnings:**
- Decoupling data models from services improves maintainability and testability.
- Using `sqflite_common_ffi` for in-memory database testing is effective for local storage logic.
- Injecting dependencies (like the database) into services is crucial for robust unit testing.

**Surprises:**
- Initial test failures due to `_database` accessibility in `DatabaseHelper` required refactoring for testability.

**Deviations from Plan:**
- None.

### Phase 6: Integrate BLoC with UI

**Actions Taken:**
- Provided the `CalendarBloc` to the widget tree in `main.dart` using `BlocProvider`.
- Updated `CalendarIntegrationScreen` to use `BlocConsumer` to dispatch events and react to state changes from the `CalendarBloc`.

**Learnings:**
- `BlocConsumer` is a powerful widget for handling both UI building and side-effects (like navigation or showing snackbars) in response to BLoC state changes.

**Surprises:**
- None.

**Deviations from Plan:**
- None.