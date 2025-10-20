#import <AppKit/AppKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <React/RCTComponent.h>

@interface RNVideoDesktopView : NSView

@property (nonatomic, copy) NSDictionary *source;
@property (nonatomic, assign) BOOL paused;
@property (nonatomic, assign) BOOL repeat;
@property (nonatomic, assign) float rate;
@property (nonatomic, assign) float volume;
@property (nonatomic, assign) BOOL muted;
@property (nonatomic, assign) BOOL controls;
@property (nonatomic, copy) NSString *resizeMode;

@property (nonatomic, copy) RCTDirectEventBlock onVideoLoad;
@property (nonatomic, copy) RCTDirectEventBlock onVideoProgress;
@property (nonatomic, copy) RCTDirectEventBlock onVideoEnd;
@property (nonatomic, copy) RCTDirectEventBlock onVideoError;
@property (nonatomic, copy) RCTDirectEventBlock onVideoBuffer;
@property (nonatomic, copy) RCTDirectEventBlock onVideoReadyForDisplay;
@property (nonatomic, copy) RCTDirectEventBlock onVideoPlaybackStateChanged;

- (void)seek:(float)time;
- (void)pause;
- (void)play;

@end
