# SimpleNotes — macOS Notes App

A minimal Apple Notes-style macOS app built with SwiftUI and SwiftData.

## Features

- Two-column layout: note list sidebar + editor
- Live markdown formatting (headers, bold, italic, inline code, fenced code blocks)
- Markdown preview mode (Cmd+P)
- Insert photos into notes (png, jpg, gif, heic)
- Pin important notes to the top of the sidebar
- Search notes by title or body content
- Right-click context menu (pin/unpin, delete)
- Persistent storage via SwiftData
- Cmd+N to create new notes (via toolbar)

## Tech Stack

- **SwiftUI** — declarative UI framework
- **SwiftData** — persistence layer (requires macOS 14+)
- **NavigationSplitView** — two-column master-detail layout
- **NSTextView** — custom markdown syntax highlighting editor

## Building

### With Xcode (required for SwiftData macros)

```bash
open SimpleNotes.xcodeproj
# Then build and run from Xcode (Cmd+R)
```

### Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later

## Project Structure

```
SimpleNotes/
├── SimpleNotesApp.swift          # App entry point, SwiftData container
├── Models/
│   └── Note.swift                # @Model: id, title, body, createdAt, updatedAt, isPinned, imageData
├── Views/
│   ├── ContentView.swift         # NavigationSplitView (list + editor)
│   ├── NoteListView.swift        # Sidebar with search, pinned sections, context menu
│   ├── NoteEditorView.swift      # Title + markdown editor + image strip + preview toggle
│   ├── NoteRowView.swift         # Row with pin icon, title, date, preview
│   ├── MarkdownTextEditor.swift  # NSViewRepresentable with live syntax highlighting
│   └── MarkdownPreviewView.swift # Rendered markdown preview with code blocks + images
```

---

## Deploying to GitHub

### Step 1: Create the GitHub Repository

```bash
cd /path/to/SimpleNotes

# Initialize git (if not already)
git init
git add -A
git commit -m "Initial commit: SimpleNotes v1.0.0"

# Create repo on GitHub and push
gh repo create SimpleNotes --public --source=. --push
```

Or create the repo manually at github.com, then:

```bash
git remote add origin https://github.com/<your-username>/SimpleNotes.git
git branch -M main
git push -u origin main
```

### Step 2: Archive a Release Build

**Option A: Xcode UI**
1. Open `SimpleNotes.xcodeproj`
2. Select **Any Mac** as destination
3. **Product → Archive**
4. In Organizer: **Distribute App → Developer ID** (or **Copy App** if unsigned)
5. Save the `.app` bundle

**Option B: Command line** (requires `xcode-select -s /Applications/Xcode.app`)

```bash
xcodebuild -project SimpleNotes.xcodeproj \
  -scheme SimpleNotes \
  -configuration Release \
  -archivePath build/SimpleNotes.xcarchive \
  archive

xcodebuild -exportArchive \
  -archivePath build/SimpleNotes.xcarchive \
  -exportPath build/ \
  -exportOptionsPlist ExportOptions.plist
```

### Step 3: Package for Distribution

```bash
# Create a DMG
hdiutil create -volname "SimpleNotes" \
  -srcfolder build/SimpleNotes.app \
  -ov -format UDZO \
  build/SimpleNotes-1.0.0.dmg

# Or create a ZIP
cd build/ && ditto -c -k --keepParent SimpleNotes.app SimpleNotes-1.0.0.zip
```

### Step 4: Create a GitHub Release

```bash
# Tag the release
git tag v1.0.0
git push origin v1.0.0

# Create release and upload the DMG/ZIP
gh release create v1.0.0 \
  build/SimpleNotes-1.0.0.dmg \
  --title "SimpleNotes v1.0.0" \
  --notes "Initial release with markdown editing, photo support, and pinned notes."
```

Users can then download from:
`https://github.com/<your-username>/SimpleNotes/releases/latest`

---

## Code Signing & Notarization (Recommended)

Without signing, macOS will warn users or block the app entirely on Apple Silicon.

### Requirements

- **Apple Developer Program** ($99/year) — provides Developer ID certificate + notarization access
- **Hardened Runtime** — enable in Xcode: Target → Signing & Capabilities → Hardened Runtime

### Notarize Your App

```bash
# Store credentials (one-time setup)
xcrun notarytool store-credentials "notarization-password" \
  --apple-id "you@email.com" \
  --team-id "YOUR_TEAM_ID"

# Submit for notarization
xcrun notarytool submit build/SimpleNotes-1.0.0.dmg \
  --keychain-profile "notarization-password" \
  --wait

# Staple the ticket to the DMG
xcrun stapler staple build/SimpleNotes-1.0.0.dmg
```

### Without a Developer Account

You can still distribute unsigned, but users must:
1. Right-click the app → **Open** → click **Open** in the dialog
2. Or: **System Settings → Privacy & Security → Open Anyway**
3. On Apple Silicon: may need to run `codesign --force --deep --sign - SimpleNotes.app`

---

## Distribution via Homebrew Cask

### 1. Create a Homebrew Tap

Create a GitHub repo named `homebrew-tap`, then add:

**`Casks/simplenotes.rb`**

```ruby
cask "simplenotes" do
  version "1.0.0"
  sha256 "<sha256-of-your-dmg>"

  url "https://github.com/<your-username>/SimpleNotes/releases/download/v#{version}/SimpleNotes-#{version}.dmg"
  name "SimpleNotes"
  desc "Minimal macOS notes app with markdown editing and image support"
  homepage "https://github.com/<your-username>/SimpleNotes"

  depends_on macos: ">= :sonoma"

  app "SimpleNotes.app"

  zap trash: [
    "~/Library/Application Support/SimpleNotes",
    "~/Library/Caches/com.simplenotes.SimpleNotes",
  ]
end
```

### 2. Users Install With

```bash
brew tap <your-username>/tap
brew install --cask simplenotes
```

### Quick Reference

| Task | Command |
|------|---------|
| Get SHA256 | `shasum -a 256 SimpleNotes-1.0.0.dmg` |
| Create release | `gh release create v1.0.0 SimpleNotes-1.0.0.dmg` |
| Install from tap | `brew tap <user>/tap && brew install --cask simplenotes` |
| Audit cask | `brew audit --cask simplenotes` |
