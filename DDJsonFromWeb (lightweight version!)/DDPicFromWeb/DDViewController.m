//
//  DDViewController.m
//  JSBridgeIOSDemo
//
//  Created by Dominik Pich on 31.07.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import "DDViewController.h"
#import "UIWebView+getBridgedElementByID.h"
#import "NSData+Base64.h"

@interface DDViewController () <UIWebViewDelegate>
@property (strong, nonatomic) UIWebView *webView;
@end

@implementation DDViewController

@synthesize webView=_webView;
- (UIWebView *)webView {
    if(!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _webView.delegate = self;
        [self.view addSubview:_webView];
    }
    return _webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    //load test
    NSBundle *libBundle = [NSBundle mainBundle];
    NSURL *webUrl = [libBundle URLForResource:@"pic" withExtension:@"html"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:webUrl]];
}

#pragma mark -

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.webView.hidden = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.webView.hidden = NO;
    
    NSString *jsonStr = [self.webView getBridgedElementByID:@"pic0"];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    NSString *b64 = json[@"pic0"];
    NSData *data = [NSData dataFromBase64String:b64];
    UIImage *image = [UIImage imageWithData:data];
    
    NSLog(@"%@", NSStringFromCGSize(image.size));
}

@end
