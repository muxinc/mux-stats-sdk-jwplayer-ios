//
//  MuxJWPlayerSDK.m
//  TestbedObjc
//
//  Created by Ruslan Sokolov on 7/18/19.
//  Copyright © 2019 Ruslan Sokolov. All rights reserved.
//

#import <sys/utsname.h>
#import <JWPlayer_iOS_SDK/JWPlayerController.h>
#import "MUXSDKStatsJWPlayer.h"
#import "MUXSDKStatsBinding.h"

NSString * const MUXSDKStatsSoftware = @"JWPlayerController";

static NSMutableDictionary<NSString *, MUXSDKStatsBinding *> * __bindings;

@implementation MUXSDKStatsJWPlayer

+ (void)monitorJWPlayerController:(JWPlayerController *)controller
                             name:(NSString *)name
                         delegate:(id<JWPlayerDelegate> _Nullable)delegate
                       playerData:(MUXSDKCustomerPlayerData *)playerData
                        videoData:(MUXSDKCustomerVideoData *)videoData {
    [self initSDK];

    if ([__bindings.allKeys containsObject:name]) {
        [self destroyPlayerWithName:name];
    }

    MUXSDKStatsBinding * player = [[MUXSDKStatsBinding alloc] initWithName:name software:MUXSDKStatsSoftware delegate:delegate];
    [player attachPlayer:controller];
    __bindings[name] = player;

    [player dispatchEvent:MUXSDKViewInitEvent.class checkVideoData:NO];
    [self dispatchDataEventForPlayerName:name playerData:playerData videoData:videoData];
    [player dispatchEvent:MUXSDKPlayerReadyEvent.class checkVideoData:NO];
}

+ (void)videoChangeForPlayerWithName:(NSString *)name videoData:(MUXSDKCustomerVideoData *)videoData {
    MUXSDKStatsBinding * player = __bindings[name];
    if (!player) return;

    [player dispatchEvent:MUXSDKViewEndEvent.class checkVideoData:YES];
    [player resetVideoData];
    [player dispatchEvent:MUXSDKViewInitEvent.class checkVideoData:NO];

    MUXSDKDataEvent * event = [MUXSDKDataEvent new];
    event.customerVideoData = videoData;
    event.videoChange = YES;
    [MUXSDKCore dispatchEvent:event forPlayer:name];
}

+ (void)destroyPlayerWithName:(NSString *)name {
    MUXSDKStatsBinding * player = __bindings[name];
    [__bindings removeObjectForKey:name];
    [player detachPlayer];
}

    /// MARK: - Private

+ (void)initSDK {
    if (!__bindings) {
        __bindings = [NSMutableDictionary new];
    }

    MUXSDKEnvironmentData * env = [MUXSDKEnvironmentData new];
    env.muxViewerId = UIDevice.currentDevice.identifierForVendor.UUIDString;

    MUXSDKViewerData * viewer = [MUXSDKViewerData new];
    viewer.viewerApplicationName = NSBundle.mainBundle.bundleIdentifier;

    NSString * shortVersion = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * version = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    if (shortVersion && version) {
        viewer.viewerApplicationVersion = [NSString stringWithFormat:@"%@ (%@)", shortVersion, version];
    } else {
        viewer.viewerApplicationVersion = shortVersion ? shortVersion : version;
    }

    viewer.viewerDeviceManufacturer = @"Apple";

    struct utsname systemInfo;
    uname(&systemInfo);
    viewer.viewerDeviceName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    NSString *deviceCategory = @"unknown";
    NSString *osFamily = @"unknown";
    switch (UIDevice.currentDevice.userInterfaceIdiom) {
        case UIUserInterfaceIdiomTV:
            deviceCategory = @"tv";
            osFamily = @"tvOS";
            break;
        case UIUserInterfaceIdiomPad:
            deviceCategory = @"tablet";
            osFamily = @"iOS";
            break;
        case UIUserInterfaceIdiomPhone:
            deviceCategory = @"phone";
            osFamily = @"iOS";
            break;
        case UIUserInterfaceIdiomCarPlay:
            deviceCategory = @"car";
            osFamily = @"CarPlay";
            break;
        default:
            break;
    }
    viewer.viewerDeviceCategory = deviceCategory;
    viewer.viewerOsFamily = osFamily;
    viewer.viewerOsVersion = UIDevice.currentDevice.systemVersion;

    MUXSDKDataEvent * event = [MUXSDKDataEvent new];
    event.environmentData = env;
    event.viewerData = viewer;
    [MUXSDKCore dispatchGlobalDataEvent:event];
}

+ (void)dispatchDataEventForPlayerName:(NSString *)name
                            playerData:(MUXSDKCustomerPlayerData *)playerData
                             videoData:(MUXSDKCustomerVideoData *)videoData {
    MUXSDKDataEvent * event = [MUXSDKDataEvent new];
    event.customerPlayerData = playerData;
    event.customerVideoData = videoData;
    [MUXSDKCore dispatchEvent:event forPlayer:name];
}

@end
