//
//  ConnectedToDeviceScene.m
//  DoTheDancing-iPad
//
//  Created by Michael Gao on 5/5/13.
//
//

#import "ConnectedToDeviceScene.h"
#import "ConnectedToDeviceLayer.h"

@implementation ConnectedToDeviceScene

-(id)init {
    self = [super init];
    if (self != nil) {
        ConnectedToDeviceLayer *layer = [ConnectedToDeviceLayer node];
        [self addChild:layer];
    }
    
    return self;
}

@end
