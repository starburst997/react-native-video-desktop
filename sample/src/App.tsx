import type {
  OnErrorData,
  OnLoadData,
  OnProgressData,
} from "@jdboivin/react-native-video-desktop"
import VideoDesktop from "@jdboivin/react-native-video-desktop"
import React, { useRef, useState } from "react"
import { ScrollView, StyleSheet, Text, View } from "react-native"

const VIDEO_URL =
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"

function App(): React.JSX.Element {
  const [logs, setLogs] = useState<string[]>([])
  const videoRef = useRef<any>(null)

  const addLog = (message: string) => {
    const timestamp = new Date().toLocaleTimeString()
    setLogs((prev) => [`[${timestamp}] ${message}`, ...prev].slice(0, 50))
  }

  const handleLoad = (data: OnLoadData) => {
    addLog(
      `onLoad: duration=${data.duration.toFixed(2)}s, size=${data.naturalSize.width}x${data.naturalSize.height}`
    )
  }

  const handleProgress = (data: OnProgressData) => {
    addLog(`onProgress: ${data.currentTime.toFixed(2)}s`)
  }

  const handleEnd = () => {
    addLog("onEnd: Video finished playing")
  }

  const handleError = (data: OnErrorData) => {
    addLog(`onError: ${data.error.message}`)
  }

  const handleBuffer = ({ isBuffering }: { isBuffering: boolean }) => {
    addLog(`onBuffer: ${isBuffering ? "buffering..." : "ready"}`)
  }

  const handleReadyForDisplay = () => {
    addLog("onReadyForDisplay: First frame rendered")
  }

  const handleSeek = () => {
    if (videoRef.current) {
      videoRef.current.seek(30)
      addLog("Seeking to 30s")
    }
  }

  return (
    <View style={styles.container}>
      <View style={styles.videoContainer}>
        <VideoDesktop
          ref={videoRef}
          source={{ uri: VIDEO_URL }}
          style={styles.video}
          controls={true}
          resizeMode="contain"
          repeat={true}
          onLoad={handleLoad}
          onProgress={handleProgress}
          onEnd={handleEnd}
          onError={handleError}
          onBuffer={handleBuffer}
          onReadyForDisplay={handleReadyForDisplay}
        />
      </View>

      <View style={styles.logsContainer}>
        <Text style={styles.logsTitle}>Event Logs</Text>
        <ScrollView style={styles.logsScroll}>
          {logs.map((log, index) => (
            <Text key={index} style={styles.logText}>
              {log}
            </Text>
          ))}
        </ScrollView>
      </View>

      {/*<View style={styles.buttonContainer}>
        <TouchableOpacity style={styles.button} onPress={handleSeek}>
          <Text style={styles.buttonText}>Seek to 30s</Text>
        </TouchableOpacity>
      </View>*/}
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#1e1e1e",
  },
  videoContainer: {
    height: 300,
    backgroundColor: "#000",
  },
  video: {
    width: "100%",
    height: "100%",
  },
  logsContainer: {
    flex: 1,
    padding: 16,
  },
  logsTitle: {
    color: "#fff",
    fontSize: 16,
    fontWeight: "bold",
    marginBottom: 8,
  },
  logsScroll: {
    flex: 1,
  },
  logText: {
    color: "#a0a0a0",
    fontSize: 12,
    fontFamily: "Menlo, monospace",
    marginBottom: 4,
  },
  buttonContainer: {
    padding: 16,
    borderTopWidth: 1,
    borderTopColor: "#333",
  },
  button: {
    backgroundColor: "#007AFF",
    padding: 12,
    borderRadius: 8,
    alignItems: "center",
  },
  buttonText: {
    color: "#fff",
    fontSize: 16,
    fontWeight: "600",
  },
})

export default App
