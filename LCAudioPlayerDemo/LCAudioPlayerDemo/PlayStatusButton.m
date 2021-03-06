//
//  PlayStatusButton.m
//  LCAudioPlayerDemo
//
//  Created by menglingchao on 2020/6/24.
//  Copyright © 2020 menglingchao. All rights reserved.
//

#import "PlayStatusButton.h"

@interface PlayStatusButton ()

@end

@implementation PlayStatusButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.playState = PlayStatusButtonStatePaused;
    }
    return self;
}
- (void)setPlayState:(PlayStatusButtonState)playState {
    _playState = playState;
    NSArray *imageNames = @[@"lcPlayerPaused", @"lcPlayerLoading", @"lcPlayerPlaying"];
    [self setImage:[UIImage imageNamed:imageNames[playState]] forState:(UIControlStateNormal)];
}

@end
