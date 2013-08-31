//
//  DDImageFilter.m
//  DDEnhancedJSBridge
//
//  Created by Dominik Pich on 18.08.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import "DDImageFilter.h"

#import "DDImage+Masked.h"
#import "NSData+Base64.h"

@interface DDImageFilter ()
@property (strong, nonatomic) DDImage *image;
@property (strong, nonatomic) DDImage *imageMask;
@end

@implementation DDImageFilter

NSData *DDImagePNGRepresentation(DDImage *image) {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    return UIImagePNGRepresentation(image);
#else
    return [NSBitmapImageRep representationOfImageRepsInArray:image.representations usingType:NSPNGFileType properties:nil];
#endif
}
@synthesize DDEnhancedJSBridge = _bridge;

- (void)setImage:(NSDictionary*)params bridgedFrom:(id<DDBridgableWebView>)webview {
    _image = [[DDImage alloc] initWithData:[NSData dataFromBase64String:params[@"data"]]];
    [self buildResultAndDeliverTo:webview as:params[@"callback"]];
}

- (void)setMaskImage:(NSDictionary*)params bridgedFrom:(id<DDBridgableWebView>)webview {
    _imageMask = [[DDImage alloc] initWithData:[NSData dataFromBase64String:params[@"data"]]];
    [self buildResultAndDeliverTo:webview as:params[@"callback"]];
}

- (void)buildResultAndDeliverTo:(id<DDBridgableWebView>)wv as:(NSString*)cb {
    DDImage *result;
    
    if(_image && _imageMask) {
        result = [_image imageMaskedWith:_imageMask];
    }
    
    NSMutableDictionary *dict = @{@"data" : @"", @"method" : cb}.mutableCopy;
    if(result) {
        NSData *data = DDImagePNGRepresentation(result);
        dict[@"data"] = [data base64EncodedString];
    }
    
    if([_bridge canBridgeFromNative:self toWebview:wv userInfo:dict]) {
        [_bridge bridgeFromNative:self toWebview:wv userInfo:dict];
    }
}

@end
