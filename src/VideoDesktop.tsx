import React, { useRef, useEffect, useCallback } from 'react';
import {
  requireNativeComponent,
  UIManager,
  findNodeHandle,
  NativeModules,
  Platform,
} from 'react-native';
import type { VideoDesktopProps, OnLoadData, OnProgressData, OnErrorData, OnFrameUpdateData } from './types';

const COMPONENT_NAME = 'RNVideoDesktop';

interface NativeVideoDesktopProps extends VideoDesktopProps {
  onVideoLoad?: (event: { nativeEvent: OnLoadData }) => void;
  onVideoProgress?: (event: { nativeEvent: OnProgressData }) => void;
  onVideoEnd?: (event: any) => void;
  onVideoError?: (event: { nativeEvent: OnErrorData }) => void;
  onVideoBuffer?: (event: { nativeEvent: { isBuffering: boolean } }) => void;
  onVideoReadyForDisplay?: (event: any) => void;
  onVideoPlaybackStateChanged?: (event: { nativeEvent: { isPlaying: boolean } }) => void;
  onVideoFrameUpdate?: (event: { nativeEvent: OnFrameUpdateData }) => void;
}

const RNVideoDesktopNative =
  requireNativeComponent<NativeVideoDesktopProps>(COMPONENT_NAME);

const VideoDesktop = React.forwardRef<any, VideoDesktopProps>((props, ref) => {
  const {
    onLoad,
    onProgress,
    onEnd,
    onError,
    onBuffer,
    onReadyForDisplay,
    onPlaybackStateChanged,
    onFrameUpdate,
    ...restProps
  } = props;

  const nativeRef = useRef<any>(null);

  // Expose ref methods
  React.useImperativeHandle(ref, () => ({
    seek: (time: number) => {
      const handle = findNodeHandle(nativeRef.current);
      if (handle && UIManager.dispatchViewManagerCommand) {
        UIManager.dispatchViewManagerCommand(handle, 'seek', [time]);
      }
    },
    pause: () => {
      const handle = findNodeHandle(nativeRef.current);
      if (handle && UIManager.dispatchViewManagerCommand) {
        UIManager.dispatchViewManagerCommand(handle, 'pause', []);
      }
    },
    play: () => {
      const handle = findNodeHandle(nativeRef.current);
      if (handle && UIManager.dispatchViewManagerCommand) {
        UIManager.dispatchViewManagerCommand(handle, 'play', []);
      }
    },
  }));

  const handleLoad = useCallback(
    (event: { nativeEvent: OnLoadData }) => {
      onLoad?.(event.nativeEvent);
    },
    [onLoad]
  );

  const handleProgress = useCallback(
    (event: { nativeEvent: OnProgressData }) => {
      onProgress?.(event.nativeEvent);
    },
    [onProgress]
  );

  const handleEnd = useCallback(() => {
    onEnd?.();
  }, [onEnd]);

  const handleError = useCallback(
    (event: { nativeEvent: OnErrorData }) => {
      onError?.(event.nativeEvent);
    },
    [onError]
  );

  const handleBuffer = useCallback(
    (event: { nativeEvent: { isBuffering: boolean } }) => {
      onBuffer?.(event.nativeEvent);
    },
    [onBuffer]
  );

  const handleReadyForDisplay = useCallback(() => {
    onReadyForDisplay?.();
  }, [onReadyForDisplay]);

  const handlePlaybackStateChanged = useCallback(
    (event: { nativeEvent: { isPlaying: boolean } }) => {
      onPlaybackStateChanged?.(event.nativeEvent);
    },
    [onPlaybackStateChanged]
  );

  const handleFrameUpdate = useCallback(
    (event: { nativeEvent: OnFrameUpdateData }) => {
      onFrameUpdate?.(event.nativeEvent);
    },
    [onFrameUpdate]
  );

  return (
    <RNVideoDesktopNative
      ref={nativeRef}
      {...restProps}
      onVideoLoad={handleLoad}
      onVideoProgress={handleProgress}
      onVideoEnd={handleEnd}
      onVideoError={handleError}
      onVideoBuffer={handleBuffer}
      onVideoReadyForDisplay={handleReadyForDisplay}
      onVideoPlaybackStateChanged={handlePlaybackStateChanged}
      onVideoFrameUpdate={handleFrameUpdate}
    />
  );
});

VideoDesktop.displayName = 'VideoDesktop';

export default VideoDesktop;
