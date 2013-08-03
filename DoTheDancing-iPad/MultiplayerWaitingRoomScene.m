//
//  MultiplayerWaitingRoomScene.m
//  DoTheDancing-iPad
//
//  Created by Michael Gao on 7/31/13.
//
//

#import "MultiplayerWaitingRoomScene.h"
#import "MultiplayerWaitingRoomLayer.h"

@implementation MultiplayerWaitingRoomScene

-(id)init {
    self = [super init];
    if (self != nil) {
        MultiplayerWaitingRoomLayer *layer = [MultiplayerWaitingRoomLayer node];
        [self addChild:layer];
    }
    
    return self;
}

@end
