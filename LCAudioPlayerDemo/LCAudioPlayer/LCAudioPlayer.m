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

@end

@implementation LCAudioPlayer

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
#pragma mark - Setter
- (void)setUrl:(NSURL *)url {
    [self stop];
    AVPlayerItem *playerItem =[AVPlayerItem playerItemWithURL:url];
    [self.innerPlayer replaceCurrentItemWithPlayerItem:playerItem];
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
#pragma mark -

#pragma mark -


@end
