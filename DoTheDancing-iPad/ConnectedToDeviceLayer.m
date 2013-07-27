//
//  ConnectedToDeviceLayer.m
//  DoTheDancing-iPad
//
//  Created by Michael Gao on 5/5/13.
//
//

#import "ConnectedToDeviceLayer.h"
#import "GameManager.h"

@interface ConnectedToDeviceLayer()

@property (nonatomic) CGSize screenSize;
@property (nonatomic, strong) CCSpriteBatchNode *batchNode;

@end

@implementation ConnectedToDeviceLayer

-(id)init {
    self = [super init];
    if (self) {
        [GameManager sharedGameManager].server.delegate = self;
        self.screenSize = [CCDirector sharedDirector].winSize;
        self.batchNode = [CCSpriteBatchNode batchNodeWithFile:@"spritesheet.pvr.ccz"];
        [self addChild:self.batchNode];
        
        [self displayBackground];
        [self displayLogo];
        [self displayMenu];
    }
    
    return self;
}

-(void)displayBackground {
    CCSprite *bg = [CCSprite spriteWithFile:@"mainmenu_bg.png"];
    bg.anchorPoint = ccp(0.5, 1);
    bg.position = ccp(self.screenSize.width * 0.5, self.screenSize.height);
    [self addChild:bg z:-1];
}

-(void)displayLogo {
    CCSprite *logo = [CCSprite spriteWithSpriteFrameName:@"mainmenu_logo1.png"];
    logo.anchorPoint = ccp(0.5, 1);
    logo.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.96);
    [self.batchNode addChild:logo];
    
    // animate logo
    CCAnimation *animation = [CCAnimation animation];
    animation.restoreOriginalFrame = YES;
    animation.delayPerUnit = 0.25;
    [animation addSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mainmenu_logo2.png"]];
    [animation addSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mainmenu_logo1.png"]];
    id action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]];
    [logo runAction:action];
}

-(void)displayMenu {
    CCMenuItemLabel *singlePlayerButton = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Single Player" fontName:@"Helvetica" fontSize:40] block:^(id sender) {
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeDanceMoveSelection];
    }];
    singlePlayerButton.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.5);
    
    CCMenuItemLabel *disconnectButton = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Disconnect" fontName:@"Helvetica" fontSize:40] block:^(id sender) {
        
    }];
    disconnectButton.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.1);
        
    CCMenu *menu = [CCMenu menuWithItems:singlePlayerButton, disconnectButton, nil];
    menu.position = ccp(0, 0);
    
    [self addChild:menu];
}

#pragma mark - MatchmakingServerDelegate methods
-(void)matchmakingServerClientDidConnect:(NSString *)peerID {

}

-(void)matchmakingServerClientDidDisconnect:(NSString *)peerID {
    
}

-(void)matchmakingServerSessionDidEnd {
    
}

@end
