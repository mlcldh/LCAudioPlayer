//
//  PlayStatusButton.h
//  LCAudioPlayerDemo
//
//  Created by menglingchao on 2020/6/24.
//  Copyright © 2020 menglingchao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PlayStatusButtonState) {
    PlayStatusButtonStatePaused = 0,//
    PlayStatusButtonStateLoading = 1,//
    PlayStatusButtonStatePlaying = 2,//
};

/***/
@interface PlayStatusButton : UIButton

/***/
@property (nonatomic) PlayStatusButtonState playState;

@end
