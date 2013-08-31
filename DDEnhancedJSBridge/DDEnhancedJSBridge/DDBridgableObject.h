//
//  DDBridgableObject.h
//  DDEnhancedJSBridge
//
//  Created by Dominik Pich on 31.07.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DDEnhancedJSBridge;

@protocol DDBridgableObject <NSObject>
@property(weak) id<DDEnhancedJSBridge> DDEnhancedJSBridge;
@end
