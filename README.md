# Rentable v2 - iOS App

A modern iOS rental property management app built with SwiftUI and Supabase.

## Features

- ✅ Clean iOS architecture following Apple's best practices
- ✅ Complete onboarding flow with email verification
- ✅ Supabase authentication and database integration
- ✅ Native SwiftUI components throughout
- ✅ Full accessibility support (VoiceOver, Dynamic Type)
- ✅ Production-ready polish with animations and haptics
- ✅ Comprehensive error handling and validation

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd Rentable-v2
```

### 2. Configure Supabase

1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Copy `Config.example.xcconfig` to `Config.xcconfig`
3. Update `Config.xcconfig` with your Supabase credentials:

```
SUPABASE_URL = https://your-project.supabase.co
SUPABASE_ANON_KEY = your-anon-key
```

### 3. Database Setup

Run these SQL commands in your Supabase SQL Editor:

```sql
-- Create profiles table
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    date_of_birth DATE,
    phone_number TEXT,
    address TEXT,
    profile_image_url TEXT,
    user_type TEXT NOT NULL CHECK (user_type IN ('tenant', 'landlord')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own profile"
    ON profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
    ON profiles FOR UPDATE
    USING (auth.uid() = id);

-- Create storage bucket for avatars
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true);

-- Set up storage policy
CREATE POLICY "Users can upload their own avatar"
    ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);
```

### 4. Install Dependencies

Dependencies are managed via Swift Package Manager (SPM) and should be automatically resolved:

- Supabase Swift Client
- (Optional) KeychainAccess - for secure session storage

### 5. Build and Run

1. Open `Rentable v2.xcodeproj` in Xcode
2. Select your development team in Signing & Capabilities
3. Run the app (⌘R)

## Project Structure

```
Rentable v2/
├── Config/
│   ├── Environment.swift       # Environment configuration
│   └── Constants.swift          # App constants
├── Core/
│   ├── AppState.swift          # Global app state
│   └── AppCoordinator.swift    # Navigation coordinator
├── Models/
│   ├── User.swift              # User data model
│   └── SignupData.swift        # Signup form data
├── Services/
│   ├── AuthenticationService.swift  # Auth service (actor)
│   └── SupabaseManager.swift       # Supabase client
├── ViewModels/
│   └── OnboardingViewModel.swift   # Onboarding logic
├── Views/
│   ├── Onboarding/
│   │   ├── WelcomeView.swift
│   │   ├── SignupCoordinatorView.swift
│   │   ├── VerificationView.swift
│   │   └── SignupSteps/
│   │       ├── NameStepView.swift
│   │       ├── DateOfBirthStepView.swift
│   │       ├── PhoneStepView.swift
│   │       ├── AddressStepView.swift
│   │       └── PhotoStepView.swift
│   ├── Components/
│   │   ├── LoadingView.swift
│   │   └── ErrorView.swift
│   └── MainTabView.swift
└── Extensions/
    ├── View+Extensions.swift
    ├── String+Validation.swift
    ├── Date+Extensions.swift
    └── UIImage+Extensions.swift
```

## Architecture

### Modern Swift Concurrency
- **async/await** throughout (no completion handlers)
- **actor** pattern for thread-safe services
- **@MainActor** for UI components

### SOLID Principles
- Single Responsibility
- Dependency Injection
- Protocol-oriented design
- Clear separation of concerns

### SwiftUI Best Practices
- **@StateObject** at appropriate levels
- Proper state management
- Native components throughout
- Accessibility-first design

## Configuration

### Environments

The app supports three environments:
- **Development** - Debug builds with test data enabled
- **Staging** - Pre-production testing
- **Production** - Release builds

Configure in `Config/Environment.swift`

### Constants

All app constants are centralized in `Config/Constants.swift`:
- Validation rules
- UI dimensions
- Timing values
- Regex patterns
- URLs

## Testing

### MVP Testing

For development/testing, use these credentials:
- **OTP Code**: `123456` (clearly marked in UI)

### Network Testing

Use Network Link Conditioner to test:
- Slow network scenarios
- Connection failures
- Timeouts

### Accessibility Testing

Enable VoiceOver (⌘+F5) to test:
- All interactive elements have labels
- Proper hint text
- Logical navigation order

## Security

- ✅ Supabase credentials in `.gitignore`
- ✅ Row Level Security enabled
- ✅ Secure session management
- ✅ Image size validation (max 1MB)
- ✅ Input validation and sanitization

## Performance

- ✅ Image compression (JPEG 0.7 quality)
- ✅ Lazy loading
- ✅ Task cancellation
- ✅ Optimized async operations
- ✅ Actor-based concurrency

## Info.plist Configuration

Required privacy descriptions (already configured):

```xml
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take a profile photo.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to select a profile photo.</string>
```

## SPM Dependencies

### Current:
- **Supabase** - Backend integration

### Recommended for Production:
- **KeychainAccess** - Secure credential storage
- **Kingfisher** - Image caching and loading

To add KeychainAccess:
1. File → Add Package Dependencies
2. Enter: `https://github.com/kishikawakatsumi/KeychainAccess`
3. Select version and add to target

## Contributing

1. Create a feature branch
2. Make your changes
3. Run tests
4. Submit a pull request

## License

[Add your license here]

## Support

For issues or questions:
- Email: support@rentable.app
- GitHub Issues: [Add URL]

---

Built with ❤️ using SwiftUI and Supabase

