#import <JWPlayer_iOS_SDK/JWPlayerController.h>
#import "ViewController.h"

@import MuxCore;
@import MUXSDKStatsJWPlayer;

// TODO: Add your license keys
static NSString * MUX_LICENSE_KEY = @"YOUR_MUX_KEY";
static NSString * DEMO_PLAYER_NAME = @"demoplayer";

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    JWAdConfig * ad = [JWAdConfig new];
    ad.tag = @"https://pubads.g.doubleclick.net/gampad/ads?slotname=/124319096/external/ad_rule_samples&sz=640x480&ciu_szs=300x250&cust_params=deployment%3Ddevsite%26sample_ar%3Dpremidpost&url=&unviewed_position_start=1&output=xml_vast3&impl=s&env=vp&gdfp_req=1&ad_rule=0&cue=15000&vad_type=linear&vpos=midroll&pod=2&mridx=1&rmridx=1&ppos=1&lip=true&min_ad_duration=0&max_ad_duration=30000&vrid=6256&video_doc_id=short_onecue&cmsid=496&kfa=0&tfcd=0";

    JWConfig * config = [JWConfig new];
    config.file = @"https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8";
    config.advertising = ad;
    config.autostart = YES;

    self.player = [[JWPlayerController alloc] initWithConfig:config];
    self.player.view.frame = self.view.bounds;
    [self.view addSubview:self.player.view];

    MUXSDKCustomerPlayerData * playerData = [[MUXSDKCustomerPlayerData alloc] initWithPropertyKey:MUX_LICENSE_KEY];
    MUXSDKCustomerVideoData *videoData = [MUXSDKCustomerVideoData new];
    videoData.videoTitle = @"Big Buck Bunny";
    videoData.videoId = @"bigbuckbunny";
    videoData.videoSeries = @"animation";
    [MUXSDKStatsJWPlayer monitorJWPlayerController:self.player
                                              name:DEMO_PLAYER_NAME
                                          delegate:self // delegate can be nil
                                        playerData:playerData
                                         videoData:videoData];

    [self.player play];

    // After 20 seconds, we'll change the video.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        MUXSDKCustomerVideoData * videoData = [MUXSDKCustomerVideoData new];
        videoData.videoTitle = @"Apple Keynote";
        videoData.videoId = @"applekeynote2010";
        [MUXSDKStatsJWPlayer videoChangeForPlayerWithName:DEMO_PLAYER_NAME videoData:videoData];

        JWPlaylistItem * item = [JWPlaylistItem new];
        item.file = @"http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8";

        [self.player load:@[ item ]];
        [self.player play];
    });
}

- (void) onPlay:(JWEvent<JWStateChangeEvent> *)event {
    NSLog(@"Example where I registered for the onPlay delegate in my application's ViewController JWEvent event: %@", event.description);
}

@end
