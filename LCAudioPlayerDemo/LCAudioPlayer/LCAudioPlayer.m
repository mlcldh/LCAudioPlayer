//
//  LCAudioPlayer.m
//  Pods-MLCAudioPlayer
//
//  Created by menglingchao on 2020/6/20.
//

#import "LCAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface LCAudioPlayer ()

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
                _state = LCAudioPlayerStateLoadedMetadata;
                if ([self.delegate respondsToSelector:@selector(audioPlayerLoadedMetadata:)]) {
                    [self.delegate audioPlayerLoadedMetadata:self];
                }
                if (self.startPlayTime > 0) {
                    [self seekToTime:CMTimeMake(self.startPlayTime, 1) completionHandler:^(BOOL finished) {
                        
                    }];
                    self.startPlayTime = 0;
                }
            }
                break;
            case AVPlayerItemStatusFailed: {
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
    if (_url.absoluteString.length) {
        [self stop];
        [self removeObserverOfPlayer:self.innerPlayer];
    }
    AVPlayerItem *playerItem =[AVPlayerItem playerItemWithURL:url];
    [self.innerPlayer replaceCurrentItemWithPlayerItem:playerItem];
    [self addObserverOfPlayer:self.innerPlayer];
}
#pragma mark -
- (void)play {
    [self.innerPlayer play];
}
- (void)pause {
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
}
- (void)seekToTime:(CMTime)time completionHandler:(void (^)(BOOL finished))completionHandler {
    if (self.innerPlayer.status != AVPlayerItemStatusReadyToPlay) {//保护下
        return;
    }
    if ([self.delegate respondsToSelector:@selector(audioPlayerSeeking:)]) {
        [self.delegate audioPlayerSeeking:self];
    }
    __weak __typeof(self) weakSelf = self;
    [self.innerPlayer seekToTime:time completionHandler:^(BOOL finished) {
        if (completionHandler) {
            completionHandler(finished);
        }
        if ([weakSelf.delegate respondsToSelector:@selector(audioPlayerSeeked:finished:)]) {
            [weakSelf.delegate audioPlayerSeeked:self finished:finished];
        }
    }];
}
#pragma mark -
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
    _state = LCAudioPlayerStatePlaying;
    double currentTime = CMTimeGetSeconds(time);
    double duration = CMTimeGetSeconds([player.currentItem duration]);
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
//    NSLog(@"InterruptionNotification info = %@",info);
    AVAudioSessionInterruptionType type = [info[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    
}
#pragma mark - AVAudioSessionRouteChangeNotification
- (void)handleAVAudioSessionRouteChangeNotification:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
//    NSLog(@"RouteChangeNotification info = %@",info);
    AVAudioSessionRouteChangeReason reason = [info[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
}

@end
