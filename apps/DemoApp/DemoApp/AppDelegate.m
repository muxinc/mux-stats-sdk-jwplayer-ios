#import "AppDelegate.h"

@implementation AppDelegate

static NSString * JWPLAYER_LICENSE_KEY = @"";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if ([JWPLAYER_LICENSE_KEY  isEqual: @""]) {
        NSException* missingJwLicenseKey = [NSException
                                            exceptionWithName:@"Missing JW License Key"
                                            reason:@"Expected a value for JWPLAYER_LICENSE_KEY"
                                            userInfo:nil];
        @throw missingJwLicenseKey;
    }
    [JWPlayerController setPlayerKey:JWPLAYER_LICENSE_KEY];
    return YES;
}

@end
