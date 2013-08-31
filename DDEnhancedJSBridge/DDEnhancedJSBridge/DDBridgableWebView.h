//
//  DDBridgableWebView.h
//  DDEnhancedJSBridge
//
//  Created by Dominik Pich on 31.07.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#define DDWebView UIWebView
#else
#import <WebKit/WebKit.h>
#define DDWebView WebView
#endif

@protocol DDEnhancedJSBridge;

@protocol DDBridgableWebView <NSObject>
@property(weak) id<DDEnhancedJSBridge> DDEnhancedJSBridge;
- (NSDictionary*)dictionaryForJSONID:(NSInteger)JSONID;
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;
- (void)loadRequest:(NSURLRequest *)request; //added for compatib between ios and osx
@end

///one possible implementation
@interface DDBridgableWebView : DDWebView<DDBridgableWebView>
@end
