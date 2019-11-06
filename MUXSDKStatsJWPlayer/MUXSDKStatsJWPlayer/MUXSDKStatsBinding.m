//
//  MUXSDKStatsBinding.m
//  TestbedObjc
//
//  Created by Ruslan Sokolov on 7/18/19.
//  Copyright © 2019 Ruslan Sokolov. All rights reserved.
//

#import <JWPlayer_iOS_SDK/JWPlayerController.h>
#import <JWPlayer_iOS_SDK/JWPlayerError.h>
#import <JWPlayer_iOS_SDK/JWAdEvent.h>
#import "MUXSDKStatsBinding.h"
#import "MUXSDKStatsDelegateProxy.h"

@import MuxCore;

NSString * const MUXSDKStatsKPluginName = @"jwplayer-mux";
NSString * const MUXSDKStatsPluginVersion = @"0.1.0";

typedef enum : NSUInteger {
    MUXSDKStatsBindingAdProgressStarted,
    MUXSDKStatsBindingAdProgressFirstQuartile,
    MUXSDKStatsBindingAdProgressMidpoint,
    MUXSDKStatsBindingAdProgressThirdQuartile
} MUXSDKStatsBindingAdProgress;

NS_ASSUME_NONNULL_BEGIN

@interface MUXSDKStatsBinding () <JWPlayerDelegate>

@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * software;
@property (nonatomic, strong) JWPlayerController * _Nullable player;
@property (nonatomic, strong) MUXJWPlayerSDKDelegateProxy * delegateProxy;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) BOOL isLive;
@property (nonatomic, strong) id<JWAdImpressionEvent> _Nullable ad;
@property (nonatomic, assign) MUXSDKStatsBindingAdProgress adProgress;

@end

NS_ASSUME_NONNULL_END

@implementation MUXSDKStatsBinding

- (instancetype)initWithName:(NSString *)name software:(NSString *)software delegate:(id<JWPlayerDelegate> _Nullable)delegate {
    if ((self = [super init])) {
        self.name = name;
        self.software = software;

        self.delegateProxy = [MUXJWPlayerSDKDelegateProxy alloc];
        [self.delegateProxy addDelegate:self];
        if (delegate) {
            [self.delegateProxy addDelegate:delegate];
        }
    }
    return self;
}

- (void)attachPlayer:(JWPlayerController *)player {
    if (self.player == NULL) {
        [self detachPlayer];
    }
    self.player = player;
    self.player.delegate = self.delegateProxy;
}

- (void)detachPlayer {
    self.player.delegate = NULL;
    self.player = NULL;
}

- (void)dispatchEvent:(Class)eventType checkVideoData:(BOOL)checkVideoData {
    [self dispatchEvent:eventType checkVideoData:checkVideoData includeAdData:NO error:NULL];
}

- (void)resetVideoData {
    self.size = CGSizeZero;
    self.duration = 0;
    self.isLive = NO;
}

/// MARK: - Private

- (void)dispatchEvent:(Class)eventType
       checkVideoData:(BOOL)checkVideoData
        includeAdData:(BOOL)includeAdData
                error:(JWPlayerError * _Nullable)error {
    if (checkVideoData) {
        [self checkVideoData];
    }

    MUXSDKPlaybackEvent * event = [eventType new];
    event.playerData = self.playerData;
    if (error != NULL) {
        event.playerData.playerErrorCode = @(error.code).stringValue;
        event.playerData.playerErrorMessage = error.description;

        NSError * jsonError = NULL;
        NSData * jsonData = NULL;
        //
        // Sometimes, this throws 'Invalid top-level type in JSON write' and crashes the app
        // you can simulate this error by passing in an invalid ad.tag URL to the JWAdConfig
        //
        // To protect against our error handling crashing the app, let's wrap it in a try/catch
        //
        @try {
            jsonData = [NSJSONSerialization dataWithJSONObject:error options:0 error:&jsonError];
        } @catch (NSException * e) {}
        if (jsonData && !jsonError) {
            event.playerData.playeriOSErrorData = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    }

    if (includeAdData) {
        event.viewData = [self viewDataForAd:self.ad];
    }
    [MUXSDKCore dispatchEvent:event forPlayer:self.name];
}

- (MUXSDKPlayerData * _Nullable)playerData {
    if (self.player == NULL) return NULL;

    MUXSDKPlayerData * data = [MUXSDKPlayerData new];
    data.playerMuxPluginName = MUXSDKStatsKPluginName;
    data.playerMuxPluginVersion = MUXSDKStatsPluginVersion;
    data.playerSoftwareName = self.software;
    data.playerLanguageCode = NSLocale.preferredLanguages.firstObject;
    data.playerWidth = [NSNumber numberWithDouble:self.player.view.bounds.size.width * UIScreen.mainScreen.nativeScale];
    data.playerHeight = [NSNumber numberWithDouble:self.player.view.bounds.size.height *  UIScreen.mainScreen.nativeScale];
    data.playerIsFullscreen = self.player.fullscreen ? @"true" : @"false";
    data.playerIsPaused = [NSNumber numberWithBool:self.player.state == JWPlayerStatePaused];
    data.playerPlayheadTime = [NSNumber numberWithLong:self.player.position * 1000];
    data.playerSoftwareVersion = [self.player.class SDKVersion];
    return data;
}

- (void)checkVideoData {
    if (self.player == NULL || self.ad) return;

    BOOL updated = NO;
    if (!CGSizeEqualToSize(self.size, self.player.naturalSize)) {
        self.size = self.player.naturalSize;
        updated = YES;
    }
    if (fabs(self.duration - self.player.duration) > DBL_EPSILON) {
        self.duration = self.player.duration;
        updated = YES;
    }
    if (self.duration < DBL_EPSILON && self.player.state == JWPlayerStatePlaying && !self.isLive) {
        self.isLive = YES;
        updated = YES;
    }
    if (updated) {
        MUXSDKVideoData * data = [MUXSDKVideoData new];
        if (!CGSizeEqualToSize(self.size, CGSizeZero)) {
            data.videoSourceWidth = [NSNumber numberWithDouble:self.size.width];
            data.videoSourceHeight = [NSNumber numberWithDouble:self.size.height];
        }
        if (self.duration > 0) {
            data.videoSourceDuration = [NSNumber numberWithDouble:(self.duration * 1000)];
        }
        if (self.isLive) {
            data.videoSourceIsLive = @"true";
        }
        MUXSDKDataEvent * event = [MUXSDKDataEvent new];
        event.videoData = data;
        [MUXSDKCore dispatchEvent:event forPlayer:self.name];
    }
}

- (MUXSDKViewData *)viewDataForAd:(id<JWAdImpressionEvent>)event {
    MUXSDKViewData * view = [MUXSDKViewData new];
    view.viewPrerollAdId = event.adTitle;
    view.viewPrerollCreativeId = event.mediaFile;
    return view;
}

/// MARK: - JWPlayerDelegate

- (void)onPlayAttempt {
    [self dispatchEvent:MUXSDKPlayEvent.class checkVideoData:YES includeAdData:NO error:NULL];
}

- (void)onPlay:(JWEvent<JWStateChangeEvent> *)event {
    [self dispatchEvent:MUXSDKPlayingEvent.class checkVideoData:YES includeAdData:NO error:NULL];
}

- (void)onPause:(JWEvent<JWStateChangeEvent> *)event {
    [self dispatchEvent:MUXSDKPauseEvent.class checkVideoData:YES includeAdData:NO error:NULL];
}

- (void)onTime:(JWEvent<JWTimeEvent> *)event {
    [self dispatchEvent:MUXSDKTimeUpdateEvent.class checkVideoData:YES includeAdData:NO error:NULL];
}

- (void)onSeek:(JWEvent<JWSeekEvent> *)event {
    [self dispatchEvent:MUXSDKInternalSeekingEvent.class checkVideoData:NO includeAdData:NO error:NULL];
}

- (void)onSeeked {
    [self dispatchEvent:MUXSDKSeekedEvent.class checkVideoData:NO includeAdData:NO error:NULL];
}

- (void)onError:(JWEvent<JWErrorEvent> *)event {
    [self dispatchEvent:MUXSDKErrorEvent.class checkVideoData:YES includeAdData:NO error:event.error];
}

- (void)onComplete {
    [self dispatchEvent:MUXSDKViewEndEvent.class checkVideoData:YES includeAdData:NO error:NULL];
}

- (void)onAdImpression:(JWAdEvent<JWAdImpressionEvent> *)event {
    self.ad = event;
    self.adProgress = MUXSDKStatsBindingAdProgressStarted;
    [self dispatchEvent:MUXSDKAdResponseEvent.class checkVideoData:YES includeAdData:YES error:NULL];
    [self dispatchEvent:MUXSDKAdBreakStartEvent.class checkVideoData:YES includeAdData:YES error:NULL];
    [self dispatchEvent:MUXSDKAdPlayEvent.class checkVideoData:YES includeAdData:YES error:NULL];
}

- (void)onAdPlay:(JWAdEvent<JWAdStateChangeEvent> *)event {
    [self dispatchEvent:MUXSDKAdPlayingEvent.class checkVideoData:YES includeAdData:YES error:NULL];
}

- (void)onAdTime:(JWAdEvent<JWAdTimeEvent> *)event {
    if (event.position >= event.duration * 0.25) {
        if (self.adProgress < MUXSDKStatsBindingAdProgressFirstQuartile) {
            [self dispatchEvent:MUXSDKAdFirstQuartileEvent.class checkVideoData:YES includeAdData:YES error:NULL];
            self.adProgress = MUXSDKStatsBindingAdProgressFirstQuartile;
        }
    }
    if (event.position >= event.duration * 0.5) {
        if (self.adProgress < MUXSDKStatsBindingAdProgressMidpoint) {
            [self dispatchEvent:MUXSDKAdMidpointEvent.class checkVideoData:YES includeAdData:YES error:NULL];
            self.adProgress = MUXSDKStatsBindingAdProgressMidpoint;
        }
    }
    if (event.position >= event.duration * 0.75) {
        if (self.adProgress < MUXSDKStatsBindingAdProgressThirdQuartile) {
            [self dispatchEvent:MUXSDKAdThirdQuartileEvent.class checkVideoData:YES includeAdData:YES error:NULL];
            self.adProgress = MUXSDKStatsBindingAdProgressThirdQuartile;
        }
    }
}

- (void)onPlaylistItem:(JWEvent<JWPlaylistItemEvent> *)event {
    NSString *sourceUrl = event.item.file;
    if (sourceUrl) {
        MUXSDKVideoData * data = [MUXSDKVideoData new];
        [data setVideoSourceUrl:sourceUrl];
        MUXSDKDataEvent * event = [MUXSDKDataEvent new];
        event.videoData = data;
        [MUXSDKCore dispatchEvent:event forPlayer:self.name];
    }
}

- (void)onAdSkipped:(JWAdEvent<JWAdDetailEvent> *)event {
    [self dispatchEvent:MUXSDKAdEndedEvent.class checkVideoData:YES includeAdData:YES error:NULL];
    [self dispatchEvent:MUXSDKAdBreakEndEvent.class checkVideoData:YES includeAdData:YES error:NULL];
    self.ad = NULL;
}

- (void)onAdComplete:(JWAdEvent<JWAdDetailEvent> *)event {
    [self dispatchEvent:MUXSDKAdEndedEvent.class checkVideoData:YES includeAdData:YES error:NULL];
    [self dispatchEvent:MUXSDKAdBreakEndEvent.class checkVideoData:YES includeAdData:YES error:NULL];
    self.ad = NULL;
}

- (void)onAdPause:(JWAdEvent<JWAdStateChangeEvent> *)event {
    [self dispatchEvent:MUXSDKAdPauseEvent.class checkVideoData:YES includeAdData:YES error:NULL];
}

- (void)onAdError:(JWAdEvent<JWErrorEvent> *)event {
    [self dispatchEvent:MUXSDKAdErrorEvent.class checkVideoData:YES includeAdData:YES error:event.error];
}

- (void)onAdRequest:(JWAdEvent<JWAdRequestEvent> *)event {
    [self dispatchEvent:MUXSDKAdRequestEvent.class checkVideoData:YES includeAdData:YES error:NULL];
}

@end
