//
//  DDAppDelegate.m
//  JSBridgeIOSDemo
//
//  Created by Dominik Pich on 31.07.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import "DDAppDelegate.h"
#import "DDViewController.h"

@interface DDAppDelegate ()
@property (strong, nonatomic) DDViewController *viewController;
@end

@implementation DDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[DDViewController alloc] initWithNibName:nil bundle:nil];
	self.window.rootViewController = self.viewController;
    
	[self.window makeKeyAndVisible];
    return YES;
}

@end
