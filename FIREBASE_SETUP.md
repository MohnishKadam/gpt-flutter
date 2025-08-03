# Firebase Setup Guide

This guide will help you set up Firebase for the ChatGPT Flutter app to enable chat history storage and management.

## Prerequisites

1. A Google account
2. Flutter SDK installed
3. Firebase CLI installed (optional but recommended)

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter a project name (e.g., "chatgpt-flutter-app")
4. Choose whether to enable Google Analytics (optional)
5. Click "Create project"

## Step 2: Enable Authentication

1. In your Firebase project console, go to "Authentication" in the left sidebar
2. Click "Get started"
3. Go to the "Sign-in method" tab
4. Enable "Anonymous" authentication:
   - Click on "Anonymous"
   - Toggle the "Enable" switch
   - Click "Save"

## Step 3: Enable Firestore Database

1. In your Firebase project console, go to "Firestore Database" in the left sidebar
2. Click "Create database"
3. Choose "Start in test mode" for development (you can secure it later)
4. Select a location for your database (choose the closest to your users)
5. Click "Done"

## Step 4: Set Up Security Rules

1. In Firestore Database, go to the "Rules" tab
2. Replace the default rules with the following:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read and write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Allow users to manage their conversations
      match /conversations/{conversationId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
        
        // Allow users to manage messages in their conversations
        match /messages/{messageId} {
          allow read, write: if request.auth != null && request.auth.uid == userId;
        }
      }
    }
  }
}
```

3. Click "Publish"

## Step 5: Get Firebase Configuration

1. In your Firebase project console, click the gear icon next to "Project Overview"
2. Select "Project settings"
3. Scroll down to "Your apps" section
4. Click the web icon (</>) to add a web app
5. Enter an app nickname (e.g., "chatgpt-web")
6. Click "Register app"
7. Copy the configuration object

## Step 6: Update Firebase Configuration

1. Open `lib/firebase_options.dart`
2. Replace the placeholder values with your actual Firebase configuration:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'your-actual-api-key',
  appId: 'your-actual-app-id',
  messagingSenderId: 'your-actual-sender-id',
  projectId: 'your-actual-project-id',
  authDomain: 'your-actual-project-id.firebaseapp.com',
  storageBucket: 'your-actual-project-id.appspot.com',
  measurementId: 'your-actual-measurement-id',
);

static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'your-actual-api-key',
  appId: 'your-actual-app-id',
  messagingSenderId: 'your-actual-sender-id',
  projectId: 'your-actual-project-id',
  storageBucket: 'your-actual-project-id.appspot.com',
);
```

## Step 7: Test the Setup

1. Run the app: `flutter run`
2. Try creating a new chat
3. Check the Firebase console to see if data is being stored
4. Try accessing the chat history from the drawer

## Features Implemented

### Chat History Management
- ✅ Create new conversations
- ✅ Save messages to Firebase
- ✅ View conversation history
- ✅ Rename conversations
- ✅ Delete conversations
- ✅ Real-time updates

### Firebase Backend
- ✅ Anonymous authentication
- ✅ Firestore database
- ✅ Secure data access
- ✅ User-specific data isolation

### UI/UX
- ✅ Chat history screen
- ✅ Drawer navigation
- ✅ Conversation list
- ✅ Loading states
- ✅ Error handling

## Troubleshooting

### Common Issues

1. **Firebase not initialized**
   - Check if `firebase_options.dart` has correct configuration
   - Ensure Firebase is properly initialized in `main.dart`

2. **Authentication errors**
   - Verify Anonymous authentication is enabled
   - Check if user is properly authenticated

3. **Database permission errors**
   - Verify Firestore security rules
   - Check if the database is in test mode

4. **Data not saving**
   - Check console for error messages
   - Verify Firebase service is properly injected

### Debug Commands

```bash
# Check Firebase connection
flutter run --verbose

# Clear app data
flutter clean
flutter pub get
```

## Security Considerations

1. **Production Setup**: Before deploying to production:
   - Disable test mode in Firestore
   - Set up proper security rules
   - Enable additional authentication methods if needed
   - Set up proper API key restrictions

2. **Data Privacy**: The current setup stores:
   - User conversations
   - Message content
   - Timestamps
   - User preferences

3. **Backup**: Consider implementing:
   - Data export functionality
   - Regular backups
   - Data retention policies

## Next Steps

1. **Enhanced Features**:
   - Add user profiles
   - Implement conversation sharing
   - Add message reactions
   - Enable file uploads

2. **Performance**:
   - Implement pagination for large conversation lists
   - Add offline support
   - Optimize database queries

3. **Security**:
   - Add email/password authentication
   - Implement data encryption
   - Add audit logging

## Support

If you encounter any issues:
1. Check the Firebase console for error logs
2. Review the Flutter console output
3. Verify all configuration steps were completed
4. Test with a fresh Firebase project if needed 