//
//  DDAppDelegate.m
//  OSXDemo
//
//  Created by Dominik Pich on 17.08.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import "DDAppDelegate.h"
#import "DDImageFilter.h"

@interface DDAppDelegate ()
@property (strong, nonatomic) DDBridgableWebView *webView;
@property (strong, nonatomic) DDImageFilter *imagefilter;
@end

@implementation DDAppDelegate

@synthesize webView=_webView;
- (DDBridgableWebView *)webView {
    if(!_webView) {
        _webView = [[DDBridgableWebView alloc] initWithFrame:[self.window.contentView bounds]];
//        _webView.delegate = self;
        [self.window.contentView addSubview:_webView];
    }
    return _webView;
}

@synthesize imagefilter=_imagefilter;
- (DDImageFilter*)imagefilter {
    if(!_imagefilter) {
        _imagefilter = [[DDImageFilter alloc] init];
    }
    return _imagefilter;
}

#pragma mark - 

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.window = [[NSWindow alloc] initWithContentRect:NSInsetRect([[NSScreen mainScreen] visibleFrame], 50, 50)
                                              styleMask:NSTitledWindowMask|NSClosableWindowMask
                                                  backing:NSBackingStoreBuffered
                                                    defer:NO];

    //register everybody
    [[DDEnhancedJSBridge defaultBridge] addWebView:self.webView];
    [[DDEnhancedJSBridge defaultBridge] addObject:self.imagefilter forName:@"imagefilter"];
    
    //load test
    NSBundle *libBundle = [NSBundle mainBundle];
    NSURL *webUrl = [libBundle URLForResource:@"pics_and_masks" withExtension:@"html"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:webUrl]];
    
    [self.window makeKeyAndOrderFront:nil];
}

@end
