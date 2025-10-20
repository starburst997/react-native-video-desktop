import type { ViewStyle } from 'react-native';

export type ResizeMode = 'contain' | 'cover' | 'stretch';

export interface VideoSource {
  uri: string;
  headers?: { [key: string]: string };
}

export interface OnLoadData {
  duration: number;
  currentTime: number;
  naturalSize: {
    width: number;
    height: number;
    orientation: 'landscape' | 'portrait';
  };
}

export interface OnProgressData {
  currentTime: number;
  playableDuration: number;
  seekableDuration: number;
}

export interface OnErrorData {
  error: {
    errorString: string;
    errorException?: string;
    errorCode?: string;
  };
}

export interface VideoDesktopProps {
  source: VideoSource;
  style?: ViewStyle;

  // Playback control
  paused?: boolean;
  repeat?: boolean;
  rate?: number;
  volume?: number;
  muted?: boolean;
  controls?: boolean;
  seek?: number;

  // Display
  resizeMode?: ResizeMode;
  poster?: string;
  posterResizeMode?: ResizeMode;

  // Events
  onLoad?: (data: OnLoadData) => void;
  onProgress?: (data: OnProgressData) => void;
  onEnd?: () => void;
  onError?: (data: OnErrorData) => void;
  onBuffer?: (data: { isBuffering: boolean }) => void;
  onReadyForDisplay?: () => void;
  onPlaybackStateChanged?: (data: { isPlaying: boolean }) => void;
}
