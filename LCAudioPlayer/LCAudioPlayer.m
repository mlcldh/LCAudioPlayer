//
//  LCAudioPlayer.m
//  Pods-MLCAudioPlayer
//
//  Created by menglingchao on 2020/6/20.
//

#import "LCAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, LCAudioPlayerPurpose) {
    LCAudioPlayerPurposePause = 0,//
    LCAudioPlayerPurposePlay = 1,//
};

@interface LCAudioPlayer ()

@property (nonatomic) LCAudioPlayerPurpose purpose;//
@property (nonatomic, copy) NSURL *playUrl;//
@property (nonatomic, strong) AVPlayer *innerPlayer;//
@property (nonatomic, strong) NSObject *periodicTimeObserver;//

@end

@implementation LCAudioPlayer

- (void)dealloc {
    [self removeObserverOfPlayer:self.innerPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.innerPlayer = [[AVPlayer alloc]init];
        self.rate = 1;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAVAudioSessionInterruptionNotification:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAVAudioSessionRouteChangeNotification:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
    }
    return self;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        AVPlayerItem *playerItem = object;
        //        NSLog(@"menglc KVO playerItem = %@",playerItem);
    } else if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItem *playerItem = object;
        //        NSLog(@"menglc AVPlayerItem status%@,%@",@(playerItem.status),playerItem.error);
        switch (playerItem.status) {
            case AVPlayerItemStatusReadyToPlay: {
                BOOL shouldSeek = NO;
                if (!self.loadedMetadata) {
                    _loadedMetadata = YES;
                    if ([self.delegate respondsToSelector:@selector(audioPlayerDidStart:)]) {
                        [self.delegate audioPlayerDidStart:self];
                    }
                    shouldSeek = YES;
                }
                if (_loadedMetadata) {
                    if ([self.delegate respondsToSelector:@selector(audioPlayerCanPlay:)]) {
                        [self.delegate audioPlayerCanPlay:self];
                    }
                }
                if (shouldSeek && (self.startPlayTime > 0)) {
                    [self seekToTime:CMTimeMake(self.startPlayTime, 1) completionHandler:^(BOOL finished) {
                    }];
                }
            }
                break;
            case AVPlayerItemStatusFailed: {
                if ([self.delegate respondsToSelector:@selector(audioPlayer:playError:)]) {
                    [self.delegate audioPlayer:self playError:self.innerPlayer.error];
                }
                [self removeObserverOfPlayer:self.innerPlayer];
                [self.innerPlayer pause];
                
                AVAsset *asset = [AVAsset assetWithURL:self.url];
                AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset automaticallyLoadedAssetKeys:@[@"duration",@"playable"]];
                AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];//
                self.innerPlayer = player;
                float total = CMTimeGetSeconds([playerItem duration]);
                
                [self addObserverOfPlayer:player];
            }
                break;
            default:
                break;
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        AVPlayerItem *playerItem = object;
        CMTimeRange timeRange = [playerItem.loadedTimeRanges.firstObject CMTimeRangeValue]; //本次缓冲的时间范围
        double totalBuffer = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration); //缓冲总长度
        if ([self.delegate respondsToSelector:@selector(audioPlayer:updateCacheTime:)]) {
            [self.delegate audioPlayer:self updateCacheTime:totalBuffer];
        }
    }
}
#pragma mark - Setter
- (void)setUrl:(NSURL *)url {
    if (self.playUrl) {
        [self stop];
    }
    _url = url.copy;
    _duration = 0;
}
- (double)volume {
    return self.innerPlayer.volume;
}
- (void)setRate:(double)rate {
    if (rate <= 0) {
        return;
    }
    _rate = rate;
}
- (void)setVolume:(double)volume {
    self.innerPlayer.volume = volume;
}
#pragma mark -
- (void)play {
    [self ensureAudioSessionActive];
    self.purpose = LCAudioPlayerPurposePlay;
    if (self.url && ![self.url isEqual:self.playUrl]) {
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:self.url];
        [self.innerPlayer replaceCurrentItemWithPlayerItem:playerItem];
        [self addObserverOfPlayer:self.innerPlayer];
        self.playUrl = self.url;
    }
    if (self.url) {
        self.innerPlayer.rate = self.rate;
        _state = LCAudioPlayerStateLoading;
        if ([self.delegate respondsToSelector:@selector(audioPlayerLoading:)]) {
            [self.delegate audioPlayerLoading:self];
        }
    }
}
- (void)pause {
    [self pause:YES];
}
- (void)pause:(BOOL)isPurpose {
    if (isPurpose) {
        self.purpose = LCAudioPlayerPurposePause;
    }
    [self.innerPlayer pause];
    _state = LCAudioPlayerStatePaused;
    if ([self.delegate respondsToSelector:@selector(audioPlayerDidPaused:)]) {
        [self.delegate audioPlayerDidPaused:self];
    }
}
- (void)stop {
    [self.innerPlayer pause];
    _state = LCAudioPlayerStateStopped;
    if ([self.delegate respondsToSelector:@selector(audioPlayerDidStopped:)]) {
        [self.delegate audioPlayerDidStopped:self];
    }
    [self removeObserverOfPlayer:self.innerPlayer];
    [self.innerPlayer replaceCurrentItemWithPlayerItem:nil];
//    [self addObserverOfPlayer:self.innerPlayer];
    _loadedMetadata = NO;
    _startPlayTime = 0;
    self.playUrl = nil;
}
- (void)seekToTime:(CMTime)time completionHandler:(void (^)(BOOL finished))completionHandler {
    if (self.innerPlayer.status != AVPlayerItemStatusReadyToPlay) {//保护下
        return;
    }
    if ([self.delegate respondsToSelector:@selector(audioPlayer:seekingWithSeekTime:)]) {
        [self.delegate audioPlayer:self seekingWithSeekTime:CMTimeGetSeconds(time)];
    }
    __weak __typeof(self) weakSelf = self;
    [self.innerPlayer seekToTime:time completionHandler:^(BOOL finished) {
        if (completionHandler) {
            completionHandler(finished);
        }
        if ([weakSelf.delegate respondsToSelector:@selector(audioPlayer:seekedWithSeekTime:finished:)]) {
            [weakSelf.delegate audioPlayer:self seekedWithSeekTime:CMTimeGetSeconds(time) finished:finished];
        }
    }];
}
#pragma mark -
- (void)ensureAudioSessionActive {
    AVAudioSessionCategoryOptions options = 0;
    if((options == AVAudioSession.sharedInstance.categoryOptions) && (AVAudioSessionCategoryPlayback == AVAudioSession.sharedInstance.category)){
        
    }
    else{
        NSError *setCategoryErr = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:options error:&setCategoryErr];
        if (setCategoryErr) {
            
        }
    }
    if (@available(iOS 9.0, *)) {
        if (AVAudioSessionModeSpokenAudio != AVAudioSession.sharedInstance.mode) {
            [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeSpokenAudio error:nil];
        }
    } else {
        if (AVAudioSessionModeDefault != AVAudioSession.sharedInstance.mode) {
            [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeDefault error:nil];
        }
    }
    
    NSError *activationErr  = nil;
//    [[AVAudioSession sharedInstance] setActive:YES error:&activationErr];
    [[AVAudioSession sharedInstance] setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&activationErr];
    
}
- (void)addObserverOfPlayer:(AVPlayer *)player {
    __weak typeof(self) weakSelf = self;
    __weak AVPlayer *weakPlayer = player;
    self.periodicTimeObserver = [player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        [weakSelf handleCurrentTime:time ofPlayer:weakPlayer];
    }];
    [player.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleAVPlayerItemDidPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem];
}
- (void)removeObserverOfPlayer:(AVPlayer *)player {
    if (_periodicTimeObserver) {
        [player removeTimeObserver:self.periodicTimeObserver];
        [player.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [player.currentItem removeObserver:self forKeyPath:@"status"];
        [player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    _periodicTimeObserver = nil;
}
- (void)handleCurrentTime:(CMTime)time ofPlayer:(AVPlayer *)player{
    //    NSLog(@"menglc self.fmPlayer.rate = %@",@(self.fmPlayer.rate));
    //    NSLog(@"menglc AVAudioSession category 2 = %@",[AVAudioSession sharedInstance].category);
    if (_state != LCAudioPlayerStatePaused) {
        _state = LCAudioPlayerStatePlaying;
    }
    
    double currentTime = CMTimeGetSeconds(time);
    double duration = CMTimeGetSeconds([player.currentItem duration]);
    _currentTime = currentTime;
    _duration = duration;
    if ([self.delegate respondsToSelector:@selector(audioPlayer:updateCurrentTime:duration:)]) {
        [self.delegate audioPlayer:self updateCurrentTime:currentTime duration:duration];
    }
}
#pragma mark - AVPlayerItemDidPlayToEndTimeNotification
- (void)handleAVPlayerItemDidPlayToEndTimeNotification:(NSNotification *)notification {
    if (notification.object != self.innerPlayer.currentItem) {//只处理当前currentItem播放完毕的通知
        return;
    }
    _state = LCAudioPlayerStateEnded;
    if ([self.delegate respondsToSelector:@selector(audioPlayerDidEnd:)]) {
        [self.delegate audioPlayerDidEnd:self];
    }
}
#pragma mark - AVAudioSessionInterruptionNotification
- (void)handleAVAudioSessionInterruptionNotification:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
//    NSLog(@"menglc AVAudioSessionInterruptionNotification %@",info);
    AVAudioSessionInterruptionType interruptionType = [info[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    BOOL wasSuspended = NO;
    if (@available(iOS 10.3, *)) {
        wasSuspended = [info[AVAudioSessionInterruptionWasSuspendedKey] boolValue];
    }
    AVAudioSessionInterruptionOptions interruptionOptions = [info[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
    BOOL isPlaying = (self.state == LCAudioPlayerStatePlaying) || (self.state == LCAudioPlayerStateLoading);
    NSLog(@"menglc handleAVAudioSessionInterruptionNotification %@, %@", info, @(isPlaying));
    if (interruptionType == AVAudioSessionInterruptionTypeBegan && isPlaying && !wasSuspended) {
        NSLog(@"menglc handleAVAudioSessionInterruptionNotification pause");
        [self pause:NO];
    } else if ((interruptionType == AVAudioSessionInterruptionTypeEnded) && (self.purpose == LCAudioPlayerPurposePlay)) {
        NSLog(@"menglc handleAVAudioSessionInterruptionNotification want play");
        NSError *error = nil;
//        if (interruptionOptions == AVAudioSessionInterruptionOptionShouldResume) {
//            [self.innerPlayer play];
//        }
        if([[AVAudioSession sharedInstance] setActive:YES error:&error]){
            NSLog(@"menglc handleAVAudioSessionInterruptionNotification play");
            [self play];
        }
    }
}
#pragma mark - AVAudioSessionRouteChangeNotification
- (void)handleAVAudioSessionRouteChangeNotification:(NSNotification *)notification {
    BOOL isPlaying = (self.state == LCAudioPlayerStatePlaying) || (self.state == LCAudioPlayerStateLoading);
    NSDictionary *info = notification.userInfo;
    NSLog(@"menglc AVAudioSessionRouteChangeNotification %@",info);
    AVAudioSessionRouteChangeReason reason = [info[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
    if ((reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) && isPlaying) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self pause:NO];
        });
    } else if ((reason == AVAudioSessionRouteChangeReasonNewDeviceAvailable) && (self.purpose == LCAudioPlayerPurposePlay)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self play];
        });
    }
}

@end
