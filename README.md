# Cat Breeds Challenge

A SwiftUI application displaying cat breeds using The Cat API with offline functionality and favorites management.

## ✅ Requirements Met

### Mandatory:
- Cat breeds list with image and name
- Search bar to filter by breed name
- Button to mark breed as favorite
- Favorites screen with average lifespan
- Breed detail screen with all required fields
- Navigation between screens
- MVVM architecture
- SwiftUI
- Unit test coverage
- Offline functionality (SwiftData)

### Bonus:
- Error handling
- Pagination (partial implementation - fails when API returns inconsistent page sizes)
- Modular design

## ❌ Requirements NOT Met

### Bonus:
- **TCA architecture**
- **Integration and E2e tests** (only unit tests)

## Development Strategies

### Architecture Decision: MVVM
**Strategy:** Chose MVVM over TCA for simpler implementation.

### Data Management Strategy
**Offline-first approach:** Check local SwiftData first, fetch from API only when needed. Prevents network dependency after initial load.

### Pagination Strategy
**Infinite scroll with hybrid pagination:** Load from local data when available, fetch from API when insufficient. Triggered when user reaches last 3 items.

### Error Handling Strategy
**Custom error enum:** App continues working with local data when API fails.

### Testing Strategy
**Unit tests for business logic:** Focused on data parsing, calculations, and edge cases rather than UI testing.
