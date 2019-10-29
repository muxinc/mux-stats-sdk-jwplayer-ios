//
//  MUXSDKStatsJWPlayer.h
//  TestbedObjc
//
//  Created by Ruslan Sokolov on 7/18/19.
//  Copyright © 2019 Ruslan Sokolov. All rights reserved.
//

#import <Foundation/Foundation.h>

@import MuxCore;

NS_ASSUME_NONNULL_BEGIN

@class JWPlayerController;
@protocol JWPlayerDelegate;

/*!
 @class            MUXSDKStatsJWPlayer

 @abstract
 MUXSDKStatsJWPlayer offers an interface for monitoring video players.

 @discussion
 MUXSDKStatsJWPlayer monitors JWPlayerController performance by sending tracking pings to Mux servers.

 In the simplest use case, a JWPlayerController can be provided to the MUXSDKStatsJWPlayer API and everything else is taken care of for you. The MUXSDKStatsJWPlayer object registers itself as the delegate of the JWPlayerController instance. If you need to receive delegate callbacks, pass in a new delegate object. When you are done with the JWPlayerController instance, call destroyPlayer: to clean up.

 If you change the video that is playing in the JWPlayer, you should call videoChangeForPlayer:videoData: to provide the updated video information. Not calling videoChangeForPlayer:withConfig: when the video changes will cause tracking pings to be associated with the last video that was playing.
 */
@interface MUXSDKStatsJWPlayer : NSObject

/*!
@method      monitorJWPlayerController:name:delegate:playerData:videoData:
@abstract    Starts to monitor a given JWPlayerController
@param       controller The JWPlayerController to monitor
@param       name The name for this instance of the player
@param       delegate The delegate (option) that will receive JWPlayerController callbacks
@param       playerData A MUXSDKCustomerPlayerData object with player metadata
@param       videoData A MUXSDKCustomerVideoData object with video metadata
@discussion  Use this method to start a Mux player monitor on the given JWPlayerController. The player must have a name which is globally unique. The config provided should match the specifications in the Mux docs at https://docs.mux.com
*/
+ (void)monitorJWPlayerController:(JWPlayerController *)controller
                             name:(NSString *)name
                         delegate:(id<JWPlayerDelegate> _Nullable)delegate
                       playerData:(MUXSDKCustomerPlayerData *)playerData
                        videoData:(MUXSDKCustomerVideoData *)videoData;

/*!
 @method      videoChangeForPlayer:videoData:
 @abstract    Signals that a player is now playing a different video.
 @param       name The name of the player to update
 @param       videoData A MUXSDKCustomerVideoData object with video metadata
 @discussion  Use this method to signal that the player is now playing a new video. The player name provided must been passed as the name in a monitorPlayer:withPlayerName:andConfig: call. The config provided should match the specifications in the Mux docs at https://docs.mux.com and should include all desired keys, not just those keys that are specific to this video. If the name of the player provided was not previously initialized, an exception will be raised.

 */
+ (void)videoChangeForPlayerWithName:(NSString *)name videoData:(MUXSDKCustomerVideoData *)videoData;

/*!
 @method      destroyPlayer:
 @abstract    Removes any JWPlayerController observers and delegates on the associated player.
 @param       name The name of the player to destory
 @discussion  When you are done with a player, call destoryPlayer: to remove all observers that were set up when monitorPlayer:withPlayerName:andConfig: was called and to ensure that any remaining tracking pings are sent to complete the view. If the name of the player provided was not previously initialized, an exception will be raised.
 */
+ (void)destroyPlayerWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
