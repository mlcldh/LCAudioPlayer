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
#import "PlayStatusButton.h"

@interface ViewController ()<LCAudioPlayerDelegate>

@property (nonatomic, strong) LCAudioPlayer *audioPlayer;//
@property (nonatomic, strong) UIButton *playButton;//
@property (nonatomic, strong) UIButton *setStartPlayTimeButton;//
@property (nonatomic, strong) UIButton *pauseButton;//
@property (nonatomic, strong) UIButton *stopButton;//
@property (nonatomic, strong) UIButton *rateButton;//
@property (nonatomic, strong) UIButton *playNextButton;//
@property (nonatomic, strong) UIButton *seekButton;//
@property (nonatomic, strong) PlayStatusButton *playStatusButton;//

@property (nonatomic, strong) UISlider *cacheSlider;//
@property (nonatomic, strong) UISlider *progressSlider;//
@property (nonatomic, strong) UISlider *volumeSlider;//

@property (nonatomic, copy) NSArray *urlStrings;//
@property (nonatomic) NSInteger currentIndex;//

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    
    _urlStrings = @[@"http://audio.xmcdn.com/group26/M01/21/11/wKgJWFjKZo3BxPm-ADxcnyEQeBg883.m4a",
                    @"http://audio.cos.xmcdn.com/group67/M02/20/0E/wKgMd13JCRuA9o-oAC_10WSNKAM973.m4a",
                    @"http://aod.cos.tx.xmcdn.com/group68/M06/1F/0E/wKgMbl3JC2eCtnp7ACv5QyhwI4s816.m4a",
                    @"http://aod.cos.tx.xmcdn.com/group67/M08/3B/91/wKgMd13Kj3qy-ZDnAEWKES4uq0U690.m4a",];
    
    [self creatAudioPlayer];
    [self useVolume];
    
    [self playButton];
    [self setStartPlayTimeButton];
    [self pauseButton];
    [self stopButton];
    [self rateButton];
    [self playNextButton];
    [self seekButton];
    
    [self playStatusButton];
    
    [self cacheSlider];
    [self progressSlider];
    [self volumeSlider];
}
#pragma mark - Getter
- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
        _playButton.backgroundColor = [UIColor purpleColor];
        [_playButton setTitle:@"play" forState:(UIControlStateNormal)];
        @weakify(self)
        [_playButton mlc_addActionForControlEvents:(UIControlEventTouchUpInside) callback:^(id sender) {
            @strongify(self)
            [self.audioPlayer play];
        }];
        [self.view addSubview:_playButton];
        [_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(20);
            make.top.equalTo(self.view).offset(20);
        }];
    }
    return _playButton;
}
- (UIButton *)setStartPlayTimeButton {
    if (!_setStartPlayTimeButton) {
        _setStartPlayTimeButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
        _setStartPlayTimeButton.backgroundColor = [UIColor purpleColor];
        [_setStartPlayTimeButton setTitle:@"setStartPlayTime" forState:(UIControlStateNormal)];
//        @weakify(self)
        [_setStartPlayTimeButton mlc_addActionForControlEvents:(UIControlEventTouchUpInside) callback:^(id sender) {
//            @strongify(self)
            self.audioPlayer.startPlayTime = 200;
        }];
        [self.view addSubview:_setStartPlayTimeButton];
        [_setStartPlayTimeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.playButton.mas_right).offset(20);
            make.top.equalTo(self.playButton);
        }];
    }
    return _setStartPlayTimeButton;
}
- (UIButton *)pauseButton {
    if (!_pauseButton) {
        _pauseButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
        _pauseButton.backgroundColor = [UIColor purpleColor];
        [_pauseButton setTitle:@"pause" forState:(UIControlStateNormal)];
        @weakify(self)
        [_pauseButton mlc_addActionForControlEvents:(UIControlEventTouchUpInside) callback:^(id sender) {
            @strongify(self)
            [self.audioPlayer pause];
        }];
        [self.view addSubview:_pauseButton];
        [_pauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.setStartPlayTimeButton.mas_right).offset(20);
            make.top.equalTo(self.playButton);
        }];
    }
    return _pauseButton;
}
- (UIButton *)stopButton {
    if (!_stopButton) {
        _stopButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
        _stopButton.backgroundColor = [UIColor purpleColor];
        [_stopButton setTitle:@"stop" forState:(UIControlStateNormal)];
        @weakify(self)
        [_stopButton mlc_addActionForControlEvents:(UIControlEventTouchUpInside) callback:^(id sender) {
            @strongify(self)
            [self.audioPlayer stop];
            NSLog(@"menglc after stop");
            self.cacheSlider.value = 0;
            self.progressSlider.value = 0;
        }];
        [self.view addSubview:_stopButton];
        [_stopButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.pauseButton.mas_right).offset(20);
            make.top.equalTo(self.pauseButton);
        }];
    }
    return _stopButton;
}
- (UIButton *)rateButton {
    if (!_rateButton) {
        _rateButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
        _rateButton.backgroundColor = [UIColor purpleColor];
        [_rateButton setTitle:@"倍速" forState:(UIControlStateNormal)];
        @weakify(self)
        [_rateButton mlc_addActionForControlEvents:(UIControlEventTouchUpInside) callback:^(id sender) {
            @strongify(self)
            self.audioPlayer.rate = 2;
        }];
        [self.view addSubview:_rateButton];
        [_rateButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.stopButton.mas_right).offset(20);
            make.top.equalTo(self.stopButton);
        }];
    }
    return _rateButton;
}
- (UIButton *)playNextButton {
    if (!_playNextButton) {
        _playNextButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
        _playNextButton.backgroundColor = [UIColor purpleColor];
        [_playNextButton setTitle:@"next" forState:(UIControlStateNormal)];
        @weakify(self)
        [_playNextButton mlc_addActionForControlEvents:(UIControlEventTouchUpInside) callback:^(id sender) {
            @strongify(self)
            self.currentIndex ++;
            if (self.currentIndex >= self.urlStrings.count) {
                self.currentIndex = 0;
            }
            NSURL *url = [NSURL URLWithString:self.urlStrings[self.currentIndex]];
            self.audioPlayer.url = url;
            [self.audioPlayer play];
        }];
        [self.view addSubview:_playNextButton];
        [_playNextButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(20);
            make.top.equalTo(self.playButton.mas_bottom).offset(20);
        }];
    }
    return _playNextButton;
}
- (UIButton *)seekButton {
    if (!_seekButton) {
        _seekButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
        _seekButton.backgroundColor = [UIColor purpleColor];
        [_seekButton setTitle:@"seek" forState:(UIControlStateNormal)];
        @weakify(self)
        [_seekButton mlc_addActionForControlEvents:(UIControlEventTouchUpInside) callback:^(id sender) {
            @strongify(self)
            NSLog(@"menglc before seek");
            [self.audioPlayer seekToTime:CMTimeMake(100, 1) completionHandler:^(BOOL finished) {
            }];
            [self.audioPlayer seekToTime:CMTimeMake(50, 1) completionHandler:^(BOOL finished) {
            }];
            NSLog(@"menglc after seek");
        }];
        [self.view addSubview:_seekButton];
        [_seekButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.playNextButton.mas_right).offset(20);
            make.top.equalTo(self.playNextButton);
        }];
    }
    return _seekButton;
}
- (PlayStatusButton *)playStatusButton {
    if (!_playStatusButton) {
        CGFloat width = 64;
        _playStatusButton = [[PlayStatusButton alloc]init];
        _playStatusButton.clipsToBounds = YES;
        _playStatusButton.layer.cornerRadius = width / 2;
        _playStatusButton.backgroundColor = [UIColor colorWithRed:0 green:132 / 255.0 blue:1 alpha:1];
        @weakify(self)
        [_playStatusButton mlc_addActionForControlEvents:(UIControlEventTouchUpInside) callback:^(id sender) {
            @strongify(self)
            PlayStatusButton *playStatusButton = sender;
            switch (playStatusButton.playState) {
                case PlayStatusButtonStateLoading:
                    break;
                case PlayStatusButtonStatePlaying: {
                    [self.audioPlayer pause];
                }
                    break;
                case PlayStatusButtonStatePaused: {
                    self.playStatusButton.playState = PlayStatusButtonStatePlaying;
                    [self.audioPlayer play];
                }
                    break;
                default:
                    break;
            }
        }];
        [self.view addSubview:_playStatusButton];
        [_playStatusButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.playNextButton.mas_bottom).offset(20);
            make.width.height.mas_equalTo(width);
        }];
    }
    return _playStatusButton;
}
- (UISlider *)cacheSlider {
    if (!_cacheSlider) {
        UILabel *label = [[UILabel alloc]init];
        label.text = @"缓存";
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(20);
            make.top.equalTo(self.playStatusButton.mas_bottom).offset(20);
        }];
        
        _cacheSlider = [[UISlider alloc]init];
        _cacheSlider.userInteractionEnabled = NO;
        [self.view addSubview:_cacheSlider];
        [_cacheSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(label.mas_right).offset(20);
            make.right.equalTo(self.view).offset(-20);
            make.centerY.equalTo(label);
        }];
    }
    return _cacheSlider;
}
- (UISlider *)progressSlider {
    if (!_progressSlider) {
        UILabel *label = [[UILabel alloc]init];
        label.text = @"进度";
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(20);
            make.top.equalTo(self.cacheSlider.mas_bottom).offset(40);
        }];
        
        _progressSlider = [[UISlider alloc]init];
//        @weakify(self)
        [_progressSlider mlc_addActionForControlEvents:(UIControlEventValueChanged) callback:^(id sender) {
//            @strongify(self)
            UISlider *slider = sender;
//            NSLog(@"menglc self.player.duration %@", @(self.player.duration));
//            NSLog(@"menglc slider.value %@", @(slider.value));
            [self.audioPlayer seekToTime:CMTimeMake(self.audioPlayer.duration *slider.value, 1) completionHandler:^(BOOL finished) {
            }];
        }];
        [self.view addSubview:_progressSlider];
        [_progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(label.mas_right).offset(20);
            make.right.equalTo(self.view).offset(-20);
            make.centerY.equalTo(label);
        }];
    }
    return _progressSlider;
}
- (UISlider *)volumeSlider {
    if (!_volumeSlider) {
        UILabel *label = [[UILabel alloc]init];
        label.text = @"音量";
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(20);
            make.top.equalTo(self.progressSlider.mas_bottom).offset(40);
        }];
        
        _volumeSlider = [[UISlider alloc]init];
        _volumeSlider.value = 1;
        @weakify(self)
        [_volumeSlider mlc_addActionForControlEvents:(UIControlEventValueChanged) callback:^(id sender) {
            @strongify(self)
            UISlider *slider = sender;
            self.audioPlayer.volume = slider.value;
        }];
        [self.view addSubview:_volumeSlider];
        [_volumeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(label.mas_right).offset(20);
            make.right.equalTo(self.view).offset(-20);
            make.centerY.equalTo(label);
        }];
    }
    return _volumeSlider;
}
#pragma mark -
- (void)creatAudioPlayer {
    self.audioPlayer = [[LCAudioPlayer alloc]init];
    self.audioPlayer.url = [NSURL URLWithString:_urlStrings.firstObject];
    self.audioPlayer.delegate = self;
}
- (void)useVolume {
    NSLog(@"menglc useVolume0 %@", @(self.audioPlayer.volume));
//    self.audioPlayer.volume = 20;
    NSLog(@"menglc useVolume1 %@", @(self.audioPlayer.volume));
}
#pragma mark -LCAudioPlayerDelegate
- (void)audioPlayerLoading:(LCAudioPlayer *)audioPlayer {
    
}
- (void)audioPlayerDidStart:(LCAudioPlayer *)audioPlayer {
    NSLog(@"menglc audioPlayerDidStart");
}
- (void)audioPlayerCanPlay:(LCAudioPlayer *)audioPlayer {
    NSLog(@"menglc audioPlayerCanPlay");
}
- (void)audioPlayerDidPaused:(LCAudioPlayer *)audioPlayer {
    NSLog(@"menglc audioPlayerDidPaused");
    self.playStatusButton.playState = PlayStatusButtonStatePaused;
}
- (void)audioPlayerDidStopped:(LCAudioPlayer *)audioPlayer {
    NSLog(@"menglc audioPlayerDidStopped");
}
- (void)audioPlayerDidEnd:(LCAudioPlayer *)audioPlayer {
    NSLog(@"menglc audioPlayerDidEnd");
}
- (void)audioPlayer:(LCAudioPlayer *)audioPlayer playError:(NSError *)error {
    NSLog(@"menglc playError %@", error);
}
- (void)audioPlayer:(LCAudioPlayer *)audioPlayer seekingWithSeekTime:(double)seekTime {
    NSLog(@"menglc seekingWithSeekTime %@", @(seekTime));
}
- (void)audioPlayer:(LCAudioPlayer *)audioPlayer seekedWithSeekTime:(double)seekTime finished:(BOOL)finished {
    NSLog(@"menglc seekedWithSeekTime %@", @(seekTime));
}
- (void)audioPlayer:(LCAudioPlayer *)audioPlayer updateCacheTime:(double)cacheTime {
    NSLog(@"menglc updateCacheTime %@", @(cacheTime));
    if (self.audioPlayer.duration > 0) {
        self.cacheSlider.value = cacheTime / self.audioPlayer.duration;
    }
}
- (void)audioPlayer:(LCAudioPlayer *)audioPlayer updateCurrentTime:(double)currentTime duration:(double)duration {
    NSLog(@"menglc updateCurrentTime %@,%@", @(currentTime), @(duration));
    self.progressSlider.value = currentTime / duration;
}

@end
