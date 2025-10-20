#import "RNVideoDesktopManager.h"
#import "RNVideoDesktopView.h"
#import <React/RCTBridge.h>
#import <React/RCTUIManager.h>

@implementation RNVideoDesktopManager

RCT_EXPORT_MODULE(RNVideoDesktop)

- (NSView *)view
{
  return [[RNVideoDesktopView alloc] init];
}

// Export props
RCT_EXPORT_VIEW_PROPERTY(source, NSDictionary)
RCT_EXPORT_VIEW_PROPERTY(paused, BOOL)
RCT_EXPORT_VIEW_PROPERTY(repeat, BOOL)
RCT_EXPORT_VIEW_PROPERTY(rate, float)
RCT_EXPORT_VIEW_PROPERTY(volume, float)
RCT_EXPORT_VIEW_PROPERTY(muted, BOOL)
RCT_EXPORT_VIEW_PROPERTY(controls, BOOL)
RCT_EXPORT_VIEW_PROPERTY(resizeMode, NSString)

// Export events
RCT_EXPORT_VIEW_PROPERTY(onVideoLoad, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onVideoProgress, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onVideoEnd, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onVideoError, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onVideoBuffer, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onVideoReadyForDisplay, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onVideoPlaybackStateChanged, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onVideoFrameUpdate, RCTDirectEventBlock)

// Export commands
RCT_EXPORT_METHOD(seek:(nonnull NSNumber *)reactTag time:(NSNumber *)time)
{
  [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, NSView *> *viewRegistry) {
    RNVideoDesktopView *view = (RNVideoDesktopView *)viewRegistry[reactTag];
    if ([view isKindOfClass:[RNVideoDesktopView class]]) {
      [view seek:time.floatValue];
    }
  }];
}

RCT_EXPORT_METHOD(pause:(nonnull NSNumber *)reactTag)
{
  [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, NSView *> *viewRegistry) {
    RNVideoDesktopView *view = (RNVideoDesktopView *)viewRegistry[reactTag];
    if ([view isKindOfClass:[RNVideoDesktopView class]]) {
      [view pause];
    }
  }];
}

RCT_EXPORT_METHOD(play:(nonnull NSNumber *)reactTag)
{
  [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, NSView *> *viewRegistry) {
    RNVideoDesktopView *view = (RNVideoDesktopView *)viewRegistry[reactTag];
    if ([view isKindOfClass:[RNVideoDesktopView class]]) {
      [view play];
    }
  }];
}

@end
