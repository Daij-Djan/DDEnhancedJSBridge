//
//  DDEnhancedJSBridge.h
//  DDEnhancedJSBridge
//
//  Created by Dominik Pich on 31.07.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDBridgableWebView.h"
#import "DDBridgableObject.h"

@protocol DDBridgableWebView;
@protocol DDBridgableObject;

@protocol DDEnhancedJSBridge <NSObject>

///should normally be called by a bridged webview (*url TBD*)
///checks if the URL is well formed only. doesnt resolve the bridged object or fetch the JSON
- (BOOL)canBridgeFromWebView:(id<DDBridgableWebView>)wv toNativeIdentifiedByURL:(NSURL*)url;

///decodes the URL and calls the specified child (*url TBD*)
- (void)bridgeFromWebView:(id<DDBridgableWebView>)wv toNativeIdentifiedByURL:(NSURL*)url;

///should normally be called by a bridged webview (*js function naming TBD*)
- (BOOL)canBridgeFromNative:(id<DDBridgableObject>)o toWebview:(id<DDBridgableWebView>)wv userInfo:(NSDictionary*)userInfo;

///sends JSON to the specified webview by calling a JSMethod (*js function TBD*)
- (void)bridgeFromNative:(id<DDBridgableObject>)o toWebview:(id<DDBridgableWebView>)wv userInfo:(NSDictionary*)userInfo;

@end

@interface DDEnhancedJSBridge : NSObject<DDEnhancedJSBridge>

+ (instancetype)defaultBridge;

- (void)addWebView:(id<DDBridgableWebView>)wv;
- (void)removeWebView:(id<DDBridgableWebView>)wv;
@property(readonly) NSArray *bridgedWebViews;

- (void)addObject:(id<DDBridgableObject>)o forName:(NSString*)name;
- (void)removeObject:(id<DDBridgableObject>)o;
@property(readonly) NSDictionary *bridgedObjects;

@end

@interface DDEnhancedJSBridge (SubclassingHooks)

- (NSString *)urlScheme;
- (BOOL)splitURL:(NSURL*)url toComponent:(id<DDBridgableObject>*)pComponent method:(SEL*)pMethod;

@end

/**
 the default URL scheme as implemented by the stock defaultBridge, is DDBridge://%component%/%method%?ReadNotificationWithId=%INT%. The bridge will try to find a BridgableObject named %component%, if it does it will call a selector %method% passing it an NSDictionary with parameters AND the webview that initiated the call.
 
 selectors therefore need to have the following signature:
 - (void)%name%:(NSDictionary*)params bridgedFrom:(id<DDBridgableWebView*)webview
 returning a value should always happen asynchronously. The receiver calls bridgeFromNative:toWebview:
 */

/**
When bridging back from native to a webview the userInfo dictionary MUST contain a param named 'method' that specifies the javascript function to call.

 the js function must have the signature:
 %name%(parametersJSONDictionary, senderName)
 
 senderName specifies the name of the object
 */