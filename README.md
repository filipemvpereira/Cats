# Cats

A modular iOS application built with Swift Package Manager (SPM) that displays cat breeds from The Cat API, allowing users to browse, search, and favorite breeds.

## Development Strategies

This section explains the key technical decisions and strategies adopted during the development of this challenge.

### 1. Modular Architecture with Swift Package Manager

**Decision**: Split the application into multiple SPM packages

**Implementation**:
- Core modules provide shared functionality (CoreBreeds, Network, CoreLocalStorage)
- Feature modules are self-contained and depend only on core modules
- Main app assembles all features using dependency injection

### 2. SwiftData for Persistence

**Decision**: Use SwiftData for local storage.

**Implementation**:
- `BreedEntity` model with `@Model` macro for breed caching
- `LocalStorageRepository` protocol for abstraction and testability
- SwiftData implementation hidden behind protocol (easy to swap if needed)
- Automatic favorite persistence across app launches

### 3. Two-Tier Testing Strategy

**Decision**: Implement both unit tests and integration tests for critical features.

**Implementation**:
- CoreTests module with shared mocks (`MockNetworkService`, `MockLocalStorageRepository`)
- Unit tests mock all dependencies for speed and isolation
- Integration tests use real implementations with only external services mocked
- Example: `BreedsListIntegrationTests` tests ViewModel → UseCases → Repository → Storage

### 4. Dependency Injection with Swinject

**Decision**: Use Swinject for dependency injection

**Implementation**:
- Each module has its own `Assembly` (e.g., `CoreBreedsAssembly`, `BreedsListAssembly`)
- Main app assembles all modules in `AppDI.swift`
- Test targets can override assemblies with mock implementations

### 5. Clean Architecture Principles

**Decision**: Apply Clean Architecture with layers: Presentation → Domain → Data.


**Implementation**:
```
FeatureBreedsList/
├── Presentation/       # ViewModels, Views (depends on Domain)
├── Domain/             # UseCases, protocols (no dependencies)
└── Models/             # View-specific models
```

### 6. Offline-First Approach

**Decision**: Cache all API responses locally and use cache when network fails.

**Implementation**:
- Repository tries network first, falls back to cache on error
- All breeds, search results, and details are cached in SwiftData
- Favorites persisted locally and survive app restarts

### 7. Protocol-Driven Design

**Decision**: Define protocols for all abstractions (Repository, UseCases, NetworkService).

**Implementation**:
```swift
// Protocol
public protocol BreedRepository {
    func getBreeds(page: Int, limit: Int) async throws -> [Breed]
}

// Implementation (can be swapped)
public final class BreedRepositoryImpl: BreedRepository { ... }

// Mock for testing
final class MockBreedRepository: BreedRepository { ... }
```

### 8. Swift 6 Concurrency

**Decision**: Use async/await and actors throughout the codebase.

**Implementation**:
- All network and database operations are `async`
- ViewModels use `@MainActor` for thread safety
- `@ModelActor` for SwiftData concurrency
- Strict concurrency checking enabled in all modules

### 9. Separation of Models

**Decision**: Use different models for each layer (DTO, Domain, View).

**Implementation**:
- `BreedDTO`: Network layer (matches API response)
- `Breed`: Domain layer (business logic)
- `LocalBreed`: Storage layer (SwiftData entity)
- `BreedItemViewData`: View layer (presentation-specific)

### 10. Shared Test Utilities

**Decision**: Create CoreTests module for shared mocks instead of duplicating them.

**Implementation**:
- `MockNetworkService` used by CoreBreeds and all feature modules
- `MockLocalStorageRepository` shared across all tests
- Easy to extend with new shared test utilities

## Architecture

This project uses a modular architecture with SPM packages:

### Core Modules
- **CoreBreeds** - Domain models and business logic for cat breeds
- **CoreLocalStorage** - SwiftData persistence layer for caching and favorites
- **CoreUI** - Shared UI components and utilities
- **CoreResources** - Shared resources (images, localizations)
- **CoreTests** - Shared test utilities and mocks
- **Network** - Network layer with URLSession

### Feature Modules
- **FeatureBreedsList** - Breeds list with search functionality
- **FeatureBreedDetail** - Detailed breed information view
- **FeatureFavourites** - Favorite breeds management

## Requirements

- Xcode 16.2+
- iOS 18.0+
- Swift 6.2+

## Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd Cats
```

### 2. Open the Project

```bash
open Cats/Cats.xcodeproj
```

Xcode will automatically resolve SPM dependencies on first open.

### 3. Select a Simulator

- Choose any iPhone simulator with iOS 18.0 or later
- Recommended: iPhone 16 Pro or iPhone 17

### 4. Build and Run

Press `⌘R` or click the Run button in Xcode.

## Running Tests

### Option 1: Using the Test Script (Recommended)

The project includes a convenient test runner script that runs all SPM package tests.

#### Run all tests:
```bash
./run-tests.sh
```

The script will:
- Test all SPM packages (CoreBreeds, FeatureBreedsList, FeatureBreedDetail, FeatureFavourites)
- Display a summary with pass/fail status
- Show total duration

### Option 2: Running Tests in Xcode

#### Run All Tests
1. Press `⌘U` to run all tests in the Cats scheme
2. This runs unit tests for the main app

#### Run SPM Package Tests Individually

SPM package test targets don't appear in the Cats app scheme by default. To test them:

**Method 1: Open Package Directly**
1. Navigate to the package directory (e.g., `CoreBreeds/`)
2. Open `Package.swift` in Xcode
3. Select the package scheme (e.g., `CoreBreeds`)
4. Press `⌘U` to run tests

**Method 2: Using xcodebuild**
```bash
# Test CoreBreeds
cd CoreBreeds
xcodebuild test -scheme CoreBreeds -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Test FeatureBreedsList
cd FeatureBreedsList
xcodebuild test -scheme FeatureBreedsList -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

## Test Coverage

### CoreBreeds
- **Unit Tests**: Repository tests with mocked network and storage
- **Coverage**: API integration, caching, favorite management, error handling

### FeatureBreedsList
- **Unit Tests**: ViewModel tests with mocked use cases
- **Integration Tests**: End-to-end tests from ViewModel to Repository
  - Load breeds with network success
  - Network error fallback to cache
  - Toggle favorite persistence
  - Search functionality

### FeatureBreedDetail
- **Unit Tests**: ViewModel tests for breed detail display
- **Coverage**: Loading states, favorite toggling, error handling

### FeatureFavourites
- **Unit Tests**: ViewModel tests for favorites management
- **Coverage**: Load favorites, unfavorite action, empty states

### CoreTests
- Shared test utilities used across all feature modules
- Mock implementations for NetworkService and LocalStorageRepository

## Features

### Breeds List
- Browse all cat breeds
- Search breeds by name
- Mark/unmark breeds as favorites
- Pull-to-refresh
- Offline support with caching

### Breed Detail
- View detailed information about a breed
- See breed characteristics (origin, temperament)
- Toggle favorite status
- View breed images

### Favorites
- View all favorited breeds
- Remove breeds from favorites
- Persisted across app launches

## Dependencies

- [Swinject](https://github.com/Swinject/Swinject) (2.10.0) - Dependency injection

## Technologies

- **SwiftUI** - Modern declarative UI framework
- **Swift Concurrency** - async/await for asynchronous operations
- **SwiftData** - Modern persistence framework
- **@Observable** - State management
- **Swift Package Manager** - Modular architecture
- **Dependency Injection** - Testable, decoupled components

## Project Structure

```
Cats/
├── Cats/                      # Main app target
│   ├── Cats/
│   │   ├── App/              # App entry point
│   │   └── DI/               # Dependency injection setup
│   └── Cats.xcodeproj
├── CoreBreeds/                # SPM package - Breed domain logic
│   ├── Sources/CoreBreeds/
│   │   ├── Domain/           # Breed models
│   │   ├── Repository/       # Data access layer
│   │   ├── DTO's/            # Data transfer objects
│   │   └── DI/               # Module assembly
│   └── Tests/CoreBreedsTests/
├── CoreLocalStorage/          # SPM package - SwiftData persistence
│   ├── Sources/CoreLocalStorage/
│   │   ├── Domain/           # Storage protocols and models
│   │   ├── Data/             # SwiftData implementation
│   │   └── DI/               # Module assembly
│   └── Package.swift
├── CoreUI/                    # SPM package - Shared UI components
│   └── Sources/CoreUI/
├── CoreResources/             # SPM package - Shared resources
│   └── Sources/CoreResources/
├── CoreTests/                 # SPM package - Test utilities
│   └── Sources/CoreTests/
│       ├── MockNetworkService.swift
│       └── MockLocalStorageRepository.swift
├── Network/                   # SPM package - Networking
│   ├── Sources/Network/
│   │   ├── Client/           # URLSession wrapper
│   │   ├── Models/           # Request/Response models
│   │   └── DI/               # Module assembly
│   └── Package.swift
├── FeatureBreedsList/         # SPM package - Breeds list feature
│   ├── Sources/FeatureBreedsList/
│   │   ├── Domain/           # Use cases
│   │   ├── Models/           # View models
│   │   ├── Presentation/     # Views and ViewModels
│   │   └── DI/               # Module assembly
│   └── Tests/FeatureBreedsListTests/
│       ├── BreedsListViewModelTests.swift
│       ├── BreedsListIntegrationTests.swift
│       └── Mocks/
├── FeatureBreedDetail/        # SPM package - Breed detail feature
│   ├── Sources/FeatureBreedDetail/
│   └── Tests/FeatureBreedDetailTests/
├── FeatureFavourites/         # SPM package - Favorites feature
│   ├── Sources/FeatureFavourites/
│   └── Tests/FeatureFavouritesTests/
└── run-tests.sh              # Test runner script
```

## Architecture Principles

### Clean Architecture
- **Separation of Concerns**: Each module has a single responsibility
- **Dependency Inversion**: High-level modules don't depend on low-level modules
- **Testability**: All components are testable in isolation

### Modular Design
- **Feature Modules**: Self-contained features with their own dependencies
- **Core Modules**: Shared business logic and utilities
- **Dependency Injection**: Swinject for managing dependencies

### Testing Strategy
- **Unit Tests**: Test individual components in isolation with mocks
- **Integration Tests**: Test real flows with mocked external dependencies
- **Shared Mocks**: CoreTests module provides reusable test utilities

## API

This app uses [The Cat API](https://thecatapi.com/) to fetch cat breed information.
