//
//  UIWebView+getBridgedElementByID.m
//  DDPicFromWeb
//
//  Created by Dominik Pich on 11/01/14.
//  Copyright (c) 2014 Dominik Pich. All rights reserved.
//

#import "UIWebView+getBridgedElementByID.h"

@implementation UIWebView (getBridgedElementByID)

- (NSString*)getBridgedElementByID:(NSString*)theID {
    id str = [NSString stringWithFormat:@"getBridgedElementByID('%@')", theID];
    return [self stringByEvaluatingJavaScriptFromString:str];
}

@end
