//
//  MUXSDKStatsDelegateProxy.h
//  TestbedObjc
//
//  Created by Ruslan Sokolov on 7/11/19.
//  Copyright © 2019 Ruslan Sokolov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JWPlayer_iOS_SDK/JWPlayerDelegate.h>

NS_ASSUME_NONNULL_BEGIN

@interface MUXJWPlayerSDKDelegateProxy : NSProxy<JWPlayerDelegate>

- (void)addDelegate:(id<JWPlayerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
