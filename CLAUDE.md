# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`react-native-video-desktop` is a React Native video component for desktop platforms (macOS, Windows, Linux) that provides API compatibility with `react-native-video`. Currently only macOS is implemented using AVKit/AVFoundation, with Windows (Media Foundation) and Linux (GStreamer) planned.

## Build Commands

```bash
# Build the library (compiles TypeScript to CommonJS/ESM)
npm run prepare

# Type checking
npm run typescript

# Linting
npm run lint

# Run example app (macOS only currently)
npm run example
```

## Architecture

### Bridge Architecture

This is a **React Native native module** with a custom native view component. The bridge follows this flow:

1. **JavaScript Layer** (`src/VideoDesktop.tsx`): React component that wraps the native view
2. **Native Module Manager** (`macos/RNVideoDesktopManager.m`): Registers the native component and exports props/events/commands
3. **Native View** (`macos/RNVideoDesktopView.m`): Implements the actual video player using AVPlayer/AVPlayerLayer

### Key Communication Patterns

**Props → Native**: Props are declared in the Manager with `RCT_EXPORT_VIEW_PROPERTY` and set via property setters in the View class.

**Events → JavaScript**: Events use `RCTDirectEventBlock` callbacks. Native code invokes these blocks with dictionaries that get converted to JavaScript objects.

**Commands (Imperative API)**: JavaScript can call native methods via `UIManager.dispatchViewManagerCommand`. The Manager exports these with `RCT_EXPORT_METHOD` and forwards to the View instance.

### macOS Implementation Details

**Layer Management**: The View uses `AVPlayerLayer` added as a sublayer to the React-managed NSView's layer. The View overrides `setBackgroundColor:` to prevent React from interfering with layer backgrounds.

**Frame Updates**: The `updateVideoLayerFrame` method is called in `layout` and `viewDidMoveToWindow` to ensure the player layer fills the view bounds. This uses `CATransaction` with disabled animations for immediate updates.

**Player Lifecycle**:
- `AVPlayer` is created immediately in `setupPlayer`
- `AVPlayerItem` is created when `source` prop is set
- KVO observers watch `status` and `duration` on the player item
- Periodic time observer (4 times per second) drives progress callbacks
- Observers must be properly removed in `removeObservers` to prevent crashes

**Event Flow**:
- Native events (e.g., `onVideoLoad`) are named with "onVideo" prefix in the View
- These are wrapped in the JavaScript component to match the public API (e.g., `onLoad`)

## Type Definitions

All TypeScript types are in `src/types.ts`. The main types are:
- `VideoDesktopProps` - Public component props
- `OnLoadData`, `OnProgressData`, `OnErrorData` - Event payloads
- `VideoSource` - Source configuration with uri and optional headers

## Build System

**react-native-builder-bob** handles the build, outputting:
- CommonJS (`lib/commonjs/`)
- ES Modules (`lib/module/`)
- TypeScript declarations (`lib/typescript/`)

The build runs automatically via the `prepare` npm script.

## Platform Support Status

- **macOS**: ✅ Fully implemented
- **Windows**: 🚧 Planned (no code yet)
- **Linux**: 🚧 Planned (no code yet)

When implementing Windows/Linux, follow the macOS structure as a reference and maintain API compatibility.

## Publishing

Package is scoped as `@jdboivin/react-native-video-desktop`. When publishing:
- First publish requires `--access public` flag
- For prerelease versions, use `--tag beta` or `--tag alpha`
- Version bump with `npm version [patch|minor|major]`

## react-native-video API Compatibility

This library aims for API compatibility with `react-native-video`, meaning:
- Props should match their API where possible
- Event data structures should be consistent
- Imperative methods (seek, pause, play) should work the same way

Not all features are implemented yet (e.g., subtitles, DRM, picture-in-picture).
