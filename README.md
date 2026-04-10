# Save4Later

Save4Later is a personal content curation app for iOS. It gives you a single place to bookmark and organize interesting things you come across — articles, recipes, books, movies, restaurants, songs, places, and more — without relying on any external service or cloud account. Everything is stored locally on your device.

The share extension is the core workflow: when you find something worth saving in Safari, Reddit, or any other app, you tap Share → Save4Later, give it a name, pick a category, and it lands in your library instantly.

---

## Features

- **10 built-in categories** — Recipes, Books, Articles, Songs, Shows, Movies, Restaurants, Places, Activities, and General
- **Custom categories** — create as many as you need; they sync to the share extension automatically
- **Share extension** — save URLs (with auto-fetched preview images) from any app via the iOS share sheet
- **Rich items** — each entry supports a name, notes, a link, and up to 5 images
- **Search** — real-time full-text search across names, notes, categories, and links
- **Sort** — alphabetical, newest first, or oldest first
- **Slideshow** — rotating featured-item carousel on the home screen
- **Offline-first** — no accounts, no network required, all data stays on device

---

## Project Structure

```
Save4Later/
├── Save4Later/                        # Main app target
│   ├── Save4LaterApp.swift            # App entry point
│   ├── SplashScreen.swift             # Animated launch screen
│   ├── Model/
│   │   ├── SavedItem.swift            # Core data model (Codable struct)
│   │   └── ModelData.swift            # Observable data manager & persistence
│   ├── Views/
│   │   ├── ContentView.swift          # Root navigation container
│   │   ├── SavedItem/
│   │   │   ├── SavedItemsHome.swift   # Home screen with search & sort
│   │   │   ├── SavedItemDetail.swift  # Full detail view
│   │   │   ├── SavedItemInfoForm.swift# Create / edit form
│   │   │   ├── SavedItemHomeRow.swift # Horizontal category row
│   │   │   └── SavedItemPreview.swift # Card preview component
│   │   └── Helpers/
│   │       ├── SlideShowView.swift    # Featured item carousel
│   │       ├── ExpandableText.swift   # Truncate/expand text helper
│   │       ├── RoundedImage.swift     # Styled image component
│   │       └── Extensions.swift       # Color & string utilities
│   ├── Assets.xcassets                # App icons, colors, images
│   ├── Resources/
│   │   └── savedItemsData.json        # Bundled sample data
│   └── fonts/                         # OpenSans font family
│
├── Save4LaterShareExtension/          # iOS share sheet extension
│   ├── ShareViewController.swift      # Extension lifecycle & URL extraction
│   ├── ShareFormView.swift            # Share UI form
│   └── SharedSavedItem.swift          # Shareable data model
│
├── Save4LaterShareExtension2/         # Alternate extension target
│
├── Save4LaterTests/                   # Unit tests
├── Save4LaterUITests/                 # UI tests
└── Screenshots/                       # App store / promotional screenshots
```

---

## Architecture

The app follows a straightforward MVVM pattern using modern SwiftUI conventions.

**ModelData** is an `@Observable` class that acts as the single source of truth. Views access it via `@Environment(ModelData.self)` and never own data directly. All persistence is handled inside `ModelData` — items are serialized to JSON and written to the app's Documents directory. On load, the app falls back to the bundled `savedItemsData.json` if no saved data is found.

**Share extension ↔ main app communication** works through two mechanisms. First, the extension writes a `SharedSavedItem` JSON payload to a shared app group container (`group.save4later`). Second, it posts a Darwin notification via `CFNotificationCenter`. The main app listens for that notification and, when it comes to the foreground, calls `importSharedItemIfAvailable()` to pull in the new item. A `WeakModelDataBox` wrapper prevents retain cycles in the notification callback.

**Custom categories** are also stored in the shared app group container so the extension can read and display them without any IPC round-trip.

**Optimistic UI updates** are used for deletes and edits — the change is applied to the in-memory array immediately, and rolled back if the disk write fails.

---

## Tech Stack

| | |
|---|---|
| Language | Swift 5 |
| UI | SwiftUI |
| Minimum iOS | iOS 18.4 |
| Persistence | JSON files in the Documents directory |
| Cross-target data | App group container (`group.save4later`) |
| IPC | Darwin notifications (`CFNotificationCenter`) |
| Image handling | PhotosUI, JPEG at 0.8 quality |
| Link previews | LinkPresentation framework |
| Fonts | OpenSans (Regular, Bold, SemiBold, Medium, Light, ExtraBold, Italic) |

---

## How the Share Extension Works

1. User taps **Share → Save4Later** in any app
2. The extension extracts the shared URL from the input items
3. `LinkPresentation` fetches a preview image for the URL in the background
4. A form is presented — the URL is pre-filled, the preview image is pre-loaded, and the user can set a name, notes, category, and additional photos
5. On submit, a `SharedSavedItem` is encoded to JSON and written to the app group container
6. A Darwin notification is posted to wake the main app
7. The next time the main app enters the foreground, it reads the pending item from the container and imports it into the library

---

## Getting Started

1. Clone the repo and open `Save4Later.xcodeproj` in Xcode
2. Select your development team in the project's Signing & Capabilities settings (required for the app group entitlement)
3. Make sure the app group identifier `group.save4later` is configured for both the main app and share extension targets
4. Build and run on a device or simulator running iOS 18.4+

To test the share extension, run the app once to register it, then share a URL from Safari — Save4Later should appear in the share sheet.
