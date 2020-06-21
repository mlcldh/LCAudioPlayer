//
//  ViewController.m
//  LCAudioPlayer
//
//  Created by menglingchao on 2020/6/20.
//  Copyright © 2020 menglingchao. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "MLCMacror.h"
#import "UIControl+MLCKit.h"
#import "LCAudioPlayer.h"

@interface ViewController ()<LCAudioPlayerDelegate>

@property (nonatomic, strong) LCAudioPlayer *audioPlayer;//

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
#pragma mark -
- (void)useAudioPlayer {
    self.audioPlayer = [[LCAudioPlayer alloc]init];
    self.audioPlayer.url = [NSURL URLWithString:@""];
    self.audioPlayer.delegate = self;
    [self.audioPlayer play];
}
#pragma mark -LCAudioPlayerDelegate


@end
