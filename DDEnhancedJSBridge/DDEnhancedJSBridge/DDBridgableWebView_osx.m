#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
//
//  DDBridgableWebView.m
//  DDEnhancedJSBridge
//
//  Created by Dominik Pich on 31.07.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import "DDBridgableWebView.h"
#import "DDEnhancedJSBridge.h"

@implementation DDBridgableWebView {
    id _originalDelegate;
}

- (void)setFrameLoadDelegate:(id)delegate {
    _originalDelegate = delegate;
    super.frameLoadDelegate = self;
}

- (id)frameLoadDelegate {
    return _originalDelegate;
}

- (void)loadRequest:(NSURLRequest *)request {
    super.frameLoadDelegate = self;
    [self.mainFrame loadRequest:request];
}

#pragma mark -

@synthesize DDEnhancedJSBridge=_bridge;

- (NSDictionary*)dictionaryForJSONID:(NSInteger)JSONID {
    NSString* jsonStr = [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"DDBridge_getJsonStringForObjectWithId(%ld)", JSONID]];
    
    NSError *error = nil;
    NSDictionary* jsonDic = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    NSAssert(jsonDic, [error description]);

    return jsonDic;
}

#pragma mark - expose to JS

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector {
    return (selector == @selector(bridgeUrl:)) ? NO : YES;
}

+ (BOOL)isKeyExcludedFromWebScript:(const char *)property {
    return YES;
}

+ (NSString *)webScriptNameForSelector:(SEL)sel {
    return (sel == @selector(bridgeUrl:)) ? @"bridgeUrl" : nil;
}

//exposed!
- (void)bridgeUrl:(NSString*)urlString {
    NSParameterAssert(urlString);
    
    //bridge
    if(_bridge) {
        NSURL *url = [NSURL URLWithString:urlString];
        if([_bridge canBridgeFromWebView:self toNativeIdentifiedByURL:url]) {
            //async so we dont block too long
            dispatch_async(dispatch_get_main_queue(), ^{
                [_bridge bridgeFromWebView:self toNativeIdentifiedByURL:url];
            });
        }
    }
}

#pragma mark - FrameLoadDelegate

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame {
    if([_originalDelegate respondsToSelector:@selector(webView:didStartProvisionalLoadForFrame:)]) {
        [_originalDelegate webView:sender didStartProvisionalLoadForFrame:frame];
    }
}

- (void)webView:(WebView *)sender didReceiveServerRedirectForProvisionalLoadForFrame:(WebFrame *)frame {
    if([_originalDelegate respondsToSelector:@selector(webView:didReceiveServerRedirectForProvisionalLoadForFrame:)]) {
        [_originalDelegate webView:sender didReceiveServerRedirectForProvisionalLoadForFrame:frame];
    }
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
    if([_originalDelegate respondsToSelector:@selector(webView:didFailLoadWithError:forFrame:)]) {
        [_originalDelegate webView:sender didFailLoadWithError:error forFrame:frame];
    }
}

- (void)webView:(WebView *)sender didCommitLoadForFrame:(WebFrame *)frame {
    if([_originalDelegate respondsToSelector:@selector(webView:didCommitLoadForFrame:)]) {
        [_originalDelegate webView:sender didCommitLoadForFrame:frame];
    }
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame {
    if([_originalDelegate respondsToSelector:@selector(webView:didReceiveTitle:forFrame:)]) {
        [_originalDelegate webView:sender didReceiveTitle:title forFrame:frame];
    }
}

- (void)webView:(WebView *)sender didReceiveIcon:(NSImage *)image forFrame:(WebFrame *)frame {
    if([_originalDelegate respondsToSelector:@selector(webView:didReceiveIcon:forFrame:)]) {
        [_originalDelegate webView:sender didReceiveIcon:image forFrame:frame];
    }
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    if([_originalDelegate respondsToSelector:@selector(webView:didFinishLoadForFrame:)]) {
        [_originalDelegate webView:sender didFinishLoadForFrame:frame];
    }
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
    if([_originalDelegate respondsToSelector:@selector(webView:didFailLoadWithError:forFrame:)]) {
        [_originalDelegate webView:sender didFailLoadWithError:error forFrame:frame];
    }
}

- (void)webView:(WebView *)sender didChangeLocationWithinPageForFrame:(WebFrame *)frame {
    if([_originalDelegate respondsToSelector:@selector(webView:didChangeLocationWithinPageForFrame:)]) {
        [_originalDelegate webView:sender didChangeLocationWithinPageForFrame:frame];
    }
}

- (void)webView:(WebView *)sender willPerformClientRedirectToURL:(NSURL *)URL delay:(NSTimeInterval)seconds fireDate:(NSDate *)date forFrame:(WebFrame *)frame {
    if([_originalDelegate respondsToSelector:@selector(webView:willPerformClientRedirectToURL:delay:fireDate:forFrame:)]) {
        [_originalDelegate webView:sender willPerformClientRedirectToURL:URL delay:seconds fireDate:date forFrame:frame];
    }
}


- (void)webView:(WebView *)sender didCancelClientRedirectForFrame:(WebFrame *)frame {
    if([_originalDelegate respondsToSelector:@selector(webView:didCancelClientRedirectForFrame:)]) {
        [_originalDelegate webView:sender didCancelClientRedirectForFrame:frame];
    }
}

- (void)webView:(WebView *)sender willCloseFrame:(WebFrame *)frame {
    if([_originalDelegate respondsToSelector:@selector(webView:willCloseFrame:)]) {
        [_originalDelegate webView:sender willCloseFrame:frame];
    }
}

- (void)webView:(WebView *)webView didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame {
    //set us as bridge
    [windowObject setValue:self forKey:@"DDBridgableWebView"];

    if([_originalDelegate respondsToSelector:@selector(webView:didClearWindowObject:forFrame:)]) {
        [_originalDelegate webView:webView didClearWindowObject:windowObject forFrame:frame];
    }
}

- (void)webView:(WebView *)webView windowScriptObjectAvailable:(WebScriptObject *)windowScriptObject {
    //set us as bridge
    [windowScriptObject setValue:self forKey:@"DDBridgableWebView"];

    if([_originalDelegate respondsToSelector:@selector(webView:windowScriptObjectAvailable:)]) {
        [_originalDelegate webView:webView windowScriptObjectAvailable:windowScriptObject];
    }
}

- (void)webView:(WebView *)webView didCreateJavaScriptContext:(JSContext *)context forFrame:(WebFrame *)frame {
    if([_originalDelegate respondsToSelector:@selector(webView:didCreateJavaScriptContext:forFrame:)]) {
        [_originalDelegate webView:webView didCreateJavaScriptContext:context forFrame:frame];
    }
}

@end
#endif