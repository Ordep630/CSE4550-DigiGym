# CSE4550-DigiGym

## Overview

DigiGym is a mobile fitness application designed to help users plan workouts and meals based on their individual fitness goals and needs. This application provides personalized workout recommendations, meal recommendations, nutritional information, and grocery lists based on information provided by the user.

## Features
  * User Account creation and login
  * User Profile management
  * Fitness level and fitness goal tracking
  * Personalize workout recommendations
  * Meal recommendations
  * Nutritional Information
  * Grocery lists based on meal plans
  * Simple and Accessible mobile interface

## Project Goals

The goal of DigiGym is to provide users with a convenient way to organize their fitness and nutrition planning in one application.

The Application is designed to:
  * Help users create and manage their fitness profiles
  * Recommend workouts based on fitness goals and level
  * Provide meal recommendations
  * Display nutritional information
  * Generate grocery lists from recommended meals
  * Provide an easy-to-use interface for managing fitness and meal plans

## Technology
The technologies used for this project include:
  * Frontend: Flutter
  * Backend: Serverpod 4.0.2
  * Database: PostgreSQL
  * Version Control: Github
  * Development Environment: Visual Studio Code

## Local Development

1. Install Flutter and the Serverpod CLI.
2. Copy `digigym_backend/digigym_backend_server/config/passwords.example.yaml`
   to `passwords.yaml` in the same directory, then replace every placeholder
   with a local secret. The destination file is gitignored.
3. From `digigym_backend/digigym_backend_server`, run `serverpod start`.
4. Run the root Flutter application. The default API URL is
   `http://localhost:8080/`, which works with iOS Simulator and desktop/web
   development.

For an Android emulator, point the app at the host loopback address:

```sh
flutter run --dart-define=SERVER_URL=http://10.0.2.2:8080/
```

For a physical device, replace the URL with the development machine's LAN IP.
Do not commit production URLs, passwords, or other credentials.

Backend tests use an isolated embedded PostgreSQL database. They can use a
process-only test password instead of a credentials file:

```sh
SERVERPOD_DATABASE_PASSWORD=local_test_only dart test
```

## Team Roles

  Team Member | Role
  * Chaya       | Frontend Developer
  * Isaac       | Frontend Integration
  * Genesis     | Backend developer
  * Yoni        | Backend Developer
  * Oscar       | UI/UX & Frontend
  * Danny       | Documentation & Project Planning
  * Shane       | Development & Integration Support
  * Pedro       | Software Project Manager

# Project Status

Current Sprint: Sprint 1
Status: In development

DigiGym is currently in the initial development phase. The team is working on the application prototype, core functionality, UI/UX Design, backend development, frontend integration, and project documentation.
