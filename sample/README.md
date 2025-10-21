# VideoSample - react-native-video-desktop Sample App

A simple macOS sample app demonstrating the usage of `@jdboivin/react-native-video-desktop`.

## Features

- Video playback with AVKit/AVFoundation
- Event logging (onLoad, onProgress, onEnd, onError, onBuffer, onReadyForDisplay)
- Seek functionality
- Built-in player controls

## Prerequisites

- Node.js 18+
- Xcode 15+
- CocoaPods
- macOS 11.0+

## Setup

```bash
# Install dependencies
npm install

# Install CocoaPods
npm run pods:macos
```

## Running the App

```bash
# Start Metro bundler
npm start

# In another terminal, run the app
npm run macos
```

## Building for Release

This project uses **Fastlane** for building and code signing.

### Prerequisites

```bash
# Install Ruby dependencies
bundle install
```

### Build Commands

**Unsigned Build** (for testing):
```bash
bundle exec fastlane mac test_build
```

**Signed Build with Fastlane Match** (recommended):
```bash
bundle exec fastlane mac release
```

The built app will be available at `dist/VideoSample-macOS.zip`.

### Code Signing with Fastlane Match

This project uses Fastlane Match to manage code signing certificates. See the [Fastlane Code Signing Guide](../docs/CODE_SIGNING_FASTLANE.md) for setup instructions.

Required environment variables for signed builds:
- `MATCH_GIT_URL`: Your Match certificates repository
- `MATCH_PASSWORD`: Match encryption password
- `APPLE_ID`: Your Apple ID email
- `APPLE_ID_PASSWORD`: App-specific password
- `APPLE_TEAM_ID`: Your team ID

## Project Structure

```
sample/
├── src/
│   └── App.tsx              # Main React component
├── macos/
│   ├── VideoSample-macOS/   # Native macOS code
│   │   ├── AppDelegate.mm   # App entry point
│   │   └── ...
│   ├── VideoSample.xcodeproj/
│   └── Podfile              # CocoaPods dependencies
├── scripts/
│   ├── build-macos.sh       # Build script (no signing)
│   └── build-macos-signed.sh # Build script (with signing)
└── package.json
```

## Fastlane Lanes

Available Fastlane lanes (defined in `fastlane/Fastfile`):

| Lane | Description |
|------|-------------|
| `sync_certificates` | Downloads certificates from Fastlane Match |
| `build_unsigned` | Builds the app without code signing |
| `build_signed` | Builds, signs, and notarizes the app |
| `release` | Full release build (pods + build + sign + notarize + zip) |
| `test_build` | Quick unsigned build for testing |

### Code Signing Setup for CI/CD

See the complete [Fastlane Code Signing Guide](../docs/CODE_SIGNING_FASTLANE.md) for:
- Setting up Fastlane Match
- Configuring GitHub Actions secrets
- SSH key setup for Match repository
- Troubleshooting common issues

## Troubleshooting

### "Command PhaseScriptExecution failed"

Make sure Node is in your PATH and `.xcode.env` is properly configured.

### CocoaPods Issues

```bash
cd macos
pod deintegrate
pod install
```

### Build Fails with Code Signing Errors

Verify your certificate is valid and not expired:

```bash
security find-identity -v -p codesigning
```

## License

MIT
