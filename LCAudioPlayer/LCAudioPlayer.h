//
//  LCAudioPlayer.h
//  Pods-MLCAudioPlayer
//
//  Created by menglingchao on 2020/6/20.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LCAudioPlayerState) {
    LCAudioPlayerStateReady = 0,//
    LCAudioPlayerStateLoading = 1,//
    LCAudioPlayerStateLoadedMetadata = 1,//
    LCAudioPlayerStatePlaying = 2,//
    LCAudioPlayerStatePaused = 3,//
    LCAudioPlayerStateStopped = 4,//
    LCAudioPlayerStateEnded = 5,//
    LCAudioPlayerStateError = 6,//
};

@class LCAudioPlayer;

/***/
@protocol LCAudioPlayerDelegate <NSObject>

@optional
/***/
- (void)audioPlayerDidStart:(LCAudioPlayer *)audioPlayer;
/***/
- (void)audioPlayerLoadedMetadata:(LCAudioPlayer *)audioPlayer;
/***/
- (void)audioPlayerSeeking:(LCAudioPlayer *)audioPlayer;
/***/
- (void)audioPlayerSeeked:(LCAudioPlayer *)audioPlayer finished:(BOOL)finished;
/***/
- (void)audioPlayerDidPaused:(LCAudioPlayer *)audioPlayer;
/***/
- (void)audioPlayerDidStopped:(LCAudioPlayer *)audioPlayer;
/***/
- (void)audioPlayerDidEnd:(LCAudioPlayer *)audioPlayer;
/***/
- (void)audioPlayer:(LCAudioPlayer *)audioPlayer updateCacheTime:(double)cacheTime;
/***/
- (void)audioPlayer:(LCAudioPlayer *)audioPlayer updateCurrentTime:(double)currentTime duration:(double)duration;

@end


@interface LCAudioPlayer : NSObject

/***/
@property (nonatomic, copy) NSURL *url;
/***/
@property (nonatomic) double startPlayTime;
/***/
@property (nonatomic, readonly) LCAudioPlayerState state;
/***/
@property (nonatomic, weak) id<LCAudioPlayerDelegate> delegate;


/***/
- (void)play;
/***/
- (void)pause;
/***/
- (void)stop;

@end

