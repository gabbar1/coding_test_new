# Todo App - Flutter Assignment

This is a Flutter app that works with JSONPlaceholder API to manage todos. I've built this using BLoC pattern for state management and added offline support so it works even without internet.

## What's in this app?

- You can see all todos in a list
- Add new todos with a floating button
- Mark todos as complete/incomplete
- Delete todos
- Search todos by typing in the search box
- Pull down to refresh the list
- Login screen (username: admin, password: password)
- Works offline - todos are saved locally and sync when you're back online

## How I built it

I followed Clean Architecture approach and tried to keep things organized:

```
lib/
├── core/          # Constants, errors, utilities
├── data/          # API calls, local storage, models
├── domain/        # Business logic entities and interfaces
└── presentation/ # UI stuff - screens, widgets, BLoC
```

## BLoC Pattern

I used BLoC for managing state. It's cleaner than setState and makes testing easier.

**TodoBloc** handles:
- Loading todos from API or local storage
- Creating new todos
- Updating todos (marking complete)
- Deleting todos
- Searching todos
- Syncing with server

**AuthBloc** handles:
- Login/logout flow

## API Integration

I'm using Dio for API calls because it's better than http package - has interceptors, better error handling, etc.

Endpoints I'm using:
- GET /todos - get all todos
- POST /todos - create new todo
- PATCH /todos/:id - update todo
- DELETE /todos/:id - delete todo

I also added pretty_dio_logger so you can see all API requests and responses in console.

## Offline Support

This was tricky. Here's what I did:

1. **Local Storage**: I'm using SharedPreferences to store todos locally (works on web too, unlike sqflite)

2. **How it works**:
   - When you're online: fetches from API, saves to local, shows API data
   - When you're offline: shows local data
   - If API fails: falls back to local data

3. **Optimistic Updates**: When you add/update/delete a todo, it updates the UI immediately and saves locally first. Then tries to sync with server.

4. **Sync Queue**: If you're offline and make changes, they're saved in a pending sync queue. When you come back online, it syncs everything automatically. You can also manually sync using the sync button.

## SOLID Principles

I tried to follow SOLID principles:

- **Single Responsibility**: Each class does one thing
- **Open/Closed**: Can extend without modifying existing code
- **Liskov Substitution**: Interfaces can be swapped
- **Interface Segregation**: Separate interfaces for different things
- **Dependency Inversion**: High level modules depend on abstractions, not concrete implementations

## Setup

1. Make sure you have Flutter installed (3.7.2 or higher)

2. Clone the repo and install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

4. Login with:
   - Username: `admin`
   - Password: `password`

## Why I made these choices

**BLoC**: I've used it before and it's good for managing complex state. Makes code more testable.

**Dio**: Better than http package. Has interceptors, better error handling, timeout configs.

**SharedPreferences**: Used this instead of sqflite because it works on web too. For this assignment, it's enough.

**Repository Pattern**: Keeps data layer separate from business logic. Easy to swap implementations if needed.

## Challenges I faced

1. **Offline Sync**: Managing pending sync operations was tricky. I created a separate queue that stores what needs to be synced and processes it when online.

2. **Optimistic Updates**: Making sure UI updates immediately while keeping data consistent. I save locally first, then sync to server.

3. **Error Handling**: Showing proper error messages without breaking UX. Created custom Failure classes and Result type for better error handling.

4. **Web Compatibility**: Initially used sqflite but it doesn't work on web. Switched to SharedPreferences which works everywhere.

## What could be improved

- Add unit tests (didn't have time)
- Add pagination for large lists
- Add categories or tags
- Dark mode
- Better error messages
- Loading indicators for better UX

## Dependencies used

- `flutter_bloc` - for state management
- `dio` - for API calls
- `pretty_dio_logger` - to log API requests/responses
- `shared_preferences` - for local storage
- `connectivity_plus` - to check network status
- `equatable` - for value equality
- `uuid` - to generate unique IDs

That's pretty much it. Let me know if you have any questions!
