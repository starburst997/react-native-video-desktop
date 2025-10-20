#import "RNVideoDesktopView.h"

@interface RNVideoDesktopView ()

@property (nonatomic, strong) NSView *videoContainerView;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) NSView *testContainerView;
@property (nonatomic, strong) AVPlayerLayer *testPlayerLayer;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, assign) BOOL isPlaying;

@end

@implementation RNVideoDesktopView

- (instancetype)initWithFrame:(NSRect)frameRect
{
  if (self = [super initWithFrame:frameRect]) {
    [self setupPlayer];
  }
  return self;
}

// Don't override makeBackingLayer - let React Native create its own layer

- (void)setupPlayer
{
  // Create player immediately
  self.player = [AVPlayer new];

  // Default values
  _paused = NO;
  _repeat = NO;
  _rate = 1.0;
  _volume = 1.0;
  _muted = NO;
  _controls = NO;
  _resizeMode = @"contain";

  // Create a FIXED SIZE dedicated container view for video (400x300)
  self.videoContainerView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
  self.videoContainerView.wantsLayer = YES;
  self.videoContainerView.layer.backgroundColor = [[NSColor clearColor] CGColor];

  // Create player layer with FIXED SIZE filling the container
  self.playerLayer = [AVPlayerLayer layer];
  self.playerLayer.frame = NSMakeRect(0, 0, 400, 300);
  self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
  self.playerLayer.player = self.player;
  self.playerLayer.backgroundColor = [[NSColor clearColor] CGColor];
  [self.videoContainerView.layer addSublayer:self.playerLayer];

  // Create TEST container with FIXED position and size
  self.testContainerView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
  self.testContainerView.wantsLayer = YES;
  self.testContainerView.layer.backgroundColor = [[NSColor greenColor] CGColor];

  // Create TEST player layer
  self.testPlayerLayer = [AVPlayerLayer layer];
  self.testPlayerLayer.frame = NSMakeRect(0, 0, 400, 300);
  self.testPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
  self.testPlayerLayer.player = self.player;
  self.testPlayerLayer.backgroundColor = [[NSColor redColor] CGColor];
  [self.testContainerView.layer addSublayer:self.testPlayerLayer];

  // Don't add as subview yet - wait for viewDidMoveToWindow
}

- (void)viewDidMoveToWindow
{
  [super viewDidMoveToWindow];

  if (self.window && self.videoContainerView.superview == nil) {
    NSView *contentView = self.window.contentView;

    // Add dynamic container to window's content view
    [contentView addSubview:self.videoContainerView positioned:NSWindowAbove relativeTo:nil];

    // Add TEST container with FIXED position
    self.testContainerView.frame = NSMakeRect(50, 50, 400, 300);
    [contentView addSubview:self.testContainerView positioned:NSWindowAbove relativeTo:nil];

    // Update position and size to match our view
    [self updateVideoContainerFrame];
  }
}

- (void)updateVideoContainerFrame
{
  NSLog(@"[RNVideoDesktop] updateVideoContainerFrame called - bounds: %@, window: %@", NSStringFromRect(self.bounds), self.window ? @"YES" : @"NO");

  if (!self.window || !self.videoContainerView) {
    NSLog(@"[RNVideoDesktop] Early return - window or container is nil");
    return;
  }

  // Convert our frame to window coordinates
  NSRect frameInWindow = [self convertRect:self.bounds toView:nil];

  NSLog(@"[RNVideoDesktop] Frame in window: %@", NSStringFromRect(frameInWindow));

  // Send frame update event for debugging
  if (self.onVideoFrameUpdate) {
    NSLog(@"[RNVideoDesktop] Sending frame update event");
    self.onVideoFrameUpdate(@{
      @"viewBounds": @{
        @"x": @(self.bounds.origin.x),
        @"y": @(self.bounds.origin.y),
        @"width": @(self.bounds.size.width),
        @"height": @(self.bounds.size.height)
      },
      @"frameInWindow": @{
        @"x": @(frameInWindow.origin.x),
        @"y": @(frameInWindow.origin.y),
        @"width": @(frameInWindow.size.width),
        @"height": @(frameInWindow.size.height)
      }
    });
  } else {
    NSLog(@"[RNVideoDesktop] onVideoFrameUpdate is nil!");
  }

  // Update video container frame
  self.videoContainerView.frame = frameInWindow;

  // Update player layer to match container bounds
  if (self.playerLayer) {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.playerLayer.frame = self.videoContainerView.bounds;
    [CATransaction commit];
  }
}

- (void)layout
{
  [super layout];

  // Update video container whenever our layout changes
  [self updateVideoContainerFrame];
}

// Override to prevent React Native from setting background color
- (void)setBackgroundColor:(NSColor *)backgroundColor
{
  // Intentionally do nothing - we manage our own layer backgrounds
}

- (void)dealloc
{
  [self removeObservers];
}

#pragma mark - Property Setters

- (void)setSource:(NSDictionary *)source
{
  _source = source;

  if (!source || !source[@"uri"]) {
    return;
  }

  NSString *uri = source[@"uri"];
  NSURL *url = [NSURL URLWithString:uri];

  // Create player item
  self.playerItem = [AVPlayerItem playerItemWithURL:url];

  // Remove old observers
  [self removeObservers];

  // Replace player item
  [self.player replaceCurrentItemWithPlayerItem:self.playerItem];

  // Add observers
  [self addObservers];

  // Apply current settings including resize mode
  [self applyModifiers];
  [self setResizeMode:self.resizeMode];
}

- (void)setPaused:(BOOL)paused
{
  _paused = paused;

  if (self.player) {
    if (paused) {
      [self.player pause];
    } else {
      [self.player play];
    }
  }
}

- (void)setRepeat:(BOOL)repeat
{
  _repeat = repeat;
}

- (void)setRate:(float)rate
{
  _rate = rate;
  if (self.player && !self.paused) {
    self.player.rate = rate;
  }
}

- (void)setVolume:(float)volume
{
  _volume = volume;
  if (self.player) {
    self.player.volume = volume;
  }
}

- (void)setMuted:(BOOL)muted
{
  _muted = muted;
  if (self.player) {
    self.player.muted = muted;
  }
}

- (void)setControls:(BOOL)controls
{
  _controls = controls;
  // Note: AVPlayerLayer doesn't support built-in controls
  // Controls would need to be implemented separately if needed
}

- (void)setResizeMode:(NSString *)resizeMode
{
  _resizeMode = resizeMode;

  if ([resizeMode isEqualToString:@"cover"]) {
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
  } else if ([resizeMode isEqualToString:@"stretch"]) {
    self.playerLayer.videoGravity = AVLayerVideoGravityResize;
  } else {
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
  }
}

#pragma mark - Observers

- (void)addObservers
{
  if (!self.playerItem) return;

  // Player item status
  [self.playerItem addObserver:self
                    forKeyPath:@"status"
                       options:NSKeyValueObservingOptionNew
                       context:nil];

  // Player item duration
  [self.playerItem addObserver:self
                    forKeyPath:@"duration"
                       options:NSKeyValueObservingOptionNew
                       context:nil];

  // Playback finished
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(playerItemDidPlayToEnd:)
                                               name:AVPlayerItemDidPlayToEndTimeNotification
                                             object:self.playerItem];

  // Time observer for progress
  __weak typeof(self) weakSelf = self;
  self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 4)
                                                                queue:dispatch_get_main_queue()
                                                           usingBlock:^(CMTime time) {
    [weakSelf sendProgressUpdate];
  }];
}

- (void)removeObservers
{
  if (self.playerItem) {
    @try {
      [self.playerItem removeObserver:self forKeyPath:@"status"];
      [self.playerItem removeObserver:self forKeyPath:@"duration"];
    } @catch (NSException *exception) {
      // Ignore if not observing
    }
  }

  [[NSNotificationCenter defaultCenter] removeObserver:self];

  if (self.timeObserver) {
    [self.player removeTimeObserver:self.timeObserver];
    self.timeObserver = nil;
  }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  if ([keyPath isEqualToString:@"status"]) {
    AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];

    switch (status) {
      case AVPlayerItemStatusReadyToPlay:
        [self onVideoLoadReady];
        if (self.onVideoReadyForDisplay) {
          self.onVideoReadyForDisplay(@{});
        }
        // Trigger frame update when video is ready
        [self updateVideoContainerFrame];
        break;

      case AVPlayerItemStatusFailed:
        [self onVideoError];
        break;

      default:
        break;
    }
  }
}

#pragma mark - Notifications

- (void)playerItemDidPlayToEnd:(NSNotification *)notification
{
  if (self.onVideoEnd) {
    self.onVideoEnd(@{});
  }

  if (self.repeat) {
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
  }
}

#pragma mark - Events

- (void)onVideoLoadReady
{
  if (!self.onVideoLoad || !self.playerItem) return;

  CMTime duration = self.playerItem.duration;
  Float64 durationSeconds = CMTimeGetSeconds(duration);

  Float64 currentSeconds = CMTimeGetSeconds(self.player.currentTime);

  NSArray *tracks = [self.playerItem.asset tracksWithMediaType:AVMediaTypeVideo];
  CGSize videoSize = CGSizeZero;

  if (tracks.count > 0) {
    AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
    videoSize = videoTrack.naturalSize;
  }

  self.onVideoLoad(@{
    @"duration": @(durationSeconds),
    @"currentTime": @(currentSeconds),
    @"naturalSize": @{
      @"width": @(videoSize.width),
      @"height": @(videoSize.height),
      @"orientation": videoSize.width > videoSize.height ? @"landscape" : @"portrait"
    }
  });
}

- (void)sendProgressUpdate
{
  if (!self.onVideoProgress || !self.player || !self.playerItem) return;

  Float64 currentSeconds = CMTimeGetSeconds(self.player.currentTime);
  Float64 durationSeconds = CMTimeGetSeconds(self.playerItem.duration);

  self.onVideoProgress(@{
    @"currentTime": @(currentSeconds),
    @"playableDuration": @(durationSeconds),
    @"seekableDuration": @(durationSeconds)
  });
}

- (void)onVideoError
{
  if (!self.onVideoError || !self.playerItem) return;

  NSError *error = self.playerItem.error;
  NSString *errorMessage = error ? error.localizedDescription : @"Unknown error";

  self.onVideoError(@{
    @"error": @{
      @"errorString": errorMessage,
      @"errorCode": error ? @(error.code).stringValue : @"unknown"
    }
  });
}

#pragma mark - Commands

- (void)seek:(float)time
{
  if (self.player) {
    CMTime cmTime = CMTimeMakeWithSeconds(time, NSEC_PER_SEC);
    [self.player seekToTime:cmTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
  }
}

- (void)pause
{
  self.paused = YES;
}

- (void)play
{
  self.paused = NO;
}

#pragma mark - Helper Methods

- (void)applyModifiers
{
  if (self.player) {
    self.player.rate = self.paused ? 0.0 : self.rate;
    self.player.volume = self.volume;
    self.player.muted = self.muted;
  }
}

@end
