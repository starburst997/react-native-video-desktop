# react-native-video-desktop

A video component for React Native desktop platforms (macOS, Windows, Linux) with a `react-native-video` compatible API.

[![npm version](https://badge.fury.io/js/react-native-video-desktop.svg)](https://badge.fury.io/js/react-native-video-desktop)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

`react-native-video-desktop` provides native video playback capabilities for React Native desktop applications. It's designed to be a drop-in replacement for `react-native-video` on desktop platforms, offering a familiar API while leveraging native video frameworks.

### Platform Support

| Platform | Status         | Framework        |
| -------- | -------------- | ---------------- |
| macOS    | ✅ Implemented | AVKit            |
| Windows  | 🚧 Planned     | Media Foundation |
| Linux    | 🚧 Planned     | GStreamer        |

## Features

- ✅ Native video playback using platform-specific frameworks
- ✅ Compatible with `react-native-video` API
- ✅ Support for local and remote video files
- ✅ Playback controls (play, pause, seek)
- ✅ Video styling (resize modes)
- ✅ Event callbacks (onLoad, onProgress, onEnd, etc.)
- ✅ TypeScript support

## Installation

```bash
npm install react-native-video-desktop
# or
yarn add react-native-video-desktop
# or
pnpm add react-native-video-desktop
```

### macOS

After installing the package, you need to install the CocoaPods dependencies:

```bash
cd macos && pod install
```

Then rebuild your app:

```bash
npm run macos
# or
react-native run-macos
```

### Windows

_Coming soon_

### Linux

_Coming soon_

## Usage

```tsx
import React from "react"
import { View, StyleSheet } from "react-native"
import Video from "react-native-video-desktop"

function App() {
  return (
    <View style={styles.container}>
      <Video
        source={{ uri: "https://example.com/video.mp4" }}
        style={styles.video}
        controls={true}
        resizeMode="contain"
        repeat={true}
        onLoad={(data) => console.log("Video loaded", data)}
        onProgress={(data) => console.log("Progress", data)}
        onEnd={() => console.log("Video ended")}
      />
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  video: {
    width: "100%",
    height: 400,
  },
})

export default App
```

## Props

### Video Source

```tsx
source: {
  uri: string;           // URL or local file path
  headers?: object;      // HTTP headers (for remote videos)
}
```

### Playback Control

| Prop       | Type    | Default | Description                                          |
| ---------- | ------- | ------- | ---------------------------------------------------- |
| `paused`   | boolean | `false` | Controls whether the media is paused                 |
| `repeat`   | boolean | `false` | Repeat the video when it ends                        |
| `rate`     | number  | `1.0`   | Playback rate (0.5 = half speed, 2.0 = double speed) |
| `volume`   | number  | `1.0`   | Volume level (0.0 to 1.0)                            |
| `muted`    | boolean | `false` | Mutes the audio                                      |
| `controls` | boolean | `false` | Show native playback controls                        |
| `seek`     | number  | -       | Seek to specified time in seconds                    |

### Display

| Prop         | Type                              | Default     | Description                         |
| ------------ | --------------------------------- | ----------- | ----------------------------------- |
| `resizeMode` | 'contain' \| 'cover' \| 'stretch' | `'contain'` | How the video fits in the container |
| `style`      | ViewStyle                         | -           | Style for the video container       |
| `poster`     | string                            | -           | Image to show before video loads    |

### Events

| Callback                | Description                                |
| ----------------------- | ------------------------------------------ |
| `onLoad(data)`          | Called when video loads successfully       |
| `onProgress(data)`      | Called periodically during playback        |
| `onEnd()`               | Called when video reaches the end          |
| `onError(error)`        | Called when an error occurs                |
| `onBuffer(isBuffering)` | Called when buffering state changes        |
| `onReadyForDisplay()`   | Called when video is ready to be displayed |

#### Event Data Structures

**onLoad:**

```tsx
{
  duration: number // Video duration in seconds
  currentTime: number // Current playback position
  naturalSize: {
    width: number
    height: number
  }
}
```

**onProgress:**

```tsx
{
  currentTime: number // Current playback position
  playableDuration: number
  seekableDuration: number
}
```

## Example

See the [example](./example) directory for a complete working example.

## API Compatibility

This library aims to maintain API compatibility with `react-native-video`. However, some features may not be available on all platforms. The following table shows the current implementation status:

| Feature            | macOS | Windows | Linux |
| ------------------ | ----- | ------- | ----- |
| Basic playback     | ✅    | 🚧      | 🚧    |
| Controls           | ✅    | 🚧      | 🚧    |
| Seeking            | ✅    | 🚧      | 🚧    |
| Volume control     | ✅    | 🚧      | 🚧    |
| Playback rate      | ✅    | 🚧      | 🚧    |
| Resize modes       | ✅    | 🚧      | 🚧    |
| Subtitles          | ⏳    | 🚧      | 🚧    |
| DRM                | ⏳    | 🚧      | 🚧    |
| Picture-in-Picture | ⏳    | 🚧      | 🚧    |

**Legend:** ✅ Implemented | 🚧 Planned | ⏳ Under consideration

## Development

### Prerequisites

- Node.js 18+
- React Native development environment set up for your target platform
- For macOS: Xcode and CocoaPods

### Building

```bash
git clone https://github.com/yourusername/react-native-video-desktop.git
cd react-native-video-desktop
npm install
npm run prepare
```

### Running the Example

```bash
cd example
npm install
npm run macos
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

See [CONTRIBUTING.md](./CONTRIBUTING.md) for more details.

### Help Wanted

We're especially looking for contributors to help with:

- Windows implementation using Media Foundation
- Linux implementation using GStreamer
- Additional features (subtitles, DRM, etc.)
- Bug fixes and testing

## License

MIT License - see the [LICENSE](./LICENSE) file for details.

## Acknowledgments

- Inspired by [react-native-video](https://github.com/react-native-video/react-native-video)
- Built for the [react-native-macos](https://github.com/microsoft/react-native-macos) community

## Related Projects

- [react-native-video](https://github.com/react-native-video/react-native-video) - The original React Native video component for iOS and Android
- [react-native-macos](https://github.com/microsoft/react-native-macos) - React Native for macOS
- [react-native-windows](https://github.com/microsoft/react-native-windows) - React Native for Windows

## Support

- [Issue Tracker](https://github.com/yourusername/react-native-video-desktop/issues)
- [Discussions](https://github.com/yourusername/react-native-video-desktop/discussions)
