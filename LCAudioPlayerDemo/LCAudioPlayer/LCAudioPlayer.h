//
//  LCAudioPlayer.h
//  Pods-MLCAudioPlayer
//
//  Created by menglingchao on 2020/6/20.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LCAudioPlayerState) {
    LCAudioPlayerStateReady = 0,//
    LCAudioPlayerStateLoadedMetadata = 1,//
    LCAudioPlayerStatePlaying = 2,//
    LCAudioPlayerStatePaused = 3,//
    LCAudioPlayerStateStopped = 4,//
    LCAudioPlayerStateError = 5,//
};

@class LCAudioPlayer;

/***/
@protocol LCAudioPlayerDelegate <NSObject>

/***/
- (void)audioPlayerDidStart:(LCAudioPlayer *)audioPlayer;
/***/
- (void)audioPlayerDidPaused:(LCAudioPlayer *)audioPlayer;
/***/
- (void)audioPlayerDidStopped:(LCAudioPlayer *)audioPlayer;
/***/
- (void)audioPlayerDidEnd:(LCAudioPlayer *)audioPlayer;

@end


@interface LCAudioPlayer : NSObject

/***/
@property (nonatomic, copy) NSURL *url;
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

