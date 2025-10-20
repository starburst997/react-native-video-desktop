#import "RNVideoDesktopView.h"

@interface RNVideoDesktopView ()

@property (nonatomic, strong) AVPlayerView *playerView;
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

- (void)setupPlayer
{
  self.playerView = [[AVPlayerView alloc] init];
  self.playerView.controlsStyle = AVPlayerViewControlsStyleNone;
  self.playerView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

  [self addSubview:self.playerView];

  // Default values
  _paused = NO;
  _repeat = NO;
  _rate = 1.0;
  _volume = 1.0;
  _muted = NO;
  _controls = NO;
  _resizeMode = @"contain";
}

- (void)layout
{
  [super layout];
  self.playerView.frame = self.bounds;
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

  // Create or update player
  if (!self.player) {
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerView.player = self.player;
  } else {
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
  }

  // Add observers
  [self addObservers];

  // Apply current settings
  [self applyModifiers];
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
  if (self.playerView) {
    self.playerView.controlsStyle = controls ? AVPlayerViewControlsStyleDefault : AVPlayerViewControlsStyleNone;
  }
}

- (void)setResizeMode:(NSString *)resizeMode
{
  _resizeMode = resizeMode;

  if ([resizeMode isEqualToString:@"cover"]) {
    self.playerView.videoGravity = AVLayerVideoGravityResizeAspectFill;
  } else if ([resizeMode isEqualToString:@"stretch"]) {
    self.playerView.videoGravity = AVLayerVideoGravityResize;
  } else {
    self.playerView.videoGravity = AVLayerVideoGravityResizeAspect;
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
