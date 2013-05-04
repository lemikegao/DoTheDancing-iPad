//
//  MainMenuLayer.m
//  chinAndCheeksTemplate
//
//  Created by Michael Gao on 11/17/12.
//
//

#import "MainMenuLayer.h"
#import "Constants.h"
#import "GameManager.h"

@interface MainMenuLayer()

@property (nonatomic) CGSize screenSize;
@property (nonatomic, strong) CCSpriteBatchNode *batchNode;

@end

@implementation MainMenuLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        // load texture atlas
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"spritesheet.plist"];
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
    CCMenuItemLabel *connectButton = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Connect to Device" fontName:@"Helvetica" fontSize:40] block:^(id sender) {
        // segue to 'Searching for Device...'
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeSearchingForDevice];
    }];
    connectButton.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.5);
    
    CCMenu *menu = [CCMenu menuWithItems:connectButton, nil];
    menu.position = ccp(0, 0);
    
    [self addChild:menu];
}

@end
