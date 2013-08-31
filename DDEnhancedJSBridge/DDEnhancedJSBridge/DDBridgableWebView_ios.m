#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
//
//  DDBridgableWebView.m
//  DDEnhancedJSBridge
//
//  Created by Dominik Pich on 31.07.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import "DDBridgableWebView.h"
#import "DDEnhancedJSBridge.h"

@interface DDBridgableWebView () <UIWebViewDelegate>
@end

@implementation DDBridgableWebView {
    __weak id<UIWebViewDelegate> _originalDelegate;
}

- (void)setDelegate:(id<UIWebViewDelegate>)delegate {
    _originalDelegate = delegate;
    super.delegate = self;
}

- (id<UIWebViewDelegate>)delegate {
    return _originalDelegate;
}

- (void)loadRequest:(NSURLRequest *)request {
    super.delegate = self;
    [super loadRequest:request];
}

#pragma mark - 

@synthesize DDEnhancedJSBridge=_bridge;

- (NSDictionary*)dictionaryForJSONID:(NSInteger)JSONID {
    NSString* jsonStr = [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"DDBridge_getJsonStringForObjectWithId(%d)", JSONID]];
    
    NSError *error = nil;
    NSDictionary* jsonDic = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    NSAssert(jsonDic, [error description]);

    return jsonDic;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if(_bridge) {
        if([_bridge canBridgeFromWebView:self toNativeIdentifiedByURL:request.URL]) {
            //async so we dont block too long
            dispatch_async(dispatch_get_main_queue(), ^{
                [_bridge bridgeFromWebView:self toNativeIdentifiedByURL:request.URL];
            });
            return NO;
        }
    }
    
    if([_originalDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [_originalDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if([_originalDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [_originalDelegate webViewDidStartLoad:webView];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if([_originalDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [_originalDelegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if([_originalDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [_originalDelegate webView:webView didFailLoadWithError:error];
    }
}

@end
#endif