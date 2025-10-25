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
- [ ] Create unit tests for the onboarding screens (if applicable).

### Phase 3: Implement Onboarding UI (Calendar Integration Screen)

- [ ] Create the `CalendarIntegrationScreen` widget.
- [ ] Design the UI for the `CalendarIntegrationScreen` with options to "Connect Google Calendar" and "Continue without connecting".
- [ ] Implement the warning message/dialog for users who choose to "Continue without connecting".
- [ ] Add navigation logic based on user choice.
- [ ] Create unit tests for the `CalendarIntegrationScreen`.

### Phase 4: Implement Google Calendar Integration Logic

- [ ] Create a `CalendarBloc` to manage the state of calendar integration.
- [ ] Implement the Google Sign-In logic within the `CalendarBloc`.
- [ ] Handle requesting calendar permissions.
- [ ] Implement the logic to fetch Google Calendar events using `googleapis`.
- [ ] Create unit tests for the `CalendarBloc` and calendar integration services.

### Phase 5: Implement Local Calendar Logic

- [ ] Create a local calendar service using `sqflite` for storing and retrieving events.
- [ ] Integrate the local calendar service with the `CalendarBloc` for users who opt out of Google Calendar.
- [ ] Create unit tests for the local calendar service.

### Phase 6: Integrate BLoC with UI

- [ ] Connect the `CalendarBloc` to the onboarding screens using `BlocProvider` and `BlocBuilder`.
- [ ] Update the UI to react to states emitted by the `CalendarBloc` (e.g., loading, authenticated, error).
- [ ] Ensure proper navigation based on the calendar integration status.
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