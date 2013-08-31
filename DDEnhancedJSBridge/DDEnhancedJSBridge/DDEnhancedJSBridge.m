//
//  DDEnhancedJSBridge.m
//  DDEnhancedJSBridge
//
//  Created by Dominik Pich on 31.07.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import "DDEnhancedJSBridge.h"

@implementation DDEnhancedJSBridge {
    NSMutableArray *_ownedWebViews;
    NSMutableDictionary *_ownedObjects;
}

+ (instancetype)defaultBridge {
    NSAssert([NSThread isMainThread], @"DDEnhancedBridge is only meant for the main thread");

    static id defaultBridge;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultBridge = [[[self class] alloc] init];
    });

    return defaultBridge;
}

///the url scheme used by this bridge DDBridge per default
- (NSString *)urlScheme {
    return @"DDBridge";
}

#pragma mark -

- (void)addWebView:(id<DDBridgableWebView>)wv {
    NSParameterAssert([wv conformsToProtocol:@protocol(DDBridgableWebView)] && wv.DDEnhancedJSBridge!=self);
    NSAssert([NSThread isMainThread], @"DDEnhancedBridge is only meant for the main thread");
    
    if(!_ownedWebViews) {
        _ownedWebViews = nil;
    }
    [_ownedWebViews addObject:wv];
    wv.DDEnhancedJSBridge = self;
}

- (void)removeWebView:(id<DDBridgableWebView>)wv {
    NSParameterAssert([wv conformsToProtocol:@protocol(DDBridgableWebView)] && wv.DDEnhancedJSBridge==self);
    NSAssert([NSThread isMainThread], @"DDEnhancedBridge is only meant for the main thread");
    [_ownedWebViews removeObject:wv];
    wv.DDEnhancedJSBridge = nil;
}

- (NSArray *)bridgedWebViews {
    NSAssert([NSThread isMainThread], @"DDEnhancedBridge is only meant for the main thread");
    return _ownedWebViews.copy;
}

#pragma mark - 

- (void)addObject:(id<DDBridgableObject>)o forName:(NSString*)name {
    NSParameterAssert([o conformsToProtocol:@protocol(DDBridgableObject)] && o.DDEnhancedJSBridge!=self);
    NSParameterAssert(name.length);
    NSAssert([NSThread isMainThread], @"DDEnhancedBridge is only meant for the main thread");
    
    if (!_ownedObjects) {
        _ownedObjects = [[NSMutableDictionary alloc] init];
    }
    
    _ownedObjects[name] = o;
    o.DDEnhancedJSBridge = self;
}

- (void)removeObject:(id<DDBridgableObject>)o {
    NSParameterAssert([o conformsToProtocol:@protocol(DDBridgableObject)] && o.DDEnhancedJSBridge==self);
    NSAssert([NSThread isMainThread], @"DDEnhancedBridge is only meant for the main thread");
    
    for(id k in [_ownedObjects allKeysForObject:o]) {
        [_ownedObjects removeObjectForKey:k];
    }
    
    o.DDEnhancedJSBridge = nil;
}

- (NSDictionary *)bridgedObjects {
    NSAssert([NSThread isMainThread], @"DDEnhancedBridge is only meant for the main thread");
    return _ownedObjects.copy;
}

#pragma mark -

- (BOOL)canBridgeFromWebView:(id<DDBridgableWebView>)wv toNativeIdentifiedByURL:(NSURL*)url {
    NSParameterAssert([wv conformsToProtocol:@protocol(DDBridgableWebView)] && wv.DDEnhancedJSBridge==self);
    NSParameterAssert(url);
    NSAssert([NSThread isMainThread], @"DDEnhancedBridge is only meant for the main thread");

    return [self splitURL:url toComponent:nil method:nil JSONID:nil];
}

- (void)bridgeFromWebView:(id<DDBridgableWebView>)wv toNativeIdentifiedByURL:(NSURL*)url {
    NSParameterAssert([wv conformsToProtocol:@protocol(DDBridgableWebView)] && wv.DDEnhancedJSBridge==self);
    NSParameterAssert(url);
    NSAssert([NSThread isMainThread], @"DDEnhancedBridge is only meant for the main thread");

    id<DDBridgableObject> obj;
    SEL method;
    NSInteger JSONID;
    
    if([self splitURL:url toComponent:&obj method:&method JSONID:&JSONID]) {
        if(obj) {
            if([obj respondsToSelector:method]) {
                NSDictionary *JSONDict = [wv dictionaryForJSONID:JSONID];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [obj performSelector:method withObject:JSONDict withObject:wv];
#pragma clang diagnostic pop
            }
        }
    }
}

- (BOOL)canBridgeFromNative:(id<DDBridgableObject>)o toWebview:(id<DDBridgableWebView>)wv userInfo:(NSDictionary *)userInfo {
    NSParameterAssert([o conformsToProtocol:@protocol(DDBridgableObject)] && o.DDEnhancedJSBridge==self);
    NSParameterAssert([wv conformsToProtocol:@protocol(DDBridgableWebView)] && wv.DDEnhancedJSBridge==self);
    NSParameterAssert(userInfo.count);
    NSAssert([NSThread isMainThread], @"DDEnhancedBridge is only meant for the main thread");
    
    return [userInfo[@"method"] isKindOfClass:[NSString class]];
}

- (void)bridgeFromNative:(id<DDBridgableObject>)o toWebview:(id<DDBridgableWebView>)wv userInfo:(NSDictionary*)userInfo {
    NSParameterAssert([o conformsToProtocol:@protocol(DDBridgableObject)] && o.DDEnhancedJSBridge==self);
    NSParameterAssert([wv conformsToProtocol:@protocol(DDBridgableWebView)] && wv.DDEnhancedJSBridge==self);
    NSParameterAssert(userInfo.count);
    NSAssert([NSThread isMainThread], @"DDEnhancedBridge is only meant for the main thread");
    
    NSString *method = userInfo[@"method"];
    NSString *sender = [[_ownedObjects allKeysForObject:o] firstObject];
    
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo options:0 error:&jsonError];
    NSAssert(jsonData, jsonError.description);
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    //I need to add a level of indiriction since I put it in another string
    json = [json stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    
    NSString *script = [NSString stringWithFormat:@"%@('%@', '%@');", method, json, sender];
    [wv stringByEvaluatingJavaScriptFromString:script];
}

#pragma mark -

- (BOOL)splitURL:(NSURL*)url toComponent:(id<DDBridgableObject>*)pComponent method:(SEL*)pMethod JSONID:(NSInteger*)pJSONID {
    if([url.scheme.lowercaseString isEqualToString:self.urlScheme.lowercaseString]) {
        NSArray *comps = [url.path componentsSeparatedByString:@"/"];
        NSArray *query = [url.query componentsSeparatedByString:@"="];
        if(url.host.length && comps.count == 2 && query.count == 2) {
            if(pComponent)
                *pComponent = _ownedObjects[url.host];
            if(pMethod)
                *pMethod = NSSelectorFromString([NSString stringWithFormat:@"%@:bridgedFrom:", comps[1]]);
            if(pJSONID)
                *pJSONID = [query[1] integerValue];
            
            return YES;
        }
    }
    
    return NO;
}

@end