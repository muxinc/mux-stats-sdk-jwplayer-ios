//
//  MUXSDKStatsBinding.h
//  TestbedObjc
//
//  Created by Ruslan Sokolov on 7/18/19.
//  Copyright © 2019 Ruslan Sokolov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MUXSDKStatsBinding : NSObject

- (instancetype)initWithName:(NSString *)name software:(NSString *)software delegate:(id<JWPlayerDelegate>)delegate;
- (void)attachPlayer:(JWPlayerController *)player;
- (void)detachPlayer;
- (void)dispatchEvent:(Class)eventType checkVideoData:(BOOL)checkVideoData;
- (void)resetVideoData;

@end

NS_ASSUME_NONNULL_END
