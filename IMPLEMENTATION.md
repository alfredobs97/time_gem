# Implementation Plan: time_gem Onboarding

This document outlines the phased implementation plan for the `time_gem` application, focusing initially on the onboarding flow with BLoC state management and calendar integration options.

## Phases

### Phase 1: Project Setup and Initial Commit

- [ ] Update the `pubspec.yaml` file:
    - Set the `description` to "A time management app with AI-powered task scheduling and calendar integration."
    - Set the `version` to `0.1.0`.
    - Add `flutter_bloc`, `bloc`, `google_sign_in`, `googleapis`, `sqflite` as dependencies.
- [ ] Update the `README.md` file with a short placeholder description: "time_gem: Your intelligent time management companion."
- [ ] Create a `CHANGELOG.md` file with the initial version `0.1.0` and a brief entry.
- [ ] Commit this initial, empty version of the package to the `main` branch with a suitable commit message.
- [ ] After committing, start the app using the `launch_app` tool on the user's preferred device.

### Phase 2: Implement Onboarding UI (Welcome Screen)

- [ ] Create the `WelcomeScreen` widget.
- [ ] Design the UI for the `WelcomeScreen` to introduce the app's purpose.
- [ ] Add navigation to the `CalendarIntegrationScreen`.
- [ ] Create unit tests for the `WelcomeScreen` (if applicable, e.g., for any simple logic).

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

- [ ] Connect the `CalendarBloc` to the `WelcomeScreen` and `CalendarIntegrationScreen` using `BlocProvider` and `BlocBuilder`.
- [ ] Update the UI to react to states emitted by the `CalendarBloc` (e.g., loading, authenticated, error).
- [ ] Ensure proper navigation based on the calendar integration status.
- [ ] Create widget tests for the integrated onboarding flow.

### Phase 7: Finalization and Documentation

- [ ] Create a comprehensive `README.md` file for the package, detailing its purpose, features, and how to run it.
- [ ] Create a `GEMINI.md` file in the project directory that describes the app, its purpose, and implementation details of the application and the layout of the files.
- [ ] Ask the user to inspect the app and the code and say if they are satisfied with it, or if any modifications are needed.

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

This section will be updated after each phase with a log of actions taken, things learned, surprises, and deviations from the plan. It will be in chronological order.
