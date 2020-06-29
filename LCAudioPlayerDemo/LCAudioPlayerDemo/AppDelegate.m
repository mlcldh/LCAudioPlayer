//
//  AppDelegate.m
//  LCAudioPlayer
//
//  Created by menglingchao on 2020/6/20.
//  Copyright © 2019 MengLingChao. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    ViewController *vc = [ViewController new];
    //    self.window.rootViewController = vc;
    UINavigationController *nc = [[UINavigationController alloc]initWithRootViewController:vc];
    self.window.rootViewController = nc;
    
    [self.window makeKeyAndVisible];
    return YES;
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    __weak typeof (self) weakSelf = self;
    self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
//        NSLog(@"menglc beginBackgroundTaskWithExpirationHandler %@", @(weakSelf.backgroundTaskIdentifier));
        [[UIApplication sharedApplication] endBackgroundTask:weakSelf.backgroundTaskIdentifier];
        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    }];
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
}

@end
