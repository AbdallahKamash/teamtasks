<p align="center">
  <h1 align="center">🚀 TeamTasks</h1>
  <p align="center">
    <strong>A collaborative workspace & task management app built with Flutter and Firebase</strong>
  </p>
  <p align="center">
    <a href="#features">Features</a> •
    <a href="#tech-stack">Tech Stack</a> •
    <a href="#architecture">Architecture</a> •
    <a href="#getting-started">Getting Started</a> •
    <a href="#project-structure">Project Structure</a> •
    <a href="#data-models">Data Models</a>
  </p>
</p>

---

## 📋 Overview

**TeamTasks** is a cross-platform mobile application that empowers teams to collaborate efficiently through shared workspaces, task assignment workflows, role-based permissions, and real-time notifications. Designed with an Arabic-first UI (RTL layout), it provides a seamless experience for creating workspaces, managing team members, assigning and reviewing tasks, and tracking progress — all in real-time.

> **Status:** 🟡 Active Development — Core features are fully implemented. Additional polish and features are being added.

---

## ✨ Features

### 🔐 Authentication
- **Email & Password** sign-up and sign-in via Firebase Auth
- **Email Verification** — users must verify their email before accessing the app
- **Forgot Password** — password reset flow via email
- **User Profiles** — display name, profile picture, and date of birth
- **Profile Editing** — update display name, avatar, and personal info

### 🏢 Workspaces
- **Create Workspaces** — custom name, description, color, and logo
- **Edit & Delete Workspaces** — full CRUD with cascading cleanup
- **Workspace Swapper** — animated overlay dropdown to quickly switch between workspaces
- **Workspace Color Coding** — each workspace has a unique color identifier
- **Workspace Scheme** — customizable workspace configuration and role structure

### 👥 Team & Member Management
- **Invite by Email** — send pending assignment invitations to users
- **Accept / Reject Invitations** — users receive and act on workspace invitations
- **Pending Assignment Tracking** — real-time stream of pending invitations
- **Remove Members** — workspace admins can remove team members
- **Role Assignment** — assign and change roles for workspace members

### 🛡️ Role-Based Access Control (RBAC)
- **Granular Permissions** — 14 individual permissions across 5 categories:
  - **Workspace** — edit, delete
  - **Tasks** — add, edit, delete
  - **Messages** — add, edit, delete
  - **Roles** — add, edit, delete
  - **People** — add, edit, delete
- **Custom Roles** — create unlimited roles with any permission combination
- **Default Admin Role** — auto-created with full permissions on workspace creation
- **Admin Detection** — `isAdmin` computed property checks for all-permissions
- **Permission-Gated UI** — UI elements conditionally render based on user permissions

### ✅ Task Management
- **Create Tasks** — title, description, type (normal / suggestion / urgent / very urgent), and assignee
- **Task Types** with priority color coding:
  - 🟢 Normal
  - 🔵 Suggestion
  - 🟠 Urgent
  - 🔴 Very Urgent
- **Task Lifecycle** — full workflow with status tracking:
  - `assigned` → `submitted_for_review` → `under_review` → `completed` / `rejected`
- **Submit for Review** — workers submit completed tasks to a reviewer
- **Approve / Reject Tasks** — reviewers approve or reject with reasons
- **Reassign Tasks** — reassign tasks to different team members
- **Delete Tasks** — remove tasks with confirmation dialog
- **Task Metadata** — tracks submission timestamps, rejection reasons, reviewer info, and completion dates

### 📬 Notifications
- **Real-Time Notifications** — powered by Firestore real-time streams
- **Notification Types:**
  - `task_assigned` — when a new task is assigned
  - `task_submitted` — when a task is submitted for review
  - `task_approved` — when a task is completed
  - `task_rejected` — when a submitted task is rejected
- **Notification Badge** — animated icon with unread indicator on the app bar
- **Notification Detail Screen** — drill into individual notifications and pending assignments

### 📊 Dashboard Views
- **My Tasks** — tasks where the current user is the worker
- **Assigned Tasks** — tasks created by / assigned to the current user
- **Task History** — completed tasks (deduplicated across created & assigned)
- **Workspace Settings** — workspace configuration panel (permission-gated)

### 🎨 UI / UX
- **Arabic-First RTL Layout** — full right-to-left support throughout the app
- **Custom Typography** — Alexandria font family
- **Animated Page Transitions** — slide transitions with configurable direction via `GoRouter`
- **Workspace Swapper Animation** — expand/collapse overlay with smooth size transitions
- **Bottom Navigation Bar** — 4-tab navigation (My Tasks, Assigned, History, Settings)
- **Floating Action Button** — context-aware FAB for task creation
- **App Drawer** — side navigation with user info and workspace actions
- **Marquee Text** — auto-scrolling text for long workspace names
- **Material 3 Design** — `useMaterial3: true` with refined splash and highlight behavior

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | [Flutter](https://flutter.dev) (Dart SDK ^3.10.4) |
| **State Management** | [Riverpod](https://riverpod.dev) v3 (`flutter_riverpod`, `hooks_riverpod`, `riverpod_annotation`) |
| **Code Generation** | [Freezed](https://pub.dev/packages/freezed) + [JSON Serializable](https://pub.dev/packages/json_serializable) + [Riverpod Generator](https://pub.dev/packages/riverpod_generator) |
| **Routing** | [GoRouter](https://pub.dev/packages/go_router) v17 with custom slide transitions |
| **Backend** | [Firebase](https://firebase.google.com) (Auth, Cloud Firestore) |
| **Reactive Streams** | [RxDart](https://pub.dev/packages/rxdart) (`switchMap`, `combineLatest`) |
| **Local Storage** | [SharedPreferences](https://pub.dev/packages/shared_preferences) |
| **UI Utilities** | [dropdown_button2](https://pub.dev/packages/dropdown_button2), [flutter_colorpicker](https://pub.dev/packages/flutter_colorpicker), [intl](https://pub.dev/packages/intl) |
| **Platforms** | Android, iOS, macOS, Web |

---

## 🏗️ Architecture

TeamTasks follows a **feature-first** architecture with a clear separation of concerns:

```
┌───────────────────────────────────────────┐
│                 UI Layer                  │
│  (Screens, Components, Widgets)           │
├───────────────────────────────────────────┤
│            State Management               │
│  (Riverpod Providers + Notifiers)         │
├───────────────────────────────────────────┤
│            Repository Layer               │
│  (AuthRepo, WorkspaceRepo)                │
├───────────────────────────────────────────┤
│              Data Layer                   │
│  (Freezed Models, JSON Serialization)     │
├───────────────────────────────────────────┤
│          Firebase Services                │
│  (Firebase Auth, Cloud Firestore)         │
└───────────────────────────────────────────┘
```

### Key Patterns
- **Repository Pattern** — `AuthRepo` and `WorkspaceRepo` encapsulate all Firebase interactions
- **Code Generation** — Freezed for immutable data classes + Riverpod Generator for type-safe providers
- **Reactive Streams** — Real-time Firestore `snapshots()` piped through RxDart operators for complex queries
- **GoRouter + Auth Redirect** — Centralized redirect logic handles auth state, email verification, and route guarding
- **Permission-Gated UI** — Widgets observe `currentUserPermissionsProvider` to show/hide features dynamically

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** — ^3.10.4 ([Installation Guide](https://docs.flutter.dev/get-started/install))
- **Dart SDK** — Included with Flutter
- **Firebase CLI** — For project configuration ([Install Firebase CLI](https://firebase.google.com/docs/cli))
- **A Firebase Project** — With Authentication and Cloud Firestore enabled

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/AbdallahKamash/teamtasks.git
   cd teamtasks
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**

   This project uses the FlutterFire CLI for Firebase configuration. You need to set up your own Firebase project:

   ```bash
   # Install FlutterFire CLI (if not already installed)
   dart pub global activate flutterfire_cli

   # Configure Firebase for your project
   flutterfire configure
   ```

   > **Note:** The `firebase_options.dart` file is gitignored. You must generate your own by running the command above.

4. **Enable Firebase Services:**
   - Go to the [Firebase Console](https://console.firebase.google.com)
   - Enable **Authentication** → Email/Password provider
   - Enable **Cloud Firestore** and set up security rules

5. **Run code generation:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

6. **Run the app:**
   ```bash
   flutter run
   ```

### Firestore Data Structure

```
├── users/
│   └── {uid}
│       ├── email: String
│       ├── displayName: String
│       ├── pfp: String
│       ├── dob: Timestamp
│       └── createdAt: Timestamp
│
├── workspaces/
│   └── {workspaceId}
│       ├── name: String
│       ├── color: String (hex)
│       ├── description: String?
│       ├── logoUrl: String?
│       ├── roles: Map<roleId, roleName>
│       ├── scheme: Map?
│       ├── rolePermissions: Map<roleId, Map<permKey, bool>>
│       ├── createdAt: DateTime
│       └── members/ (subcollection)
│           └── {uid}
│               ├── uid: String
│               ├── email: String
│               ├── displayName: String
│               ├── roleId: String?
│               ├── pfp: String?
│               └── joinedAt: DateTime
│
├── users_workspaces/
│   └── {uid}
│       └── workspaces: [{ workspaceId: String }]
│
├── tasks/
│   └── {taskId}
│       ├── workspaceId: String
│       ├── title: String
│       ├── description: String
│       ├── type: "normal" | "suggestion" | "urgent" | "very_urgent"
│       ├── assigneeId: String?
│       ├── workerId: String?
│       ├── creatorId: String
│       ├── status: "assigned" | "submitted_for_review" | "under_review" | "completed" | "rejected"
│       ├── meta: Map? (comments, reasons, timestamps)
│       └── createdAt: DateTime
│
├── pending_assignments/
│   └── {assignmentId}
│       ├── workspaceId: String
│       ├── inviterName: String
│       ├── inviterId: String
│       ├── roleId: String
│       ├── email: String
│       ├── inviteeId: String?
│       └── createdAt: DateTime
│
└── notifications/
    └── {notificationId}
        ├── userId: String
        ├── workspaceId: String
        ├── title: String
        ├── body: String
        ├── type: "task_assigned" | "task_submitted" | "task_approved" | "task_rejected"
        ├── relatedId: String?
        ├── createdAt: Timestamp
        └── isRead: bool
```

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point, Firebase init, theming
├── firebase_options.dart              # Auto-generated Firebase config (gitignored)
├── nav_prov.dart                      # Bottom navigation index provider
│
├── auth/                              # Authentication layer
│   ├── auth_repo.dart                 # Firebase Auth + Firestore user operations
│   ├── auth_prov.dart                 # Auth state providers
│   ├── login_ctrl.dart                # Login controller (Riverpod)
│   ├── signup_ctrl.dart               # Sign-up controller (Riverpod)
│   └── shared_pref_provider.dart      # SharedPreferences provider
│
├── models/                            # Data models
│   ├── user_model.dart                # User (Freezed + TimestampConverter)
│   ├── workspace_model.dart           # Workspace (Freezed)
│   ├── workspace_member_model.dart    # Workspace member (Freezed)
│   ├── task_model.dart                # Task with lifecycle statuses
│   ├── notification_model.dart        # In-app notification
│   ├── pending_assignment_model.dart  # Workspace invitation (Freezed)
│   └── permissions_model.dart         # Nested RBAC permissions
│
├── workspace/                         # Workspace business logic
│   ├── workspace_repo.dart            # All Firestore workspace/task/notification operations
│   └── workspace_prov.dart            # Workspace, member, permission, and task providers
│
├── router/                            # Navigation
│   ├── router.dart                    # GoRouter config with auth redirect + all routes
│   └── router_ani.dart                # Custom slide page transitions
│
├── components/                        # Reusable UI components
│   ├── app_drawer.dart                # Side navigation drawer
│   ├── bottom_navbar.dart             # Bottom navigation bar (permission-aware)
│   ├── my_textfield.dart              # Custom styled text field
│   ├── workspace_button.dart          # Workspace action button
│   └── workspace_swapper.dart         # Animated workspace switcher overlay
│
└── screens/                           # Application screens
    ├── auth/
    │   ├── launch_screen.dart         # Splash / launch screen
    │   ├── auth_screen.dart           # Login & sign-up form
    │   ├── verify_email_screen.dart   # Email verification flow
    │   ├── forgot_password_screen.dart # Password reset
    │   └── marquee_text.dart          # Auto-scrolling text widget
    │
    ├── home/
    │   ├── main_page.dart             # Main scaffold with PageView + AppBar
    │   ├── my_tasks_screen.dart       # Current user's worker tasks
    │   ├── assigned_tasks_screen.dart # Tasks assigned by current user
    │   ├── task_history_screen.dart   # Completed tasks history
    │   ├── workspace_settings.dart    # Workspace config panel
    │   ├── notifications_screen.dart  # All notifications + pending invitations
    │   ├── notification_detail_screen.dart # Individual notification/invitation detail
    │   └── components/
    │       └── task_view.dart         # Shared task list/card view component
    │
    ├── tasks/
    │   ├── add_task_screen.dart       # Create / edit task form
    │   └── task_detail_screen.dart    # Task detail with lifecycle actions
    │
    ├── workspace/
    │   ├── add_workspace_screen.dart           # Create new workspace
    │   ├── edit_workspace_screen.dart          # Edit workspace details
    │   ├── edit_workspace_scheme_screen.dart   # Configure roles & permissions
    │   ├── workspace_users_screen.dart         # Manage workspace members
    │   └── delete_confirmation_dialog.dart     # Reusable delete confirmation
    │
    └── settings/
        ├── settings_screen.dart       # App settings & account actions
        └── edit_profile_screen.dart   # Edit user profile
```

---

## 📦 Data Models

| Model | Type | Description |
|---|---|---|
| `UserModel` | Freezed | Firebase Auth user with profile fields (uid, email, displayName, pfp, dob) |
| `WorkspaceModel` | Freezed | Workspace with name, color, description, logo, roles, and scheme |
| `WorkspaceMemberModel` | Freezed | User within a workspace context (uid, email, displayName, roleId, joinedAt) |
| `TaskModel` | Manual | Task with full lifecycle (type, status, assignee, creator, meta) |
| `AppNotificationModel` | Manual | In-app notification with type, read status, and related entity |
| `PendingAssignmentModel` | Freezed | Workspace invitation (inviter, invitee email, roleId) |
| `Permissions` | Manual | Nested RBAC model with 5 permission categories and 14 individual permissions |

---

## 🗺️ Routes

| Path | Screen | Auth Required | Description |
|---|---|---|---|
| `/` | `LaunchScreen` | ❌ | Splash screen |
| `/auth` | `AuthScreen` | ❌ | Login / Sign-up |
| `/verify` | `VerifyEmailScreen` | ✅ | Email verification |
| `/forgot-password` | `ForgotPasswordScreen` | ❌ | Password reset |
| `/home` | `MainPage` | ✅ | Main dashboard with tab navigation |
| `/settings` | `SettingsScreen` | ✅ | App settings |
| `/edit-profile` | `EditProfileScreen` | ✅ | Edit user profile |
| `/add-workspace` | `AddWorkspaceScreen` | ✅ | Create workspace |
| `/edit-workspace` | `EditWorkspaceScreen` | ✅ | Edit workspace (extra: WorkspaceModel) |
| `/edit-workspace-scheme` | `EditWorkspaceSchemeScreen` | ✅ | Configure roles & permissions |
| `/workspace-users` | `WorkspaceUsersScreen` | ✅ | Manage members (extra: workspaceId) |
| `/notifications` | `NotificationsScreen` | ✅ | Notifications & invitations |
| `/notification-detail` | `NotificationDetailScreen` | ✅ | Invitation detail (extra: PendingAssignmentModel) |
| `/add-task` | `AddTaskScreen` | ✅ | Create / edit task (extra: TaskModel?) |
| `/task-detail` | `TaskDetailScreen` | ✅ | Task detail & actions (extra: TaskModel) |

---

## 🔧 Development

### Code Generation

This project uses `build_runner` for code generation (Freezed, JSON Serializable, Riverpod Generator). After modifying any annotated file, run:

```bash
# One-time build
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-rebuild on save)
dart run build_runner watch --delete-conflicting-outputs
```

### Static Analysis

```bash
flutter analyze
```

### Running on Specific Platforms

```bash
# iOS Simulator
flutter run -d ios

# Android Emulator
flutter run -d android

# macOS Desktop
flutter run -d macos

# Web (Chrome)
flutter run -d chrome
```

---

## 📄 License

This project is currently unlicensed and is part of a personal portfolio. All rights reserved.

---

## 👤 Author

**Abdallah Kamash**

- GitHub: [@AbdallahKamash](https://github.com/AbdallahKamash)

---

<p align="center">
  Built with ❤️ using Flutter & Firebase
</p>
