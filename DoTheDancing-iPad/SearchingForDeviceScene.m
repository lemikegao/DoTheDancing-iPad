//
//  SearchingForDeviceScene.m
//  DoTheDancing-iPad
//
//  Created by Michael Gao on 5/4/13.
//
//

#import "SearchingForDeviceScene.h"
#import "SearchingForDeviceLayer.h"

@implementation SearchingForDeviceScene

-(id)init {
    self = [super init];
    if (self != nil) {
        SearchingForDeviceLayer *layer = [SearchingForDeviceLayer node];
        [self addChild:layer];
    }
    
    return self;
}

@end
