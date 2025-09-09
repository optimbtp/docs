# Mobile Platform Development Guide

This guide provides comprehensive information for developers working on the Mobile Platform.

## Development Environment Setup

### Prerequisites

- **Node.js** (16.0 or higher)
- **React Native CLI** (latest)
- **Xcode** (for iOS development)
- **Android Studio** (for Android development)
- **Git** (for version control)

### Installation

1. **Clone Repository**

   ```bash
   git clone https://github.com/optim/mobile-platform.git
   cd mobile-platform
   ```

2. **Install Dependencies**

   ```bash
   npm install
   # or
   yarn install
   ```

3. **iOS Setup**

   ```bash
   cd ios
   pod install
   cd ..
   ```

4. **Environment Configuration**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

## Project Structure

```
mobile-platform/
├── src/
│   ├── components/          # Reusable UI components
│   ├── screens/            # Screen components
│   ├── navigation/         # Navigation configuration
│   ├── services/           # API and business logic
│   ├── utils/              # Utility functions
│   ├── hooks/              # Custom React hooks
│   └── types/              # TypeScript type definitions
├── ios/                    # iOS-specific code
├── android/                # Android-specific code
├── __tests__/             # Test files
└── docs/                  # Documentation
```

## Development Workflow

### Running the App

1. **Start Metro Bundler**

   ```bash
   npm start
   # or
   yarn start
   ```

2. **Run on iOS**

   ```bash
   npm run ios
   # or
   yarn ios
   ```

3. **Run on Android**
   ```bash
   npm run android
   # or
   yarn android
   ```

### Development Commands

```bash
# Type checking
npm run type-check

# Linting
npm run lint
npm run lint:fix

# Testing
npm run test
npm run test:watch
npm run test:coverage

# Build
npm run build:ios
npm run build:android
```

## Architecture

### Component Architecture

The app follows a component-based architecture with:

- **Atomic Design** - Components organized by complexity
- **Container/Presenter** - Separation of logic and presentation
- **Hooks** - Custom hooks for business logic

### State Management

```typescript
// Using Redux Toolkit
interface AppState {
  auth: AuthState;
  documents: DocumentState;
  sync: SyncState;
  ui: UIState;
}
```

### Navigation

```typescript
// React Navigation v6
type RootStackParamList = {
  Auth: undefined;
  Main: undefined;
  Document: { documentId: string };
};
```

## API Integration

### Service Layer

```typescript
// services/api.ts
class APIService {
  async getDocuments(): Promise<Document[]> {
    const response = await fetch("/api/documents");
    return response.json();
  }
}
```

### Error Handling

```typescript
// utils/errorHandler.ts
export const handleAPIError = (error: APIError) => {
  // Centralized error handling logic
};
```

## Testing

### Test Structure

```
__tests__/
├── components/         # Component tests
├── screens/           # Screen tests
├── services/          # Service tests
├── utils/             # Utility tests
└── __mocks__/         # Mock files
```

### Testing Best Practices

1. **Unit Tests** - Test individual components and functions
2. **Integration Tests** - Test component interactions
3. **E2E Tests** - Test complete user workflows

### Example Test

```typescript
import { render, fireEvent } from "@testing-library/react-native";
import { LoginScreen } from "../src/screens/LoginScreen";

describe("LoginScreen", () => {
  it("should handle login submission", () => {
    const mockLogin = jest.fn();
    const { getByTestId } = render(<LoginScreen onLogin={mockLogin} />);

    fireEvent.press(getByTestId("login-button"));
    expect(mockLogin).toHaveBeenCalled();
  });
});
```

## Build and Deployment

### iOS Build

1. **Configure Signing**

   ```bash
   # Update provisioning profiles
   # Configure certificates in Xcode
   ```

2. **Build for Release**
   ```bash
   npm run build:ios:release
   ```

### Android Build

1. **Generate Keystore**

   ```bash
   keytool -genkey -v -keystore release-key.keystore -alias release-key -keyalg RSA -keysize 2048 -validity 10000
   ```

2. **Build for Release**
   ```bash
   npm run build:android:release
   ```

## Code Style Guidelines

### TypeScript

- Use strict TypeScript configuration
- Define interfaces for all data structures
- Prefer type inference where possible

### React Native

- Use functional components with hooks
- Follow React Native naming conventions
- Use TypeScript for prop types

### Styling

```typescript
// Use StyleSheet.create for styles
const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
  },
});
```

## Performance Optimization

### Best Practices

1. **Image Optimization**

   - Use appropriate image formats
   - Implement lazy loading
   - Optimize image sizes

2. **List Performance**

   - Use FlatList for large datasets
   - Implement proper keyExtractor
   - Use getItemLayout when possible

3. **Bundle Size**
   - Use dynamic imports
   - Implement code splitting
   - Remove unused dependencies

## Debugging

### Development Tools

- **Flipper** - Debugging and inspection
- **Reactotron** - React Native debugging
- **VS Code Debugger** - Breakpoint debugging

### Common Issues

1. **Metro Bundle Issues**

   ```bash
   npm start -- --reset-cache
   ```

2. **iOS Build Issues**

   ```bash
   cd ios && pod install
   ```

3. **Android Build Issues**
   ```bash
   cd android && ./gradlew clean
   ```

## Contributing

### Pull Request Process

1. Create feature branch from `develop`
2. Implement changes with tests
3. Update documentation
4. Submit PR for review

### Commit Message Format

```
type(scope): description

feat(auth): add biometric authentication
fix(sync): resolve offline data sync issue
docs(api): update API documentation
```

## Resources

- **[React Native Documentation](https://reactnative.dev/)**
- **[TypeScript Handbook](https://www.typescriptlang.org/docs/)**
- **[Testing Library](https://testing-library.com/docs/react-native-testing-library/intro/)**
- **[Redux Toolkit](https://redux-toolkit.js.org/)**

---

_For development questions, contact the Mobile Development Team or create an issue in the repository._
