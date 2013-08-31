//
//  DDImageFilter.h
//  DDEnhancedJSBridge
//
//  Created by Dominik Pich on 18.08.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DDEnhancedJSBridge.h"
#import "DDBridgableWebView.h"
#import "DDBridgableObject.h"

@interface DDImageFilter : NSObject<DDBridgableObject>

//exposed to the web
- (void)setImage:(NSDictionary*)params bridgedFrom:(id<DDBridgableWebView>)webview;
- (void)setMaskImage:(NSDictionary*)params bridgedFrom:(id<DDBridgableWebView>)webview;

@end
