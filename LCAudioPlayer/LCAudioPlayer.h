//
//  LCAudioPlayer.h
//  Pods-MLCAudioPlayer
//
//  Created by menglingchao on 2020/6/20.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

typedef NS_ENUM(NSInteger, LCAudioPlayerState) {
    LCAudioPlayerStateReady = 0,//
    LCAudioPlayerStateLoading = 1,//
    LCAudioPlayerStatePlaying = 2,//
    LCAudioPlayerStatePaused = 3,//
    LCAudioPlayerStateStopped = 4,//
    LCAudioPlayerStateEnded = 5,//
    LCAudioPlayerStateError = 6,//
};

@class LCAudioPlayer;

/**代理协议*/
@protocol LCAudioPlayerDelegate <NSObject>

@optional
/**加载*/
- (void)audioPlayerLoading:(LCAudioPlayer *)audioPlayer;
/**播放开始*/
- (void)audioPlayerDidStart:(LCAudioPlayer *)audioPlayer;
/**能够播放*/
- (void)audioPlayerCanPlay:(LCAudioPlayer *)audioPlayer;
/**被暂停*/
- (void)audioPlayerDidPaused:(LCAudioPlayer *)audioPlayer;
/**被停止*/
- (void)audioPlayerDidStopped:(LCAudioPlayer *)audioPlayer;
/**播放完毕*/
- (void)audioPlayerDidEnd:(LCAudioPlayer *)audioPlayer;
/**报错*/
- (void)audioPlayer:(LCAudioPlayer *)audioPlayer playError:(NSError *)error;
/**seek开始*/
- (void)audioPlayer:(LCAudioPlayer *)audioPlayer seekingWithSeekTime:(double)seekTime;
/**seek结束*/
- (void)audioPlayer:(LCAudioPlayer *)audioPlayer seekedWithSeekTime:(double)seekTime finished:(BOOL)finished;
/**缓存加载*/
- (void)audioPlayer:(LCAudioPlayer *)audioPlayer updateCacheTime:(double)cacheTime;
/**播放进度*/
- (void)audioPlayer:(LCAudioPlayer *)audioPlayer updateCurrentTime:(double)currentTime duration:(double)duration;

@end

/**音频播放器*/
@interface LCAudioPlayer : NSObject

/**播放地址*/
@property (nonatomic, copy) NSURL *url;
/**开始播放位置*/
@property (nonatomic) double startPlayTime;
/**
 倍速
 @param rate 大于0才有效
 */
@property (nonatomic) double rate;
/**音量*/
@property (nonatomic) double volume;
/**当前播放位置*/
@property (nonatomic, readonly) double currentTime;
/**音频总时长*/
@property (nonatomic, readonly) double duration;
/**是否已经加载了元数据*/
@property (nonatomic, readonly) BOOL loadedMetadata;
/**状态*/
@property (nonatomic, readonly) LCAudioPlayerState state;
/**代理*/
@property (nonatomic, weak) id<LCAudioPlayerDelegate> delegate;

/**播放*/
- (void)play;
/**暂停*/
- (void)pause;
/**停止*/
- (void)stop;
/***/
- (void)seekToTime:(CMTime)time completionHandler:(void (^)(BOOL finished))completionHandler;

@end

