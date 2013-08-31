//
//  DDViewController.m
//  JSBridgeIOSDemo
//
//  Created by Dominik Pich on 31.07.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import "DDViewController.h"
#import "DDImageFilter.h"

@interface DDViewController () <UIWebViewDelegate>
@property (strong, nonatomic) DDBridgableWebView *webView;
@property (strong, nonatomic) DDImageFilter *imagefilter;
@end

@implementation DDViewController

@synthesize webView=_webView;
- (DDBridgableWebView *)webView {
    if(!_webView) {
        _webView = [[DDBridgableWebView alloc] initWithFrame:self.view.bounds];
        _webView.delegate = self;
        [self.view addSubview:_webView];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //register everybody
    [[DDEnhancedJSBridge defaultBridge] addWebView:self.webView];
    [[DDEnhancedJSBridge defaultBridge] addObject:self.imagefilter forName:@"imagefilter"];
     
    //load test
    NSBundle *libBundle = [NSBundle mainBundle];
    NSURL *webUrl = [libBundle URLForResource:@"pics_and_masks" withExtension:@"html"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:webUrl]];
}

#pragma mark -

//see that the original delegate is still called

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.webView.hidden = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.webView.hidden = NO;
}

@end
