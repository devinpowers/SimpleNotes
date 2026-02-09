# SimpleNotes

A lightweight markdown notes app for macOS with first-class code block support.

## Features

- Markdown editing with live syntax highlighting (headers, bold, italic, inline code)
- Code block insertion with language picker and snippet templates
- Syntax highlighting inside code blocks (keywords, strings, comments)
- Markdown preview with copy button, line numbers, and language badges on code blocks
- Image attachments with inline preview
- Pin notes to the top of your list
- Keyboard shortcuts for common actions

## Requirements

- macOS 14.0 or later
- Xcode 15.0 or later (to build from source)

## Installation

### Download a Release

1. Go to the [Releases](../../releases) page
2. Download the latest `SimpleNotes-x.x.x.zip`
3. Unzip and drag `SimpleNotes.app` to your Applications folder
4. Open SimpleNotes from Applications

### Build from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/devinpowers/SimpleNotes.git
   cd SimpleNotes
   ```

2. Open in Xcode:
   ```bash
   open SimpleNotes.xcodeproj
   ```

3. Select the **SimpleNotes** scheme and your Mac as the destination, then press **Cmd+R** to build and run.

Alternatively, build from the command line:
```bash
xcodebuild -project SimpleNotes.xcodeproj \
  -scheme SimpleNotes \
  -configuration Release \
  -destination 'platform=macOS' \
  CODE_SIGN_IDENTITY="-" \
  build
```

## Running Tests

```bash
xcodebuild test \
  -project SimpleNotes.xcodeproj \
  -scheme SimpleNotes \
  -destination 'platform=macOS'
```

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| Cmd+N | New note |
| Cmd+P | Toggle markdown preview |
| Cmd+Shift+K | Insert code block |

## Project Structure

```
SimpleNotes/
  Models/
    Note.swift              # Core data model
    MarkdownParser.swift    # Block parser for markdown content
    CodeTemplates.swift     # Language list and snippet templates
  Views/
    ContentView.swift       # Main split view layout
    NoteListView.swift      # Sidebar note list
    NoteRowView.swift       # Individual note row
    NoteEditorView.swift    # Editor with toolbar
    MarkdownPreviewView.swift   # Rendered markdown preview
    MarkdownTextEditor.swift    # NSTextView-based editor with highlighting
SimpleNotesTests/
  MarkdownParserTests.swift
  CodeTemplatesTests.swift
  NoteModelTests.swift
```
