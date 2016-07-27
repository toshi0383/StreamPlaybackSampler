//
//  ViewController.m
//  HLSTest
//
//  Created by toshi0383 on 7/26/16.
//  Copyright © 2016 toshi0383. All rights reserved.
//

#import "ViewController.h"
#import "ResourceLoaderController.h"
@import AVFoundation;

@interface ViewController ()
@property (nonatomic) id<AVAssetResourceLoaderDelegate> resourceLoaderController;
@property (nonatomic) AVPlayerItem *item;
@end

@implementation ViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupPlaybackUsingAVAssetResourceLoader];
//    [self setupPlayback];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Normal Playback
- (void)setupPlayback {
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:@"http://devstreaming.apple.com/videos/wwdc/2016/102w0bsn0ge83qfv7za/102/0640/0640.m3u8"]];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    self.player = [AVPlayer playerWithPlayerItem:item];
    [self.player play];
}

#pragma mark - Use AVAssetResourceLoader
- (void)setupPlaybackUsingAVAssetResourceLoader {
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:@"hello://devstreaming.apple.com/videos/wwdc/2016/102w0bsn0ge83qfv7za/102/0640/0640.m3u8"]];
    AVAssetResourceLoader *loader = asset.resourceLoader;
    _resourceLoaderController = [ResourceLoaderController new];
    dispatch_queue_t queue = dispatch_get_main_queue();
    [loader setDelegate:_resourceLoaderController queue:queue];
    _item = [AVPlayerItem playerItemWithAsset:asset];
    self.player = [AVPlayer playerWithPlayerItem:_item];
    [self.player play];
}

@end
